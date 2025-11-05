import functions_framework
from supabase import create_client, Client
import os
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from shared.auth_utils import require_auth
import requests

# Initialize Supabase client
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

# Chorus Pro API configuration (placeholders)
CHORUS_PRO_API_URL = "https://api.chorus-pro.gouv.fr/"
CHORUS_PRO_CLIENT_ID = os.environ.get("CHORUS_PRO_CLIENT_ID")
CHORUS_PRO_CLIENT_SECRET = os.environ.get("CHORUS_PRO_CLIENT_SECRET")

@functions_framework.http
@require_auth
def submit_to_chorus_pro(request):
    request_json = request.get_json(silent=True)
    invoice_id = request_json.get('invoice_id')

    if not invoice_id:
        return {'success': False, 'error': 'Missing invoice_id'}, 400

    try:
        # 1. Fetch invoice data from Supabase and verify ownership
        invoice_response = supabase.table('invoices').select('user_id, facturx_xml_url').eq('id', invoice_id).single().execute()
        if not invoice_response.data:
            return {'success': False, 'error': 'Invoice not found'}, 404

        if invoice_response.data['user_id'] != request.user_id:
            return {'success': False, 'error': 'Unauthorized access to invoice'}, 403

        if not invoice_response.data.get('facturx_xml_url'):
            return {'success': False, 'error': 'Factur-X XML not generated yet'}, 400

        xml_url = invoice_response.data['facturx_xml_url']

        # 2. Get Factur-X XML from Supabase Storage
        xml_response = requests.get(xml_url)
        xml_response.raise_for_status()
        xml_content = xml_response.content

        # 3. Authenticate with Chorus Pro (placeholder)
        # This is a complex process that would involve OAuth2 or similar
        # For this example, we assume we have a valid token.
        auth_token = "dummy-auth-token"

        # 4. Submit invoice to Chorus Pro
        headers = {
            'Authorization': f'Bearer {auth_token}',
            'Content-Type': 'application/xml'
        }
        submit_url = f"{CHORUS_PRO_API_URL}invoices/submit"
        submit_response = requests.post(submit_url, headers=headers, data=xml_content)
        submit_response.raise_for_status()

        # 5. Update invoice status in Supabase
        submission_status = submit_response.json().get('status')
        supabase.table('invoices').update({
            'chorus_pro_status': submission_status,
            'chorus_pro_submitted_at': 'now()'
        }).eq('id', invoice_id).execute()

        return {'success': True, 'status': submission_status}, 200

    except Exception as e:
        supabase.table('invoices').update({'chorus_pro_status': 'failed'}).eq('id', invoice_id).execute()
        return {'success': False, 'error': str(e)}, 500
