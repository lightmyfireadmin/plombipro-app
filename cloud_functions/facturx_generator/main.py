import functions_framework
from supabase import create_client, Client
import os
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from shared.auth_utils import require_auth
from lxml import etree
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter

# Initialize Supabase client
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

@functions_framework.http
@require_auth
def generate_facturx(request):
    request_json = request.get_json(silent=True)
    invoice_id = request_json.get('invoice_id')

    if not invoice_id:
        return {'success': False, 'error': 'Missing invoice_id'}, 400

    try:
        # 1. Fetch invoice data from Supabase and verify ownership
        invoice_response = supabase.table('invoices').select('user_id').eq('id', invoice_id).single().execute()
        if not invoice_response.data:
            return {'success': False, 'error': 'Invoice not found'}, 404

        if invoice_response.data['user_id'] != request.user_id:
            return {'success': False, 'error': 'Unauthorized access to invoice'}, 403

        # Fetch full invoice data after ownership verification
        invoice_response = supabase.table('invoices').select('*').eq('id', invoice_id).single().execute()
        invoice_data = invoice_response.data

        # 2. Generate Factur-X XML (simplified example)
        root = etree.Element("CrossIndustryInvoice")
        # ... add more XML elements based on the Factur-X specification
        xml_string = etree.tostring(root, pretty_print=True, xml_declaration=True, encoding='UTF-8')

        # 3. Generate PDF (simplified example)
        pdf_path = f"/tmp/{invoice_id}.pdf"
        c = canvas.Canvas(pdf_path, pagesize=letter)
        c.drawString(100, 750, f"Invoice #{invoice_data.get('invoice_number')}")
        # ... add more content to the PDF
        c.save()

        # 4. Embed XML into PDF (this is a placeholder, a real implementation would use a library like pypdf)
        # For now, we will just save the XML to storage
        xml_file_path = f"{invoice_id}.xml"
        with open(f"/tmp/{xml_file_path}", "wb") as f:
            f.write(xml_string)

        # 5. Upload PDF and XML to Supabase Storage
        with open(pdf_path, 'rb') as f:
            supabase.storage.from_('invoices').upload(f"{invoice_id}.pdf", f)
        with open(f"/tmp/{xml_file_path}", 'rb') as f:
            supabase.storage.from_('invoices').upload(xml_file_path, f)

        # 6. Update invoice with PDF and XML URLs
        pdf_url = supabase.storage.from_('invoices').get_public_url(f"{invoice_id}.pdf")
        xml_url = supabase.storage.from_('invoices').get_public_url(xml_file_path)
        supabase.table('invoices').update({'pdf_url': pdf_url, 'facturx_xml_url': xml_url}).eq('id', invoice_id).execute()

        return {'success': True, 'pdf_url': pdf_url, 'xml_url': xml_url}, 200

    except Exception as e:
        return {'success': False, 'error': str(e)}, 500
