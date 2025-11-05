import functions_framework
from supabase import create_client, Client
import os
from google.cloud import vision
import re
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from shared.auth_utils import require_auth

# Initialize Supabase client
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

# Initialize Google Vision client
vision_client = vision.ImageAnnotatorClient()

@functions_framework.http
@require_auth
def process_ocr(request):
    request_json = request.get_json(silent=True)
    image_url = request_json.get('image_url')
    scan_id = request_json.get('scan_id')

    if not image_url or not scan_id:
        return {'success': False, 'error': 'Missing image_url or scan_id'}, 400

    # Verify user owns this scan
    try:
        scan_response = supabase.table('scans').select('user_id').eq('id', scan_id).execute()
        if not scan_response.data:
            return {'success': False, 'error': 'Scan not found'}, 404

        scan_user_id = scan_response.data[0]['user_id']
        if scan_user_id != request.user_id:
            return {'success': False, 'error': 'Unauthorized access to scan'}, 403
    except Exception as e:
        return {'success': False, 'error': f'Failed to verify scan ownership: {str(e)}'}, 500

    try:
        # 1. Download image from Supabase Storage
        # This is a simplified example. In a real scenario, you would download the image bytes.
        # For now, we assume the image_url is publicly accessible.

        # 2. Call Vision API
        image = vision.Image()
        image.source.image_uri = image_url
        response = vision_client.text_detection(image=image)
        texts = response.text_annotations

        if not texts:
            raise Exception('No text found in image.')

        raw_text = texts[0].description

        # 3. Parse text (highly simplified example)
        supplier_name = texts[1].description if len(texts) > 1 else 'Unknown'
        total_amount = 0.0
        
        # Regex to find amounts (e.g., 123,45 or 123.45)
        amount_pattern = re.compile(r'\d+[,.]\d{2}')
        amounts = amount_pattern.findall(raw_text)
        if amounts:
            # Assume the largest amount is the total
            total_amount = max([float(a.replace(',', '.')) for a in amounts])

        extracted_data = {
            'supplier_name': supplier_name,
            'total_amount': total_amount,
            'raw_text': raw_text,
        }

        # 4. Update scans table
        update_response = supabase.table('scans').update({
            'extracted_data': extracted_data,
            'extraction_status': 'needs_review'
        }).eq('id', scan_id).execute()

        if len(update_response.data) == 0:
            raise Exception('Failed to update scan record.')

        return {'success': True, 'result': extracted_data}, 200

    except Exception as e:
        # Update scan status to failed
        supabase.table('scans').update({'extraction_status': 'failed'}).eq('id', scan_id).execute()
        return {'success': False, 'error': str(e)}, 500
