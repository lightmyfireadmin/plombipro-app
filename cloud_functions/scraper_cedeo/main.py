import functions_framework
from supabase import create_client, Client
import os
import requests
from bs4 import BeautifulSoup
import time
import random
import logging
from urllib.parse import urljoin, urlparse
from urllib.robotparser import RobotFileParser
from datetime import datetime
import re

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Supabase client
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

# User agents for rotation
USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
]

# Plumbing-related categories to scrape from Cedeo
PLUMBING_CATEGORIES = [
    {'name': 'Tuyauterie', 'url': '/c/plomberie/tuyauterie/p/10_1'},
    {'name': 'Raccords', 'url': '/c/plomberie/raccords/p/10_2'},
    {'name': 'Robinetterie', 'url': '/c/plomberie/robinetterie/p/10_3'},
    {'name': 'Sanitaire', 'url': '/c/plomberie/sanitaire/p/10_4'},
    {'name': 'Plancher chauffant', 'url': '/c/plomberie/plancher-chauffant-rafraichissant-et-accessoires/p/10_5'},
    {'name': 'Évacuation', 'url': '/c/plomberie/evacuation/p/10_6'},
    {'name': 'Chauffage', 'url': '/c/chauffage/p/11_1'},
    {'name': 'Radiateurs', 'url': '/c/chauffage/radiateurs/p/11_2'},
    {'name': 'Chaudières', 'url': '/c/chauffage/chaudieres/p/11_3'},
    {'name': 'Accessoires plomberie', 'url': '/c/plomberie/accessoires/p/10_7'},
]

class CedeoScraper:
    """
    Robust Cedeo scraper with anti-blocking measures
    """

    def __init__(self, base_url='https://www.cedeo.fr'):
        self.base_url = base_url
        self.session = requests.Session()
        self.robot_parser = RobotFileParser()
        self.robot_parser.set_url(urljoin(base_url, '/robots.txt'))
        self.request_count = 0
        self.products_scraped = 0
        self.errors = []

    def can_fetch(self, url):
        """Check if URL can be fetched according to robots.txt"""
        try:
            self.robot_parser.read()
            return self.robot_parser.can_fetch("*", url)
        except Exception as e:
            logger.warning(f"Could not read robots.txt: {e}. Proceeding with caution.")
            return True

    def get_headers(self):
        """Get random headers for request"""
        return {
            'User-Agent': random.choice(USER_AGENTS),
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
            'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
            'Accept-Encoding': 'gzip, deflate, br',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'none',
            'Cache-Control': 'max-age=0',
        }

    def fetch_page(self, url, max_retries=3):
        """Fetch page with retry logic and exponential backoff"""
        full_url = urljoin(self.base_url, url) if not url.startswith('http') else url

        if not self.can_fetch(full_url):
            logger.warning(f"URL blocked by robots.txt: {full_url}")
            return None

        for attempt in range(max_retries):
            try:
                # Rate limiting: 2-5 seconds between requests
                if self.request_count > 0:
                    delay = random.uniform(2, 5)
                    logger.info(f"Waiting {delay:.2f}s before next request...")
                    time.sleep(delay)

                self.request_count += 1
                logger.info(f"Fetching ({attempt + 1}/{max_retries}): {full_url}")

                response = self.session.get(
                    full_url,
                    headers=self.get_headers(),
                    timeout=30,
                    allow_redirects=True
                )

                if response.status_code == 200:
                    return response
                elif response.status_code == 429:  # Too many requests
                    wait_time = 2 ** attempt * 5  # Exponential backoff
                    logger.warning(f"Rate limited. Waiting {wait_time}s...")
                    time.sleep(wait_time)
                elif response.status_code == 403:
                    logger.warning(f"Access forbidden (403) for {full_url}")
                    time.sleep(2 ** attempt * 3)
                else:
                    logger.warning(f"Unexpected status {response.status_code}")

            except requests.exceptions.RequestException as e:
                logger.error(f"Request error (attempt {attempt + 1}): {e}")
                if attempt < max_retries - 1:
                    time.sleep(2 ** attempt)

        return None

    def extract_price(self, price_text):
        """Extract price from text (handles various formats)"""
        if not price_text:
            return None

        # Remove € symbol and spaces
        price_text = price_text.replace('€', '').replace(' ', '').strip()

        # Handle French format: 1 234,56 or 1234,56
        price_text = price_text.replace(',', '.')

        # Extract first number found
        match = re.search(r'(\d+(?:\.\d+)?)', price_text)
        if match:
            try:
                return float(match.group(1))
            except ValueError:
                return None

        return None

    def parse_product_card(self, product_elem, category):
        """Extract product data from a product card element"""
        try:
            product_data = {
                'source': 'cedeo',
                'category': category,
                'scraped_at': datetime.utcnow().isoformat(),
            }

            # Try multiple selectors for name/title
            name_selectors = [
                '.product-title',
                '.product-name',
                'h2.product',
                'h3.product',
                '[itemprop="name"]',
                '.titre-produit',
                '.libelle',
                '.designation',
            ]

            for selector in name_selectors:
                name_elem = product_elem.select_one(selector)
                if name_elem:
                    product_data['name'] = name_elem.get_text(strip=True)
                    break

            # Try multiple selectors for price
            price_selectors = [
                '.product-price',
                '.price',
                '[itemprop="price"]',
                '.prix',
                '.tarif',
                '.price-value',
                '.montant',
            ]

            for selector in price_selectors:
                price_elem = product_elem.select_one(selector)
                if price_elem:
                    price_text = price_elem.get_text(strip=True)
                    price = self.extract_price(price_text)
                    if price:
                        product_data['purchase_price_ht'] = price
                        product_data['selling_price_ht'] = round(price * 1.3, 2)  # 30% margin
                        break

            # Try multiple selectors for reference/SKU
            ref_selectors = [
                '.product-reference',
                '.product-ref',
                '.reference',
                '[itemprop="sku"]',
                '.ref',
                '.code-article',
            ]

            for selector in ref_selectors:
                ref_elem = product_elem.select_one(selector)
                if ref_elem:
                    product_data['reference'] = ref_elem.get_text(strip=True)
                    break

            # Try to get product image
            img_elem = product_elem.select_one('img')
            if img_elem:
                img_src = img_elem.get('src') or img_elem.get('data-src') or img_elem.get('data-lazy-src')
                if img_src:
                    product_data['image_url'] = urljoin(self.base_url, img_src)

            # Try to get product description
            desc_selectors = ['.description', '.product-description', '[itemprop="description"]', '.caracteristiques']
            for selector in desc_selectors:
                desc_elem = product_elem.select_one(selector)
                if desc_elem:
                    product_data['description'] = desc_elem.get_text(strip=True)[:500]
                    break

            # Only return if we have at least name and price
            if 'name' in product_data and 'purchase_price_ht' in product_data:
                return product_data
            else:
                logger.debug(f"Incomplete product data: {product_data.get('name', 'Unknown')}")
                return None

        except Exception as e:
            logger.error(f"Error parsing product: {e}")
            return None

    def scrape_category(self, category):
        """Scrape all products from a category"""
        logger.info(f"Scraping category: {category['name']}")
        products = []

        response = self.fetch_page(category['url'])
        if not response:
            self.errors.append(f"Failed to fetch category: {category['name']}")
            return products

        soup = BeautifulSoup(response.content, 'html.parser')

        # Try multiple selectors for product listings
        product_selectors = [
            '.product-item',
            '.product-card',
            '.product',
            'article.product',
            '[itemtype*="Product"]',
            '.produit',
            '.item-produit',
            'li.product',
        ]

        product_elements = []
        for selector in product_selectors:
            product_elements = soup.select(selector)
            if product_elements:
                logger.info(f"Found {len(product_elements)} products with selector: {selector}")
                break

        if not product_elements:
            logger.warning(f"No products found for category: {category['name']}")
            # Log page structure for debugging
            logger.debug(f"Page structure: {soup.prettify()[:500]}")

        for product_elem in product_elements:
            product_data = self.parse_product_card(product_elem, category['name'])
            if product_data:
                products.append(product_data)

        logger.info(f"Successfully parsed {len(products)} products from {category['name']}")
        return products

    def save_products(self, products):
        """Save products to Supabase"""
        saved_count = 0
        for product in products:
            try:
                # Upsert based on reference if available, otherwise name + source
                if 'reference' in product:
                    existing = supabase.table('products').select('id').eq('reference', product['reference']).eq('source', 'cedeo').execute()
                else:
                    existing = supabase.table('products').select('id').eq('name', product['name']).eq('source', 'cedeo').execute()

                if existing.data:
                    # Update existing
                    supabase.table('products').update(product).eq('id', existing.data[0]['id']).execute()
                else:
                    # Insert new
                    supabase.table('products').insert(product).execute()

                saved_count += 1
                self.products_scraped += 1

            except Exception as e:
                logger.error(f"Error saving product {product.get('name', 'Unknown')}: {e}")
                self.errors.append(f"Save error: {product.get('name', 'Unknown')} - {str(e)}")

        logger.info(f"Saved {saved_count}/{len(products)} products to database")
        return saved_count

    def scrape_all_categories(self, categories=None, max_categories=None):
        """Scrape all or specified categories"""
        if categories is None:
            categories = PLUMBING_CATEGORIES

        if max_categories:
            categories = categories[:max_categories]

        logger.info(f"Starting scrape of {len(categories)} categories from Cedeo")

        all_products = []
        for category in categories:
            try:
                products = self.scrape_category(category)
                if products:
                    saved = self.save_products(products)
                    all_products.extend(products)
                    logger.info(f"Category '{category['name']}': {saved} products saved")
            except Exception as e:
                logger.error(f"Error scraping category {category['name']}: {e}")
                self.errors.append(f"Category error: {category['name']} - {str(e)}")

        return all_products

@functions_framework.cloud_event
def scrape_cedeo(cloud_event):
    """Cloud Function entry point for Cedeo scraping"""
    try:
        logger.info("=== Cedeo Scraper Started ===")

        scraper = CedeoScraper()

        # Get max_categories from event data if provided
        max_categories = None
        if cloud_event.data:
            max_categories = cloud_event.data.get('max_categories')

        products = scraper.scrape_all_categories(max_categories=max_categories)

        result = {
            'success': True,
            'total_products': len(products),
            'products_scraped': scraper.products_scraped,
            'requests_made': scraper.request_count,
            'errors': scraper.errors,
            'timestamp': datetime.utcnow().isoformat(),
        }

        logger.info(f"=== Scraping Complete ===")
        logger.info(f"Products scraped: {result['products_scraped']}")
        logger.info(f"Requests made: {result['requests_made']}")
        logger.info(f"Errors: {len(result['errors'])}")

        return result, 200

    except Exception as e:
        logger.error(f"Fatal error in Cedeo scraper: {e}", exc_info=True)
        return {
            'success': False,
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat(),
        }, 500

@functions_framework.http
def scrape_cedeo_http(request):
    """HTTP endpoint for testing Cedeo scraper"""
    try:
        # Mock cloud event
        class MockEvent:
            def __init__(self):
                self.data = request.get_json() if request.is_json else {}

        result, status_code = scrape_cedeo(MockEvent())
        return result, status_code

    except Exception as e:
        return {'success': False, 'error': str(e)}, 500
