# PLOMBIPRO - PART 2: COMPLETE CLOUD FUNCTIONS & BACKEND LOGIC

## 🌩️ GOOGLE CLOUD FUNCTIONS SETUP

### Prerequisites
```bash
# Install Google Cloud CLI
brew install google-cloud-sdk

# Login
gcloud auth login

# Create project
gcloud projects create plombipro-prod

# Enable APIs
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable vision.googleapis.com
gcloud services enable pubsub.googleapis.com

# Set project
gcloud config set project plombipro-prod
```

### Requirements.txt (All Cloud Functions)
```txt
functions-framework==3.5.0
supabase==2.0.0
google-cloud-vision==3.6.0
stripe==7.10.0
sendgrid==6.11.0
python-dateutil==2.8.2
requests==2.31.0
lxml==4.9.4
PyPDF4==1.27.0
reportlab==4.0.9
```

---

## ☁️ CLOUD FUNCTION 1: OCR Invoice Processing

**Function Name:** `ocr_process_invoice`  
**Trigger:** HTTP POST  
**Memory:** 512MB  
**Timeout:** 60s

```python
import functions_framework
import base64
import json
from google.cloud import vision
from datetime import datetime
import re

@functions_framework.http
def ocr_process_invoice(request):
    """Process invoice image with Google Vision OCR"""
    
    # CORS headers
    request.headers.add('Access-Control-Allow-Origin', '*')
    
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        request_json = request.get_json()
        
        if not request_json or 'image_base64' not in request_json:
            return {
                'success': False,
                'error': 'Missing image_base64 in request'
            }, 400
        
        image_base64 = request_json['image_base64']
        
        # Decode base64 image
        image_bytes = base64.b64decode(image_base64)
        
        # Initialize Vision API client
        client = vision.ImageAnnotatorClient()
        image = vision.Image(content=image_bytes)
        
        # Perform OCR
        response = client.document_text_detection(image=image)
        full_text = response.full_text_annotation.text
        
        if response.error.message:
            raise Exception(f"Vision API error: {response.error.message}")
        
        # Parse invoice data
        parsed_data = _parse_invoice_data(full_text)
        
        # Calculate confidence score
        confidence = _calculate_confidence(parsed_data, full_text)
        
        return {
            'success': True,
            'result': {
                'raw_text': full_text,
                'supplier': parsed_data['supplier'],
                'amount': parsed_data['amount'],
                'items': parsed_data['items'],
                'confidence': confidence,
                'image_url': _save_image_to_storage(image_bytes),
                'processed_at': datetime.utcnow().isoformat(),
            }
        }, 200
        
    except Exception as e:
        return {
            'success': False,
            'error': str(e)
        }, 500


def _parse_invoice_data(text):
    """Extract structured data from OCR text"""
    
    data = {
        'supplier': '',
        'amount': 0.0,
        'items': [],
        'date': '',
        'reference': '',
    }
    
    lines = text.split('\n')
    
    # ===== EXTRACT SUPPLIER NAME =====
    # Usually in first 10 lines, look for company indicators
    supplier_keywords = ['SARL', 'EURL', 'SAS', 'SA', 'Ltd', 'Inc', 'Plomberie', 'Sanitaire']
    for line in lines[:15]:
        if any(keyword in line for keyword in supplier_keywords):
            data['supplier'] = line.strip()
            break
    
    if not data['supplier']:
        data['supplier'] = lines[0].strip() if lines else 'Unknown'
    
    # ===== EXTRACT AMOUNT =====
    # Look for currency patterns (€, EUR, etc.)
    amount_patterns = [
        r'(?:TOTAL|Total|MONTANT|Montant|À payer|à payer)[\s:]*([0-9]+[.,][0-9]{2})',
        r'([0-9]+[.,][0-9]{2})\s*(?:€|EUR)',
    ]
    
    for pattern in amount_patterns:
        matches = re.findall(pattern, text, re.IGNORECASE)
        if matches:
            amount_str = matches[-1].replace(',', '.')
            try:
                data['amount'] = float(amount_str)
                break
            except ValueError:
                continue
    
    # ===== EXTRACT LINE ITEMS =====
    # Look for patterns: description + qty + price
    item_pattern = r'(.+?)\s+(\d+(?:[.,]\d+)?)\s+(?:x|@)?\s*([0-9]+[.,][0-9]{2})'
    
    items = re.findall(item_pattern, text)
    for description, qty, price in items:
        data['items'].append({
            'description': description.strip(),
            'quantity': float(qty.replace(',', '.')),
            'price': float(price.replace(',', '.')),
        })
    
    # ===== EXTRACT DATE =====
    date_patterns = [
        r'(?:Date|DATE)[\s:]*(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})',
        r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})',
    ]
    
    for pattern in date_patterns:
        match = re.search(pattern, text)
        if match:
            data['date'] = match.group(1)
            break
    
    return data


def _calculate_confidence(parsed_data, raw_text):
    """Calculate OCR confidence (0.0 to 1.0)"""
    
    confidence = 0.5  # Base confidence
    
    # +0.2 if supplier found
    if parsed_data['supplier'] and parsed_data['supplier'] != 'Unknown':
        confidence += 0.2
    
    # +0.3 if amount found and reasonable (€10 - €10,000)
    if 10 <= parsed_data['amount'] <= 10000:
        confidence += 0.3
    
    # +0.2 if items found
    if len(parsed_data['items']) > 0:
        confidence += 0.2
    
    # +0.1 if date found
    if parsed_data['date']:
        confidence += 0.1
    
    # Reduce if text quality is poor (low character count)
    if len(raw_text) < 100:
        confidence -= 0.1
    
    return round(min(confidence, 1.0), 2)


def _save_image_to_storage(image_bytes):
    """Upload image to Supabase Storage"""
    
    import os
    from supabase import create_client
    import uuid
    
    url = os.environ.get('SUPABASE_URL')
    key = os.environ.get('SUPABASE_KEY')
    supabase = create_client(url, key)
    
    filename = f"ocr_{uuid.uuid4().hex}.jpg"
    
    try:
        response = supabase.storage.from_('scans').upload(
            path=filename,
            file=image_bytes,
            file_options={"content-type": "image/jpeg"},
        )
        
        # Get public URL
        public_url = supabase.storage.from_('scans').get_public_url(filename)
        return public_url
        
    except Exception as e:
        print(f"Storage upload error: {e}")
        return None
```

---

## ☁️ CLOUD FUNCTION 2: Payment Intent (Stripe)

**Function Name:** `create_payment_intent`  
**Trigger:** HTTP POST  
**Memory:** 256MB  
**Timeout:** 10s

```python
import functions_framework
import stripe
import os
import json
from supabase import create_client

stripe.api_key = os.environ.get('STRIPE_SECRET_KEY')

@functions_framework.http
def create_payment_intent(request):
    """Create Stripe payment intent for invoice payment"""
    
    request.headers.add('Access-Control-Allow-Origin', '*')
    
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        request_json = request.get_json()
        
        amount = request_json.get('amount')  # In cents
        currency = request_json.get('currency', 'eur')
        invoice_id = request_json.get('invoice_id')
        user_id = request_json.get('user_id')
        
        if not amount or amount <= 0:
            return {'error': 'Invalid amount'}, 400
        
        if not invoice_id or not user_id:
            return {'error': 'Missing invoice_id or user_id'}, 400
        
        # Create payment intent
        intent = stripe.PaymentIntent.create(
            amount=int(amount),
            currency=currency,
            metadata={
                'invoice_id': invoice_id,
                'user_id': user_id,
            },
            description=f'Invoice payment - {invoice_id}',
        )
        
        # Store intent reference in Supabase
        url = os.environ.get('SUPABASE_URL')
        key = os.environ.get('SUPABASE_KEY')
        supabase = create_client(url, key)
        
        supabase.from_('invoices').update({
            'stripe_payment_id': intent['id'],
        }).eq('id', invoice_id).execute()
        
        return {
            'success': True,
            'client_secret': intent['client_secret'],
            'payment_intent_id': intent['id'],
        }, 200
        
    except stripe.error.CardError as e:
        return {'error': f'Card error: {e.user_message}'}, 400
    except stripe.error.RateLimitError:
        return {'error': 'Rate limit exceeded'}, 429
    except stripe.error.InvalidRequestError as e:
        return {'error': f'Invalid request: {e.message}'}, 400
    except Exception as e:
        return {'error': str(e)}, 500
```

---

## ☁️ CLOUD FUNCTION 3: Refund Payment

**Function Name:** `refund_payment`  
**Trigger:** HTTP POST

```python
import functions_framework
import stripe
import os

stripe.api_key = os.environ.get('STRIPE_SECRET_KEY')

@functions_framework.http
def refund_payment(request):
    """Refund a Stripe payment"""
    
    request.headers.add('Access-Control-Allow-Origin', '*')
    
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        request_json = request.get_json()
        
        payment_id = request_json.get('payment_id')
        amount = request_json.get('amount')  # Optional, full refund if not specified
        
        if not payment_id:
            return {'error': 'Missing payment_id'}, 400
        
        # Create refund
        refund_params = {'payment_intent': payment_id}
        
        if amount:
            refund_params['amount'] = int(amount)
        
        refund = stripe.Refund.create(**refund_params)
        
        return {
            'success': True,
            'refund_id': refund['id'],
            'amount': refund['amount'],
        }, 200
        
    except stripe.error.InvalidRequestError as e:
        return {'error': str(e)}, 400
    except Exception as e:
        return {'error': str(e)}, 500
```

---

## ☁️ CLOUD FUNCTION 4: Send Email Notification

**Function Name:** `send_email_notification`  
**Trigger:** HTTP POST

```python
import functions_framework
import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail, Email, To, Content, Attachment
import base64
from datetime import datetime

@functions_framework.http
def send_email_notification(request):
    """Send email via SendGrid"""
    
    request.headers.add('Access-Control-Allow-Origin', '*')
    
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        request_json = request.get_json()
        
        to_email = request_json.get('to')
        subject = request_json.get('subject')
        template_type = request_json.get('template')
        context = request_json.get('context', {})
        pdf_attachment = request_json.get('pdf_base64')  # Optional
        
        if not to_email or not subject or not template_type:
            return {'error': 'Missing required fields'}, 400
        
        # Build HTML content
        html_content = _build_email_html(template_type, context)
        
        # Create email
        message = Mail(
            from_email=Email('facturation@plombipro.fr', 'PlombiPro'),
            to_emails=To(to_email),
            subject=subject,
            html_content=html_content,
        )
        
        # Attach PDF if provided
        if pdf_attachment:
            attachment = Attachment(
                file_content=pdf_attachment,
                file_type='application/pdf',
                file_name=context.get('filename', 'document.pdf'),
                disposition='attachment',
            )
            message.attachment = attachment
        
        # Send
        sg = SendGridAPIClient(os.environ.get('SENDGRID_API_KEY'))
        response = sg.send(message)
        
        return {
            'success': True,
            'message_id': response.headers.get('X-Message-ID'),
        }, 200
        
    except Exception as e:
        return {'error': str(e)}, 500


def _build_email_html(template_type, context):
    """Build HTML email from template"""
    
    templates = {
        'quote_sent': lambda ctx: f"""
            <html>
                <body style="font-family: Arial, sans-serif; color: #333;">
                    <h2>Devis {ctx.get('quote_number', 'N/A')}</h2>
                    <p>Bonjour {ctx.get('client_name', 'Monsieur/Madame')},</p>
                    <p>Veuillez trouver ci-joint votre devis d'un montant de <strong>{ctx.get('amount', '0')}€</strong>.</p>
                    <p>Valide jusqu'au: <strong>{ctx.get('valid_until', 'N/A')}</strong></p>
                    <p><a href="{ctx.get('signature_link', '#')}" style="background-color: #1976D2; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px;">Signer le devis</a></p>
                    <hr>
                    <p>Cordialement,<br>{ctx.get('company_name', 'PlombiPro')}</p>
                </body>
            </html>
        """,
        
        'invoice_sent': lambda ctx: f"""
            <html>
                <body style="font-family: Arial, sans-serif; color: #333;">
                    <h2>Facture {ctx.get('invoice_number', 'N/A')}</h2>
                    <p>Bonjour {ctx.get('client_name', 'Monsieur/Madame')},</p>
                    <p>Veuillez trouver ci-joint votre facture d'un montant de <strong>{ctx.get('amount', '0')}€</strong>.</p>
                    <p>Échéance: <strong>{ctx.get('due_date', 'N/A')}</strong></p>
                    <p><a href="{ctx.get('payment_link', '#')}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px;">Payer en ligne</a></p>
                    <hr>
                    <p>Cordialement,<br>{ctx.get('company_name', 'PlombiPro')}</p>
                </body>
            </html>
        """,
        
        'payment_reminder': lambda ctx: f"""
            <html>
                <body style="font-family: Arial, sans-serif; color: #333;">
                    <h2>Rappel de paiement</h2>
                    <p>Bonjour {ctx.get('client_name', 'Monsieur/Madame')},</p>
                    <p>Nous vous rappelons que la facture <strong>{ctx.get('invoice_number', 'N/A')}</strong> d'un montant de <strong>{ctx.get('amount', '0')}€</strong> est en attente de paiement.</p>
                    <p>Échéance: <strong>{ctx.get('due_date', 'N/A')}</strong></p>
                    <p><a href="{ctx.get('payment_link', '#')}" style="background-color: #FF9800; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px;">Payer maintenant</a></p>
                    <hr>
                    <p>Cordialement,<br>{ctx.get('company_name', 'PlombiPro')}</p>
                </body>
            </html>
        """,
    }
    
    template_func = templates.get(template_type)
    
    if not template_func:
        return "<p>Email template not found</p>"
    
    return template_func(context)
```

---

## ☁️ CLOUD FUNCTION 5: Generate Factur-X XML (2026 Compliance)

**Function Name:** `generate_factur_x`  
**Trigger:** HTTP POST  
**Memory:** 512MB

```python
import functions_framework
from xml.etree.ElementTree import Element, SubElement, tostring
from datetime import datetime
import uuid
import os
from supabase import create_client

@functions_framework.http
def generate_factur_x(request):
    """Generate Factur-X compliant invoice (2026 French mandate)"""
    
    request.headers.add('Access-Control-Allow-Origin', '*')
    
    if request.method == 'OPTIONS':
        return '', 204
    
    try:
        request_json = request.get_json()
        
        invoice_data = request_json.get('invoice')
        company_data = request_json.get('company')
        
        if not invoice_data or not company_data:
            return {'error': 'Missing invoice or company data'}, 400
        
        # Create XML root (EN16931 standard)
        root = Element('Invoice')
        root.set('xmlns', 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100')
        root.set('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
        
        # ===== EXCHANGED DOCUMENT (Metadata) =====
        exchanged_doc = SubElement(root, 'ExchangedDocument')
        SubElement(exchanged_doc, 'ID').text = invoice_data['invoice_number']
        SubElement(exchanged_doc, 'TypeCode').text = '380'  # Commercial invoice
        issue_dt = SubElement(exchanged_doc, 'IssueDateTime')
        dt = SubElement(issue_dt, 'DateTimeString')
        dt.set('format', '102')  # YYYYMMDD
        dt.text = datetime.fromisoformat(invoice_data['issue_date']).strftime('%Y%m%d')
        
        # ===== SUPPLY CHAIN TRADE TRANSACTION =====
        trade_transaction = SubElement(root, 'SupplyChainTradeTransaction')
        
        # Line items
        for idx, item in enumerate(invoice_data['items'], 1):
            line_item = SubElement(trade_transaction, 'IncludedSupplyChainTradeLineItem')
            
            doc = SubElement(line_item, 'AssociatedDocument')
            SubElement(doc, 'LineID').text = str(idx)
            
            product = SubElement(line_item, 'SpecifiedTradeProduct')
            SubElement(product, 'Name').text = item['description']
            
            delivery = SubElement(line_item, 'SpecifiedLineTradeAgreement')
            price_spec = SubElement(delivery, 'NetPriceProductTradePrice')
            SubElement(price_spec, 'ChargeAmount').text = str(round(item['unit_price'], 2))
            
            settlement = SubElement(line_item, 'SpecifiedLineTradeSettlement')
            SubElement(settlement, 'ApplicableTradeLineTax').text = str(item.get('tax_rate', 20))
            
            total_settlement = SubElement(settlement, 'SpecifiedTradeSettlementMonetarySummation')
            SubElement(total_settlement, 'LineTotalAmount').text = str(round(
                item['quantity'] * item['unit_price'], 2
            ))
        
        # ===== HEADER TRADE SETTLEMENT (Totals) =====
        header_settlement = SubElement(trade_transaction, 'ApplicableHeaderTradeSettlement')
        
        # Buyer/Seller
        buyer = SubElement(header_settlement, 'BuyerTradeParty')
        SubElement(buyer, 'Name').text = invoice_data.get('client_name', 'Customer')
        
        seller = SubElement(header_settlement, 'SellerTradeParty')
        SubElement(seller, 'Name').text = company_data['company_name']
        SubElement(seller, 'SpecifiedLegalOrganization').text = company_data.get('siret', '')
        
        # Monetary summary
        monetary = SubElement(header_settlement, 'SpecifiedTradeSettlementMonetarySummation')
        SubElement(monetary, 'DuePaymentAmount').text = str(round(invoice_data['total_ttc'], 2))
        SubElement(monetary, 'TaxBasisTotalAmount').text = str(round(invoice_data['total_ht'], 2))
        SubElement(monetary, 'TaxTotalAmount').text = str(round(invoice_data['total_tva'], 2))
        SubElement(monetary, 'GrandTotalAmount').text = str(round(invoice_data['total_ttc'], 2))
        
        # Convert to string
        xml_str = tostring(root, encoding='utf-8').decode('utf-8')
        
        # Save XML to storage
        url = os.environ.get('SUPABASE_URL')
        key = os.environ.get('SUPABASE_KEY')
        supabase = create_client(url, key)
        
        filename = f"factur_x_{invoice_data['invoice_number']}.xml"
        
        supabase.storage.from_('documents').upload(
            path=filename,
            file=xml_str.encode('utf-8'),
            file_options={"content-type": "application/xml"},
        )
        
        xml_url = supabase.storage.from_('documents').get_public_url(filename)
        
        # Update invoice with XML URL
        supabase.from_('invoices').update({
            'xml_factur_x_url': xml_url,
            'is_electronic': True,
        }).eq('id', invoice_data['id']).execute()
        
        return {
            'success': True,
            'xml_url': xml_url,
            'xml_content': xml_str,
        }, 200
        
    except Exception as e:
        return {'error': str(e)}, 500
```

---

## ☁️ CLOUD FUNCTION 6: Scheduled Payment Reminders

**Function Name:** `payment_reminders`  
**Trigger:** Cloud Scheduler (daily at 9 AM)  
**Memory:** 256MB

```python
import functions_framework
from datetime import datetime, timedelta
import os
from supabase import create_client
import functions_framework

@functions_framework.cloud_event
def payment_reminders(cloud_event):
    """Send payment reminder emails for overdue invoices"""
    
    url = os.environ.get('SUPABASE_URL')
    key = os.environ.get('SUPABASE_KEY')
    supabase = create_client(url, key)
    
    today = datetime.utcnow().date()
    
    # Find invoices that are:
    # 1. Due within 3 days
    # 2. Not yet paid
    # 3. Not already reminded today
    
    response = supabase.from_('invoices').select('*').execute()
    
    for invoice in response.data:
        due_date = datetime.fromisoformat(invoice['due_date']).date()
        days_until_due = (due_date - today).days
        
        # Send reminder if due in 1-7 days
        if 1 <= days_until_due <= 7 and invoice['payment_status'] != 'paid':
            _send_reminder_email(supabase, invoice)


def _send_reminder_email(supabase, invoice):
    """Send reminder email for invoice"""
    
    import requests
    
    # Get client info
    client = supabase.from_('clients').select('*').eq('id', invoice['client_id']).single().execute()
    
    # Get company info
    company = supabase.from_('profiles').select('*').eq('id', invoice['user_id']).single().execute()
    
    context = {
        'client_name': client.data['name'],
        'invoice_number': invoice['invoice_number'],
        'amount': invoice['total_ttc'],
        'due_date': invoice['due_date'],
        'payment_link': f"https://plombipro.fr/pay/{invoice['id']}",
        'company_name': company.data['company_name'],
    }
    
    # Call sendgrid function
    requests.post(
        'https://YOUR_REGION-plombipro-prod.cloudfunctions.net/send_email_notification',
        json={
            'to': client.data['email'],
            'subject': f'Rappel: Facture {invoice["invoice_number"]} en attente de paiement',
            'template': 'payment_reminder',
            'context': context,
        }
    )
```

---

## 🚀 DEPLOYMENT COMMANDS

```bash
# Deploy OCR function
gcloud functions deploy ocr_process_invoice \
  --runtime python311 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point=ocr_process_invoice \
  --memory=512MB \
  --timeout=60s \
  --set-env-vars=SUPABASE_URL=https://YOUR_PROJECT.supabase.co,SUPABASE_KEY=YOUR_KEY

# Deploy Stripe function
gcloud functions deploy create_payment_intent \
  --runtime python311 \
  --trigger-http \
  --entry-point=create_payment_intent \
  --memory=256MB \
  --set-env-vars=STRIPE_SECRET_KEY=sk_live_YOUR_KEY,SUPABASE_URL=...,SUPABASE_KEY=...

# Deploy SendGrid function
gcloud functions deploy send_email_notification \
  --runtime python311 \
  --trigger-http \
  --entry-point=send_email_notification \
  --memory=256MB \
  --set-env-vars=SENDGRID_API_KEY=SG_YOUR_KEY

# Deploy Factur-X function
gcloud functions deploy generate_factur_x \
  --runtime python311 \
  --trigger-http \
  --entry-point=generate_factur_x \
  --memory=512MB \
  --set-env-vars=SUPABASE_URL=...,SUPABASE_KEY=...

# Deploy scheduled function
gcloud scheduler jobs create pubsub payment_reminders \
  --location=europe-west1 \
  --schedule="0 9 * * *" \
  --topic=payment_reminders_topic
```

---

**Ready for Part 3: Custom Flutter Functions & APIs!**