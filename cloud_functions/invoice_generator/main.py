import os
import io
import tempfile
import functions_framework
from flask import Request, jsonify
from datetime import datetime
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import cm, mm
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image, PageBreak
from reportlab.pdfgen import canvas
from reportlab.lib.enums import TA_LEFT, TA_RIGHT, TA_CENTER
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from supabase import create_client, Client
import requests
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Supabase client
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

class FrenchInvoicePDFGenerator:
    """
    Professional French invoice/quote PDF generator with legal compliance
    """

    def __init__(self, invoice_data):
        self.data = invoice_data
        self.buffer = io.BytesIO()
        self.width, self.height = A4
        self.styles = getSampleStyleSheet()

        # Define custom styles
        self.styles.add(ParagraphStyle(
            name='CompanyName',
            parent=self.styles['Heading1'],
            fontSize=16,
            textColor=colors.HexColor('#0066CC'),
            spaceAfter=2
        ))

        self.styles.add(ParagraphStyle(
            name='InvoiceTitle',
            parent=self.styles['Heading1'],
            fontSize=20,
            textColor=colors.HexColor('#0066CC'),
            alignment=TA_CENTER,
            spaceAfter=12
        ))

        self.styles.add(ParagraphStyle(
            name='Small',
            parent=self.styles['Normal'],
            fontSize=8,
            textColor=colors.grey
        ))

        self.styles.add(ParagraphStyle(
            name='Bold',
            parent=self.styles['Normal'],
            fontSize=10,
            fontName='Helvetica-Bold'
        ))

        self.styles.add(ParagraphStyle(
            name='Legal',
            parent=self.styles['Normal'],
            fontSize=7,
            textColor=colors.grey,
            alignment=TA_CENTER
        ))

    def format_currency(self, amount):
        """Format currency in French style"""
        if amount is None:
            return "0,00 €"
        return f"{amount:,.2f} €".replace(",", " ").replace(".", ",")

    def format_date(self, date_str):
        """Format date in French style (DD/MM/YYYY)"""
        if not date_str:
            return datetime.now().strftime("%d/%m/%Y")
        try:
            if isinstance(date_str, str):
                dt = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
            else:
                dt = date_str
            return dt.strftime("%d/%m/%Y")
        except:
            return date_str

    def download_logo(self, logo_url):
        """Download company logo from URL"""
        try:
            if not logo_url:
                return None
            response = requests.get(logo_url, timeout=10)
            if response.status_code == 200:
                temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.png')
                temp_file.write(response.content)
                temp_file.close()
                return temp_file.name
            return None
        except Exception as e:
            logger.warning(f"Could not download logo: {e}")
            return None

    def create_header(self, elements):
        """Create invoice header with company and client info"""
        # Company logo and info
        company = self.data.get('company', {})
        logo_url = company.get('logo_url')

        header_data = []

        # Row 1: Logo and Company Info | Invoice Title
        left_content = []

        if logo_url:
            logo_path = self.download_logo(logo_url)
            if logo_path:
                try:
                    img = Image(logo_path, width=3*cm, height=2*cm, kind='proportional')
                    left_content.append([img])
                except Exception as e:
                    logger.warning(f"Could not add logo: {e}")

        # Company details
        company_name = Paragraph(f"<b>{company.get('name', 'Nom de l\\'entreprise')}</b>", self.styles['CompanyName'])
        company_address = Paragraph(
            f"{company.get('address', '')}<br/>"
            f"{company.get('postal_code', '')} {company.get('city', '')}<br/>"
            f"Tél: {company.get('phone', '')}<br/>"
            f"Email: {company.get('email', '')}",
            self.styles['Normal']
        )

        left_content.append([company_name])
        left_content.append([company_address])

        # Invoice type and number
        doc_type = self.data.get('document_type', 'FACTURE')
        doc_number = self.data.get('invoice_number', 'FACT-0000')

        invoice_title = Paragraph(f"<b>{doc_type}</b><br/>N° {doc_number}", self.styles['InvoiceTitle'])

        header_table = Table([[left_content, invoice_title]], colWidths=[10*cm, 9*cm])
        header_table.setStyle(TableStyle([
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('ALIGN', (1, 0), (1, 0), 'RIGHT'),
        ]))

        elements.append(header_table)
        elements.append(Spacer(1, 0.5*cm))

        # Row 2: Client info and Invoice details
        client = self.data.get('client', {})
        client_info = Paragraph(
            f"<b>CLIENT</b><br/>"
            f"{client.get('name', 'Nom du client')}<br/>"
            f"{client.get('address', '')}<br/>"
            f"{client.get('postal_code', '')} {client.get('city', '')}<br/>"
            f"SIRET: {client.get('siret', 'N/A')}",
            self.styles['Normal']
        )

        invoice_details = Paragraph(
            f"<b>Date:</b> {self.format_date(self.data.get('invoice_date'))}<br/>"
            f"<b>Date d'échéance:</b> {self.format_date(self.data.get('due_date'))}<br/>"
            f"<b>Conditions de paiement:</b> {self.data.get('payment_terms', 'Net 30 jours')}",
            self.styles['Normal']
        )

        info_table = Table([[client_info, invoice_details]], colWidths=[10*cm, 9*cm])
        info_table.setStyle(TableStyle([
            ('BOX', (0, 0), (0, 0), 1, colors.grey),
            ('BOX', (1, 0), (1, 0), 1, colors.grey),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('LEFTPADDING', (0, 0), (-1, -1), 8),
            ('RIGHTPADDING', (0, 0), (-1, -1), 8),
            ('TOPPADDING', (0, 0), (-1, -1), 8),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ]))

        elements.append(info_table)
        elements.append(Spacer(1, 1*cm))

    def create_line_items_table(self, elements):
        """Create table with line items"""
        line_items = self.data.get('line_items', [])

        if not line_items:
            elements.append(Paragraph("Aucun article", self.styles['Normal']))
            return

        # Table headers
        table_data = [[
            Paragraph('<b>Désignation</b>', self.styles['Bold']),
            Paragraph('<b>Qté</b>', self.styles['Bold']),
            Paragraph('<b>P.U. HT</b>', self.styles['Bold']),
            Paragraph('<b>TVA</b>', self.styles['Bold']),
            Paragraph('<b>Total HT</b>', self.styles['Bold'])
        ]]

        # Add line items
        for item in line_items:
            description = item.get('description', '')
            quantity = item.get('quantity', 0)
            unit_price = item.get('unit_price_ht', 0)
            vat_rate = item.get('vat_rate', 20)
            line_total = quantity * unit_price

            table_data.append([
                Paragraph(description, self.styles['Normal']),
                str(quantity),
                self.format_currency(unit_price),
                f"{vat_rate}%",
                self.format_currency(line_total)
            ])

        # Create table
        line_items_table = Table(
            table_data,
            colWidths=[8*cm, 2*cm, 3*cm, 2*cm, 3.5*cm]
        )

        line_items_table.setStyle(TableStyle([
            # Header styling
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#0066CC')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 8),

            # Body styling
            ('ALIGN', (1, 1), (1, -1), 'CENTER'),  # Quantity
            ('ALIGN', (2, 1), (-1, -1), 'RIGHT'),   # Prices
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('FONTSIZE', (0, 1), (-1, -1), 9),
            ('LEFTPADDING', (0, 0), (-1, -1), 5),
            ('RIGHTPADDING', (0, 0), (-1, -1), 5),
            ('TOPPADDING', (0, 0), (-1, -1), 5),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 5),

            # Grid
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F5F5F5')]),
        ]))

        elements.append(line_items_table)
        elements.append(Spacer(1, 0.5*cm))

    def create_vat_breakdown(self, elements):
        """Create VAT breakdown table"""
        vat_breakdown = self.data.get('vat_breakdown', [])

        if not vat_breakdown:
            # Calculate from line items
            vat_dict = {}
            for item in self.data.get('line_items', []):
                vat_rate = item.get('vat_rate', 20)
                quantity = item.get('quantity', 0)
                unit_price = item.get('unit_price_ht', 0)
                line_total_ht = quantity * unit_price

                if vat_rate not in vat_dict:
                    vat_dict[vat_rate] = {'base': 0, 'vat': 0}

                vat_dict[vat_rate]['base'] += line_total_ht
                vat_dict[vat_rate]['vat'] += line_total_ht * (vat_rate / 100)

            vat_breakdown = [
                {'vat_rate': rate, 'base_amount': data['base'], 'vat_amount': data['vat']}
                for rate, data in vat_dict.items()
            ]

        if vat_breakdown:
            vat_data = [['<b>Taux TVA</b>', '<b>Base HT</b>', '<b>Montant TVA</b>']]

            for breakdown in vat_breakdown:
                vat_data.append([
                    f"{breakdown['vat_rate']}%",
                    self.format_currency(breakdown['base_amount']),
                    self.format_currency(breakdown['vat_amount'])
                ])

            vat_table = Table(vat_data, colWidths=[3*cm, 4*cm, 4*cm])
            vat_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#F5F5F5')),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
                ('FONTSIZE', (0, 0), (-1, -1), 9),
            ]))

            elements.append(Paragraph('<b>Détail de la TVA</b>', self.styles['Bold']))
            elements.append(Spacer(1, 0.3*cm))
            elements.append(vat_table)
            elements.append(Spacer(1, 0.5*cm))

    def create_totals(self, elements):
        """Create totals section"""
        subtotal_ht = self.data.get('subtotal_ht', 0)
        total_vat = self.data.get('total_vat', 0)
        total_ttc = self.data.get('total_ttc', 0)

        # Calculate if not provided
        if subtotal_ht == 0:
            for item in self.data.get('line_items', []):
                subtotal_ht += item.get('quantity', 0) * item.get('unit_price_ht', 0)

        if total_vat == 0:
            for item in self.data.get('line_items', []):
                line_total = item.get('quantity', 0) * item.get('unit_price_ht', 0)
                total_vat += line_total * (item.get('vat_rate', 20) / 100)

        if total_ttc == 0:
            total_ttc = subtotal_ht + total_vat

        totals_data = [
            ['Total HT', self.format_currency(subtotal_ht)],
            ['Total TVA', self.format_currency(total_vat)],
            ['', ''],  # Spacer
            ['<b>TOTAL TTC</b>', f'<b>{self.format_currency(total_ttc)}</b>']
        ]

        totals_table = Table(totals_data, colWidths=[5*cm, 4*cm])
        totals_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (-1, -1), 'RIGHT'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('LINEABOVE', (0, 3), (-1, 3), 2, colors.HexColor('#0066CC')),
            ('FONTNAME', (0, 3), (-1, 3), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 3), (-1, 3), 12),
            ('TEXTCOLOR', (0, 3), (-1, 3), colors.HexColor('#0066CC')),
            ('TOPPADDING', (0, 3), (-1, 3), 10),
        ]))

        # Align to right
        total_container = Table([[None, totals_table]], colWidths=[10*cm, 9*cm])

        elements.append(total_container)
        elements.append(Spacer(1, 1*cm))

    def create_payment_instructions(self, elements):
        """Create payment instructions section"""
        payment = self.data.get('payment_instructions', {})

        if not payment:
            return

        elements.append(Paragraph('<b>MODALITÉS DE PAIEMENT</b>', self.styles['Bold']))
        elements.append(Spacer(1, 0.3*cm))

        payment_text = f"<b>Mode de paiement:</b> {payment.get('method', 'Virement bancaire')}<br/>"

        if payment.get('iban'):
            payment_text += f"<b>IBAN:</b> {payment['iban']}<br/>"

        if payment.get('bic'):
            payment_text += f"<b>BIC:</b> {payment['bic']}<br/>"

        if payment.get('bank_name'):
            payment_text += f"<b>Banque:</b> {payment['bank_name']}<br/>"

        payment_para = Paragraph(payment_text, self.styles['Normal'])
        elements.append(payment_para)
        elements.append(Spacer(1, 0.5*cm))

    def create_footer(self, elements):
        """Create footer with legal mentions"""
        company = self.data.get('company', {})

        legal_mentions = []

        if company.get('siret'):
            legal_mentions.append(f"SIRET: {company['siret']}")

        if company.get('vat_number'):
            legal_mentions.append(f"N° TVA: {company['vat_number']}")

        if company.get('rcs'):
            legal_mentions.append(f"RCS: {company['rcs']}")

        if company.get('share_capital'):
            legal_mentions.append(f"Capital social: {self.format_currency(company['share_capital'])}")

        if company.get('insurance'):
            legal_mentions.append(f"Assurance: {company['insurance']}")

        # Add standard legal text
        legal_text = " | ".join(legal_mentions)
        legal_text += "<br/>En cas de retard de paiement, une pénalité de 3 fois le taux d'intérêt légal sera exigible."
        legal_text += "<br/>En cas de non-paiement à la date d'échéance, une indemnité forfaitaire de 40€ pour frais de recouvrement sera due."

        legal_para = Paragraph(legal_text, self.styles['Legal'])
        elements.append(Spacer(1, 1*cm))
        elements.append(legal_para)

    def generate(self):
        """Generate the complete PDF"""
        try:
            doc = SimpleDocTemplate(
                self.buffer,
                pagesize=A4,
                rightMargin=2*cm,
                leftMargin=2*cm,
                topMargin=2*cm,
                bottomMargin=2*cm
            )

            elements = []

            # Build PDF content
            self.create_header(elements)
            self.create_line_items_table(elements)
            self.create_vat_breakdown(elements)
            self.create_totals(elements)
            self.create_payment_instructions(elements)
            self.create_footer(elements)

            # Build PDF
            doc.build(elements)

            # Get PDF bytes
            pdf_bytes = self.buffer.getvalue()
            self.buffer.close()

            return pdf_bytes

        except Exception as e:
            logger.error(f"PDF generation error: {e}", exc_info=True)
            raise

@functions_framework.http
def invoice_generator(request: Request):
    """
    HTTP Cloud Function that generates a professional French invoice/quote PDF
    """
    if request.method == 'OPTIONS':
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

    try:
        request_json = request.get_json(silent=True)
        if not request_json:
            return jsonify({"error": "Invalid JSON payload"}), 400, headers

        invoice_data = request_json.get('invoice_data')
        if not invoice_data:
            return jsonify({"error": "Missing 'invoice_data' in payload"}), 400, headers

        # Generate PDF
        generator = FrenchInvoicePDFGenerator(invoice_data)
        pdf_bytes = generator.generate()

        # Upload to Supabase Storage
        user_id = invoice_data.get('user_id', 'anonymous')
        invoice_id = invoice_data.get('invoice_number', 'INV-0000').replace('/', '-')
        doc_type = invoice_data.get('document_type', 'FACTURE').lower()
        pdf_filename = f"{doc_type}_{invoice_id}.pdf"
        storage_path = f"{user_id}/{pdf_filename}"

        response = supabase.storage.from_('documents').upload(
            file=pdf_bytes,
            path=storage_path,
            file_options={"content-type": "application/pdf", "upsert": "true"}
        )

        if hasattr(response, 'error') and response.error:
            logger.error(f"Supabase upload error: {response.error}")
            return jsonify({"error": f"Storage upload failed: {response.error}"}), 500, headers

        # Get public URL
        public_url = supabase.storage.from_('documents').get_public_url(storage_path)

        logger.info(f"PDF generated successfully: {pdf_filename}")

        return jsonify({
            "success": True,
            "message": "PDF generated and stored successfully",
            "invoice_url": public_url,
            "filename": pdf_filename
        }), 200, headers

    except Exception as e:
        logger.error(f"Invoice generation failed: {e}", exc_info=True)
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500, headers

