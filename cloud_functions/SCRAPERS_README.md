# Web Scrapers Documentation

## Overview

PlombiPro includes two production-ready web scrapers for automatically importing plumbing products from major French suppliers:

1. **Point P Scraper** (`scraper_point_p/`) - France's leading construction materials supplier
2. **Cedeo Scraper** (`scraper_cedeo/`) - Specialized plumbing and heating supplier

Both scrapers are designed with:
- ✅ Anti-blocking measures (rate limiting, user agent rotation)
- ✅ Robots.txt compliance
- ✅ Exponential backoff retry logic
- ✅ Comprehensive error handling
- ✅ Structured logging
- ✅ Automatic product categorization
- ✅ Scheduled weekly execution

---

## Features

### Robust Scraping
- **Rate Limiting**: 2-5 second delays between requests
- **User Agent Rotation**: 5 different realistic user agents
- **Retry Logic**: 3 attempts with exponential backoff
- **Timeout Handling**: 30-second request timeout
- **Session Management**: Persistent HTTP sessions

### Data Extraction
- **Multiple Selector Fallbacks**: Tries various CSS selectors for each field
- **Price Parsing**: Handles French number formats (1 234,56 €)
- **Image URLs**: Extracts and normalizes product images
- **Product References**: Captures SKU/reference numbers
- **Categories**: 10+ plumbing-specific categories

### Storage
- **Smart Upserts**: Updates existing products, inserts new ones
- **Duplicate Detection**: Based on reference number or name+source
- **30% Margin**: Auto-calculates selling price from purchase price
- **Metadata**: Tracks scrape timestamp and source

---

## Architecture

```
cloud_functions/
├── scraper_point_p/
│   ├── main.py              # Point P scraper implementation
│   └── requirements.txt     # Python dependencies
├── scraper_cedeo/
│   ├── main.py              # Cedeo scraper implementation
│   └── requirements.txt     # Python dependencies
├── scrapers_scheduler.yaml  # Cloud Scheduler configuration
└── SCRAPERS_README.md       # This file
```

---

## Installation

### 1. Deploy Cloud Functions

#### Point P Scraper
```bash
cd cloud_functions/scraper_point_p

gcloud functions deploy scrape_point_p \
  --gen2 \
  --runtime=python311 \
  --region=europe-west1 \
  --source=. \
  --entry-point=scrape_point_p \
  --trigger-http \
  --allow-unauthenticated \
  --timeout=540s \
  --memory=512MB \
  --set-env-vars SUPABASE_URL=your_supabase_url,SUPABASE_KEY=your_supabase_key
```

#### Cedeo Scraper
```bash
cd cloud_functions/scraper_cedeo

gcloud functions deploy scrape_cedeo \
  --gen2 \
  --runtime=python311 \
  --region=europe-west1 \
  --source=. \
  --entry-point=scrape_cedeo \
  --trigger-http \
  --allow-unauthenticated \
  --timeout=540s \
  --memory=512MB \
  --set-env-vars SUPABASE_URL=your_supabase_url,SUPABASE_KEY=your_supabase_key
```

### 2. Set Up Cloud Scheduler

See `scrapers_scheduler.yaml` for full configuration.

**Quick setup:**
```bash
# Point P - Every Sunday at 2:00 AM
gcloud scheduler jobs create http pointp-weekly-scrape \
  --location=europe-west1 \
  --schedule="0 2 * * 0" \
  --time-zone="Europe/Paris" \
  --uri="https://europe-west1-YOUR_PROJECT_ID.cloudfunctions.net/scrape_point_p" \
  --http-method=POST \
  --message-body='{}' \
  --headers="Content-Type=application/json" \
  --max-retry-attempts=3

# Cedeo - Every Sunday at 4:00 AM
gcloud scheduler jobs create http cedeo-weekly-scrape \
  --location=europe-west1 \
  --schedule="0 4 * * 0" \
  --time-zone="Europe/Paris" \
  --uri="https://europe-west1-YOUR_PROJECT_ID.cloudfunctions.net/scrape_cedeo" \
  --http-method=POST \
  --message-body='{}' \
  --headers="Content-Type=application/json" \
  --max-retry-attempts=3
```

---

## Usage

### Manual Execution

#### Option 1: HTTP Request
```bash
curl -X POST \
  https://europe-west1-YOUR_PROJECT_ID.cloudfunctions.net/scrape_point_p \
  -H "Content-Type: application/json" \
  -d '{}'
```

#### Option 2: gcloud CLI
```bash
gcloud scheduler jobs run pointp-weekly-scrape --location=europe-west1
gcloud scheduler jobs run cedeo-weekly-scrape --location=europe-west1
```

#### Option 3: Python Script
```python
import requests

url = "https://europe-west1-YOUR_PROJECT_ID.cloudfunctions.net/scrape_point_p"
response = requests.post(url, json={})
print(response.json())
```

### Testing with Limited Categories

To test without scraping all categories, pass `max_categories`:

```bash
curl -X POST \
  https://europe-west1-YOUR_PROJECT_ID.cloudfunctions.net/scrape_point_p \
  -H "Content-Type: application/json" \
  -d '{"max_categories": 2}'
```

This will only scrape the first 2 categories.

---

## Response Format

### Success Response

```json
{
  "success": true,
  "total_products": 245,
  "products_scraped": 245,
  "requests_made": 12,
  "errors": [],
  "timestamp": "2025-11-05T14:30:00.000Z"
}
```

### Error Response

```json
{
  "success": false,
  "error": "Connection timeout",
  "timestamp": "2025-11-05T14:30:00.000Z"
}
```

### Partial Success (with errors)

```json
{
  "success": true,
  "total_products": 180,
  "products_scraped": 180,
  "requests_made": 10,
  "errors": [
    "Failed to fetch category: Chauffage",
    "Save error: Product XYZ - Invalid price"
  ],
  "timestamp": "2025-11-05T14:30:00.000Z"
}
```

---

## Database Schema

Products are saved to the `products` table with the following fields:

```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),  -- NULL for scraped products
  name TEXT NOT NULL,
  description TEXT,
  reference TEXT,
  category TEXT,
  purchase_price_ht DECIMAL(10,2),
  selling_price_ht DECIMAL(10,2),
  vat_rate DECIMAL(5,2) DEFAULT 20.00,
  source TEXT,  -- 'pointp' or 'cedeo'
  image_url TEXT,
  scraped_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for scraper queries
CREATE INDEX idx_products_source ON products(source);
CREATE INDEX idx_products_reference_source ON products(reference, source);
CREATE INDEX idx_products_name_source ON products(name, source);
```

---

## Categories Scraped

### Point P
1. Tuyauterie (Pipes)
2. Raccords (Fittings)
3. Robinetterie (Taps/Faucets)
4. Sanitaire (Sanitary)
5. Chauffage (Heating)
6. Évacuation (Drainage)
7. Outils plomberie (Plumbing tools)
8. Raccords PVC (PVC fittings)
9. Raccords cuivre (Copper fittings)
10. Chauffe-eau (Water heaters)

### Cedeo
1. Tuyauterie (Pipes)
2. Raccords (Fittings)
3. Robinetterie (Taps/Faucets)
4. Sanitaire (Sanitary)
5. Plancher chauffant (Underfloor heating)
6. Évacuation (Drainage)
7. Chauffage (Heating)
8. Radiateurs (Radiators)
9. Chaudières (Boilers)
10. Accessoires plomberie (Plumbing accessories)

---

## Monitoring & Logs

### View Cloud Function Logs

```bash
# Point P logs
gcloud logging read \
  "resource.type=cloud_function AND resource.labels.function_name=scrape_point_p" \
  --limit 50 \
  --format json

# Cedeo logs
gcloud logging read \
  "resource.type=cloud_function AND resource.labels.function_name=scrape_cedeo" \
  --limit 50 \
  --format json
```

### Cloud Console
- Cloud Functions: https://console.cloud.google.com/functions
- Cloud Scheduler: https://console.cloud.google.com/cloudscheduler
- Logs Explorer: https://console.cloud.google.com/logs

### Key Metrics to Monitor
- Execution count (should be 1/week per scraper)
- Success rate (target: >95%)
- Average execution time (expect: 2-10 minutes)
- Products scraped per run (expect: 100-500)
- Error rate (target: <5%)

---

## Troubleshooting

### Common Issues

#### 1. 403 Forbidden Errors
**Symptom:** Scraper returns "Access forbidden (403)"

**Solutions:**
- Website may have enhanced anti-bot measures
- Increase rate limiting delay (change `random.uniform(2, 5)` to `random.uniform(5, 10)`)
- Rotate more user agents
- Consider using proxy service

#### 2. No Products Found
**Symptom:** `products_scraped: 0`

**Solutions:**
- CSS selectors may have changed (website redesign)
- Check logs for "No products found for category"
- Manually inspect website HTML structure
- Update selectors in `parse_product_card()` method

#### 3. Timeout Errors
**Symptom:** Cloud Function times out after 540s

**Solutions:**
- Reduce `max_categories` in scheduler payload
- Increase Cloud Function timeout (max 3600s for HTTP)
- Scrape categories in batches

#### 4. Database Save Errors
**Symptom:** "Error saving product"

**Solutions:**
- Check Supabase credentials in environment variables
- Verify `products` table schema matches expected fields
- Check RLS (Row Level Security) policies
- Review Supabase logs for specific error

### Debug Mode

To enable debug logging, modify `main.py`:

```python
# Change this line:
logging.basicConfig(level=logging.INFO)

# To:
logging.basicConfig(level=logging.DEBUG)
```

Then redeploy the function.

---

## Legal & Ethical Considerations

### Robots.txt Compliance
Both scrapers check `robots.txt` before accessing URLs:
- If a URL is blocked, it will be skipped
- Logs will show: "URL blocked by robots.txt"

### Rate Limiting
- 2-5 second delays between requests (minimum)
- Respects 429 (Too Many Requests) responses
- Exponential backoff on errors

### User Agent Honesty
- Uses realistic browser user agents
- Does not attempt to hide or spoof identity
- Identifies as a standard web browser

### Legal Disclaimer
**This scraper is provided for educational and authorized use only.**

- Ensure you have permission to scrape these websites
- Check Terms of Service of Point P and Cedeo
- Consider reaching out to suppliers for official API access
- Some jurisdictions have laws against unauthorized scraping
- Use at your own risk; author is not liable for misuse

### Recommended Alternatives
1. **Official APIs**: Contact suppliers for API access
2. **Data Partnerships**: Negotiate data-sharing agreements
3. **Manual Entry**: Import catalogs via Excel/CSV
4. **Third-party Data**: Use aggregator services

---

## Maintenance

### Updating Selectors

If websites change their HTML structure:

1. Inspect the website's HTML manually
2. Identify new CSS selectors
3. Update the selector arrays in `parse_product_card()`:

```python
name_selectors = [
    '.new-selector',  # Add new selector
    '.product-title', # Existing selectors
    '.product-name',
    # ...
]
```

4. Test locally or with `max_categories: 1`
5. Redeploy the Cloud Function

### Adding New Categories

1. Find category URL on website (e.g., `/c/plomberie/category-name/p/10_8`)
2. Add to `PLUMBING_CATEGORIES` array:

```python
PLUMBING_CATEGORIES = [
    # Existing categories...
    {'name': 'New Category', 'url': '/c/plomberie/new-category/p/10_8'},
]
```

3. Redeploy

### Performance Tuning

**Speed up scraping (more aggressive):**
```python
delay = random.uniform(1, 2)  # Faster but riskier
```

**Slow down scraping (more respectful):**
```python
delay = random.uniform(5, 10)  # Slower but safer
```

**Increase retry attempts:**
```python
def fetch_page(self, url, max_retries=5):  # Was 3
```

---

## Cost Estimation

### Cloud Functions
- **Invocations**: 2/week (Point P + Cedeo)
- **Execution time**: ~5 minutes each = 10 minutes/week
- **Memory**: 512MB
- **Estimated cost**: $0.10-0.20/month (well within free tier)

### Cloud Scheduler
- **Jobs**: 2 (Point P + Cedeo)
- **Frequency**: Weekly
- **Estimated cost**: $0.20/month (first 3 jobs free)

### Network Egress
- **Data transfer**: ~10-50 MB/week
- **Estimated cost**: <$0.01/month

**Total estimated cost: $0.30-0.50/month** ✅ Very affordable!

---

## Roadmap & Future Enhancements

### Planned Features
- [ ] Selenium/Playwright support for dynamic content
- [ ] Proxy rotation for better anonymity
- [ ] CAPTCHA solving integration
- [ ] Product image downloading and storage
- [ ] Price history tracking
- [ ] Email notifications on completion/errors
- [ ] Dashboard for scraping statistics
- [ ] Diff reports (new products, price changes)

### Additional Suppliers
- [ ] Leroy Merlin
- [ ] Castorama
- [ ] BigMat
- [ ] Tout Faire

---

## Support

### Getting Help
1. Check logs in Cloud Console
2. Review this documentation
3. Inspect website HTML manually
4. Test with `max_categories: 1` first

### Reporting Issues
When reporting issues, include:
- Cloud Function logs (last 50 lines)
- Error message
- Timestamp of failure
- Configuration used (scheduler payload)

---

## License

This code is part of the PlombiPro application and follows the same license.

---

**Last Updated:** 2025-11-05
**Version:** 1.0.0
**Author:** Claude Code (Anthropic)
