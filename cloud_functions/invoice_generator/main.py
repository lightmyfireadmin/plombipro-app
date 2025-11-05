import os
import functions_framework
from flask import Request, jsonify
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from supabase import create_client, Client

# Initialize Supabase client
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

@functions_framework.http
def invoice_generator(request: Request):
    """
    HTTP Cloud Function that generates a PDF invoice from provided data,
    stores it in Supabase Storage, and returns a link to the invoice.
    """
    if request.method == 'OPTIONS':
        # Handle CORS preflight request
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)

    headers = {
        'Access-Control-Allow-Origin': '*'
    }

    request_json = request.get_json(silent=True)
    if not request_json:
        return jsonify({"error": "Invalid JSON payload"}), 400, headers

    # Extract invoice data from the request
    invoice_data = request_json.get('invoice_data')
    if not invoice_data:
        return jsonify({"error": "Missing 'invoice_data' in payload"}), 400, headers

    invoice_id = invoice_data.get('invoice_id', 'INV-0000')
    client_name = invoice_data.get('client_name', 'Client Name')
    items = invoice_data.get('items', [])
    total_amount = invoice_data.get('total_amount', 0.0)

    # --- PDF Generation Logic (using ReportLab) ---
    try:
        pdf_filename = f"invoice_{invoice_id}.pdf"
        # Create a PDF document
        c = canvas.Canvas(pdf_filename, pagesize=letter)
        width, height = letter

        # Add content to the PDF
        c.drawString(100, height - 50, f"Invoice ID: {invoice_id}")
        c.drawString(100, height - 70, f"Client: {client_name}")
        c.drawString(100, height - 100, "Items:")
        
        y_position = height - 120
        for item in items:
            c.drawString(120, y_position, f"- {item.get('description')} (Qty: {item.get('quantity')}, Price: {item.get('price')})")
            y_position -= 20
        
        c.drawString(100, y_position - 20, f"Total: ${total_amount:.2f}")

        c.save()

    except Exception as e:
        return jsonify({"error": f"PDF generation failed: {str(e)}"}), 500, headers

    # --- Supabase Storage Integration ---
    try:
        with open(pdf_filename, 'rb') as f:
            pdf_bytes = f.read()
        
        # Upload to Supabase Storage 'documents' bucket
        # The path in storage will be 'user_id/invoice_id.pdf'
        # Assuming user_id can be derived from auth.uid() in a real scenario,
        # for now, we'll use a placeholder or expect it in invoice_data
        user_id = invoice_data.get('user_id', 'anonymous') # Placeholder for user ID
        storage_path = f"{user_id}/{pdf_filename}"

        response = supabase.storage.from_('documents').upload(
            file=pdf_bytes,
            path=storage_path,
            file_options={"content-type": "application/pdf"}
        )
        
        # Check for errors in Supabase upload response
        if response.get('error'):
            return jsonify({"error": f"Supabase upload failed: {response['error']['message']}"}), 500, headers

        # Get public URL (if bucket is public or RLS allows)
        # For private buckets, you'd generate a signed URL
        public_url_response = supabase.storage.from_('documents').get_public_url(storage_path)
        
        # Clean up local PDF file
        os.remove(pdf_filename)

        return jsonify({
            "message": "Invoice generated and stored successfully",
            "invoice_url": public_url_response
        }), 200, headers

    except Exception as e:
        # Clean up local PDF file if it exists
        if os.path.exists(pdf_filename):
            os.remove(pdf_filename)
        return jsonify({"error": f"Supabase storage operation failed: {str(e)}"}), 500, headers

