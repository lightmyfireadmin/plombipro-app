import functions_framework
from supabase import create_client, Client
import os
from google.cloud import vision
import re
from datetime import datetime
from typing import Dict, List, Optional, Tuple

# Initialize Supabase client
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

# Initialize Google Vision client
vision_client = vision.ImageAnnotatorClient()

class OCRParser:
    """Enhanced OCR parser for French supplier invoices"""

    # Common keywords for French invoices
    INVOICE_KEYWORDS = ['facture', 'invoice', 'n°', 'numero', 'numéro']
    DATE_KEYWORDS = ['date', 'le', 'du']
    TOTAL_KEYWORDS = ['total', 'ttc', 'à payer', 'net à payer', 'montant']
    QUANTITY_KEYWORDS = ['qté', 'quantité', 'quantity', 'qt']
    UNIT_PRICE_KEYWORDS = ['prix', 'p.u.', 'pu', 'unit', 'unitaire']
    SIRET_PATTERN = r'\b\d{3}\s?\d{3}\s?\d{3}\s?\d{5}\b'
    VAT_NUMBER_PATTERN = r'FR\s?\d{2}\s?\d{9}'

    @staticmethod
    def extract_invoice_number(text: str) -> Tuple[Optional[str], float]:
        """Extract invoice number with confidence score"""
        patterns = [
            r'(?:facture|invoice|n°|numero|numéro)\s*[:\-]?\s*([A-Z0-9\-\/]+)',
            r'N°\s*([A-Z0-9\-\/]+)',
            r'(?:FACT|INV|FAC)\s*[:\-]?\s*([A-Z0-9\-\/]+)'
        ]

        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                invoice_num = match.group(1).strip()
                # Higher confidence if it matches common patterns
                confidence = 0.9 if re.match(r'^[A-Z]{3,4}-?\d{4,}', invoice_num) else 0.7
                return invoice_num, confidence

        return None, 0.0

    @staticmethod
    def extract_date(text: str) -> Tuple[Optional[str], float]:
        """Extract invoice date with confidence score"""
        # French date patterns
        patterns = [
            r'(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})',  # DD/MM/YYYY
            r'(\d{4})[\/\-\.](\d{1,2})[\/\-\.](\d{1,2})',  # YYYY/MM/DD
            r'(\d{1,2})\s+(janvier|février|mars|avril|mai|juin|juillet|août|septembre|octobre|novembre|décembre)\s+(\d{4})',  # DD Month YYYY
        ]

        months_fr = {
            'janvier': '01', 'février': '02', 'mars': '03', 'avril': '04',
            'mai': '05', 'juin': '06', 'juillet': '07', 'août': '08',
            'septembre': '09', 'octobre': '10', 'novembre': '11', 'décembre': '12'
        }

        for pattern in patterns:
            matches = re.finditer(pattern, text, re.IGNORECASE)
            for match in matches:
                try:
                    if len(match.groups()) == 3:
                        if match.group(2).lower() in months_fr:
                            # Text month format
                            day = match.group(1)
                            month = months_fr[match.group(2).lower()]
                            year = match.group(3)
                            date_str = f"{year}-{month.zfill(2)}-{day.zfill(2)}"
                        else:
                            # Numeric format
                            if len(match.group(1)) == 4:  # YYYY/MM/DD
                                date_str = f"{match.group(1)}-{match.group(2).zfill(2)}-{match.group(3).zfill(2)}"
                            else:  # DD/MM/YYYY
                                date_str = f"{match.group(3)}-{match.group(2).zfill(2)}-{match.group(1).zfill(2)}"

                        # Validate date
                        datetime.strptime(date_str, '%Y-%m-%d')
                        return date_str, 0.85
                except (ValueError, IndexError):
                    continue

        return None, 0.0

    @staticmethod
    def extract_amounts(text: str) -> List[float]:
        """Extract all monetary amounts from text"""
        # Patterns for French currency (with comma or dot decimal separator)
        patterns = [
            r'\b(\d{1,3}(?:[\s,]\d{3})*[,.]\d{2})\s*€?',  # 1 234,56 or 1234.56
            r'€\s*(\d{1,3}(?:[\s,]\d{3})*[,.]\d{2})',     # € 1234,56
        ]

        amounts = []
        for pattern in patterns:
            matches = re.finditer(pattern, text)
            for match in matches:
                amount_str = match.group(1)
                # Normalize: remove spaces, replace comma with dot
                amount_str = amount_str.replace(' ', '').replace(',', '.')
                try:
                    amounts.append(float(amount_str))
                except ValueError:
                    continue

        return amounts

    @staticmethod
    def extract_total_amount(text: str) -> Tuple[Optional[float], float]:
        """Extract total TTC amount with confidence score"""
        lines = text.split('\n')

        for i, line in enumerate(lines):
            line_lower = line.lower()
            # Look for lines with "total" keywords
            if any(keyword in line_lower for keyword in OCRParser.TOTAL_KEYWORDS):
                # Extract amounts from this line and next 2 lines
                search_text = '\n'.join(lines[i:i+3])
                amounts = OCRParser.extract_amounts(search_text)

                if amounts:
                    # Usually the largest amount near "total" is the total
                    total = max(amounts)
                    confidence = 0.9 if 'ttc' in line_lower or 'payer' in line_lower else 0.7
                    return total, confidence

        # Fallback: return largest amount in document
        all_amounts = OCRParser.extract_amounts(text)
        if all_amounts:
            return max(all_amounts), 0.5

        return None, 0.0

    @staticmethod
    def extract_supplier_info(text: str) -> Dict[str, any]:
        """Extract supplier name, SIRET, VAT number"""
        lines = text.split('\n')
        supplier_name = None
        siret = None
        vat_number = None

        # Supplier name is usually in first 5 lines (largest/boldest text)
        if len(lines) > 0:
            # Take first non-empty line as supplier name
            for line in lines[:5]:
                if line.strip() and len(line.strip()) > 2:
                    supplier_name = line.strip()
                    break

        # SIRET
        siret_match = re.search(OCRParser.SIRET_PATTERN, text)
        if siret_match:
            siret = siret_match.group(0).replace(' ', '')

        # VAT Number
        vat_match = re.search(OCRParser.VAT_NUMBER_PATTERN, text)
        if vat_match:
            vat_number = vat_match.group(0).replace(' ', '')

        confidence = 0.8 if supplier_name else 0.3

        return {
            'supplier_name': supplier_name,
            'siret': siret,
            'vat_number': vat_number,
            'confidence': confidence
        }

    @staticmethod
    def extract_line_items(text: str, blocks: List) -> Tuple[List[Dict], float]:
        """
        Extract line items using table detection
        Returns: (line_items, confidence_score)
        """
        line_items = []

        # Try to detect table structure using Vision API blocks
        # This is simplified - in production you'd use more sophisticated table detection
        lines = text.split('\n')

        # Look for lines with numeric patterns (quantity + price + total)
        # Pattern: description ... quantity ... unit_price ... line_total
        item_pattern = r'(.+?)\s+(\d+(?:[.,]\d+)?)\s+(\d+[.,]\d{2})\s+(\d+[.,]\d{2})'

        for line in lines:
            match = re.search(item_pattern, line)
            if match:
                description = match.group(1).strip()
                quantity = float(match.group(2).replace(',', '.'))
                unit_price = float(match.group(3).replace(',', '.'))
                line_total = float(match.group(4).replace(',', '.'))

                # Validate: line_total should be close to quantity * unit_price
                expected_total = quantity * unit_price
                if abs(expected_total - line_total) < 1.0:  # Allow small rounding difference
                    line_items.append({
                        'description': description,
                        'quantity': quantity,
                        'unit_price': unit_price,
                        'line_total': line_total,
                        'vat_rate': 20.0  # Default, could be enhanced
                    })

        confidence = 0.8 if len(line_items) > 0 else 0.2

        return line_items, confidence

    @staticmethod
    def extract_vat_amount(text: str) -> Tuple[Optional[float], float]:
        """Extract VAT amount"""
        patterns = [
            r'(?:tva|vat)\s*(?:20%|20\s*%)?\s*[:\-]?\s*(\d+[.,]\d{2})',
            r'montant\s+tva\s*[:\-]?\s*(\d+[.,]\d{2})'
        ]

        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                vat_amount = float(match.group(1).replace(',', '.'))
                return vat_amount, 0.8

        return None, 0.0


@functions_framework.http
def process_ocr(request):
    """Enhanced OCR processing with line items and confidence scores"""
    request_json = request.get_json(silent=True)
    image_url = request_json.get('image_url')
    scan_id = request_json.get('scan_id')

    if not image_url or not scan_id:
        return {'success': False, 'error': 'Missing image_url or scan_id'}, 400

    try:
        # 1. Call Vision API for text detection
        image = vision.Image()
        image.source.image_uri = image_url

        # Get both text annotations and full text
        response = vision_client.document_text_detection(image=image)

        if response.error.message:
            raise Exception(f'Vision API error: {response.error.message}')

        full_text = response.full_text_annotation.text

        if not full_text:
            raise Exception('No text found in image.')

        # 2. Parse the extracted text
        parser = OCRParser()

        invoice_number, invoice_number_conf = parser.extract_invoice_number(full_text)
        invoice_date, invoice_date_conf = parser.extract_date(full_text)
        supplier_info = parser.extract_supplier_info(full_text)
        total_ttc, total_conf = parser.extract_total_amount(full_text)
        vat_amount, vat_conf = parser.extract_vat_amount(full_text)
        line_items, line_items_conf = parser.extract_line_items(full_text, response.full_text_annotation.pages)

        # Calculate subtotal if we have total and VAT
        subtotal_ht = None
        if total_ttc and vat_amount:
            subtotal_ht = total_ttc - vat_amount

        # 3. Build structured data
        extracted_data = {
            'invoice_number': invoice_number,
            'invoice_date': invoice_date,
            'supplier_name': supplier_info['supplier_name'],
            'supplier_siret': supplier_info['siret'],
            'supplier_vat_number': supplier_info['vat_number'],
            'subtotal_ht': subtotal_ht,
            'vat_amount': vat_amount,
            'total_ttc': total_ttc,
            'line_items': line_items,
            'raw_text': full_text,
            'confidence_scores': {
                'invoice_number': invoice_number_conf,
                'invoice_date': invoice_date_conf,
                'supplier_info': supplier_info['confidence'],
                'total_amount': total_conf,
                'vat_amount': vat_conf,
                'line_items': line_items_conf,
                'overall': (invoice_number_conf + invoice_date_conf + supplier_info['confidence'] +
                           total_conf + line_items_conf) / 5
            }
        }

        # 4. Update scans table
        update_response = supabase.table('scans').update({
            'extracted_data': extracted_data,
            'extraction_status': 'needs_review' if extracted_data['confidence_scores']['overall'] < 0.8 else 'completed'
        }).eq('id', scan_id).execute()

        if len(update_response.data) == 0:
            raise Exception('Failed to update scan record.')

        return {'success': True, 'result': extracted_data}, 200

    except Exception as e:
        # Update scan status to failed
        supabase.table('scans').update({
            'extraction_status': 'failed',
            'extracted_data': {'error': str(e)}
        }).eq('id', scan_id).execute()
        return {'success': False, 'error': str(e)}, 500
