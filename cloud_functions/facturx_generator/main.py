import functions_framework
from supabase import create_client, Client
import os
from datetime import datetime
from facturx import generate_facturx_from_file
from lxml import etree
import tempfile
import io

# Initialize Supabase client
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)


class FacturXGenerator:
    """Generate Factur-X compliant XML for French invoices"""

    @staticmethod
    def generate_en16931_xml(invoice_data: dict, seller_info: dict, buyer_info: dict) -> bytes:
        """
        Generate EN16931 (BASIC level) compliant XML
        Reference: https://www.en16931-3-reader.de/
        """

        # Namespaces for EN16931
        nsmap = {
            'rsm': 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100',
            'qdt': 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100',
            'udt': 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100',
            'ram': 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100',
        }

        # Root element
        root = etree.Element(
            '{urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100}CrossIndustryInvoice',
            nsmap=nsmap
        )

        # Exchange Context
        exchange_context = etree.SubElement(root, '{%s}ExchangedDocumentContext' % nsmap['rsm'])
        guideline_context = etree.SubElement(exchange_context, '{%s}GuidelineSpecifiedDocumentContextParameter' % nsmap['ram'])
        guideline_id = etree.SubElement(guideline_context, '{%s}ID' % nsmap['ram'])
        guideline_id.text = 'urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic'

        # Exchanged Document (Invoice Header)
        exchanged_doc = etree.SubElement(root, '{%s}ExchangedDocument' % nsmap['rsm'])

        doc_id = etree.SubElement(exchanged_doc, '{%s}ID' % nsmap['ram'])
        doc_id.text = invoice_data.get('invoice_number', '')

        doc_type = etree.SubElement(exchanged_doc, '{%s}TypeCode' % nsmap['ram'])
        doc_type.text = '380'  # Commercial invoice

        doc_issue_date = etree.SubElement(exchanged_doc, '{%s}IssueDateTime' % nsmap['ram'])
        issue_date = etree.SubElement(doc_issue_date, '{%s}DateTimeString' % nsmap['udt'], format='102')
        invoice_date = invoice_data.get('invoice_date', datetime.now().strftime('%Y-%m-%d'))
        issue_date.text = invoice_date.replace('-', '')  # YYYYMMDD format

        # Supply Chain Trade Transaction
        transaction = etree.SubElement(root, '{%s}SupplyChainTradeTransaction' % nsmap['rsm'])

        # Line items
        line_items = invoice_data.get('line_items', [])
        for idx, item in enumerate(line_items, 1):
            line_item = etree.SubElement(transaction, '{%s}IncludedSupplyChainTradeLineItem' % nsmap['ram'])

            # Line ID
            line_doc = etree.SubElement(line_item, '{%s}AssociatedDocumentLineDocument' % nsmap['ram'])
            line_id = etree.SubElement(line_doc, '{%s}LineID' % nsmap['ram'])
            line_id.text = str(idx)

            # Product description
            product = etree.SubElement(line_item, '{%s}SpecifiedTradeProduct' % nsmap['ram'])
            product_name = etree.SubElement(product, '{%s}Name' % nsmap['ram'])
            product_name.text = item.get('description', '')

            # Line settlement
            line_settlement = etree.SubElement(line_item, '{%s}SpecifiedLineTradeSettlement' % nsmap['ram'])

            # VAT
            line_vat = etree.SubElement(line_settlement, '{%s}ApplicableTradeTax' % nsmap['ram'])
            vat_type = etree.SubElement(line_vat, '{%s}TypeCode' % nsmap['ram'])
            vat_type.text = 'VAT'
            vat_category = etree.SubElement(line_vat, '{%s}CategoryCode' % nsmap['ram'])
            vat_category.text = 'S'  # Standard rate
            vat_percent = etree.SubElement(line_vat, '{%s}RateApplicablePercent' % nsmap['ram'])
            vat_percent.text = str(item.get('vat_rate', 20.0))

            # Line monetary summation
            line_summation = etree.SubElement(line_settlement, '{%s}SpecifiedTradeSettlementLineMonetarySummation' % nsmap['ram'])
            line_total = etree.SubElement(line_summation, '{%s}LineTotalAmount' % nsmap['ram'])
            line_total.text = f"{item.get('line_total', 0):.2f}"

            # Line delivery
            line_delivery = etree.SubElement(line_item, '{%s}SpecifiedLineTradeDelivery' % nsmap['ram'])
            billed_qty = etree.SubElement(line_delivery, '{%s}BilledQuantity' % nsmap['ram'], unitCode='C62')
            billed_qty.text = str(item.get('quantity', 1))

            # Line pricing
            line_agreement = etree.SubElement(line_item, '{%s}SpecifiedLineTradeAgreement' % nsmap['ram'])
            net_price = etree.SubElement(line_agreement, '{%s}NetPriceProductTradePrice' % nsmap['ram'])
            charge_amount = etree.SubElement(net_price, '{%s}ChargeAmount' % nsmap['ram'])
            charge_amount.text = f"{item.get('unit_price', 0):.2f}"

        # Trade Agreement (Seller & Buyer)
        agreement = etree.SubElement(transaction, '{%s}ApplicableHeaderTradeAgreement' % nsmap['ram'])

        # Seller
        seller_party = etree.SubElement(agreement, '{%s}SellerTradeParty' % nsmap['ram'])
        seller_name_elem = etree.SubElement(seller_party, '{%s}Name' % nsmap['ram'])
        seller_name_elem.text = seller_info.get('company_name', '')

        if seller_info.get('siret'):
            seller_id = etree.SubElement(seller_party, '{%s}ID' % nsmap['ram'])
            seller_id.text = seller_info['siret']

        seller_address = etree.SubElement(seller_party, '{%s}PostalTradeAddress' % nsmap['ram'])
        seller_address_line = etree.SubElement(seller_address, '{%s}LineOne' % nsmap['ram'])
        seller_address_line.text = seller_info.get('address', '')
        seller_city = etree.SubElement(seller_address, '{%s}CityName' % nsmap['ram'])
        seller_city.text = seller_info.get('city', '')
        seller_postal = etree.SubElement(seller_address, '{%s}PostcodeCode' % nsmap['ram'])
        seller_postal.text = seller_info.get('postal_code', '')
        seller_country = etree.SubElement(seller_address, '{%s}CountryID' % nsmap['ram'])
        seller_country.text = 'FR'

        # Seller VAT ID
        if seller_info.get('vat_number'):
            seller_vat = etree.SubElement(seller_party, '{%s}SpecifiedTaxRegistration' % nsmap['ram'])
            seller_vat_id = etree.SubElement(seller_vat, '{%s}ID' % nsmap['ram'], schemeID='VA')
            seller_vat_id.text = seller_info['vat_number']

        # Buyer
        buyer_party = etree.SubElement(agreement, '{%s}BuyerTradeParty' % nsmap['ram'])
        buyer_name_elem = etree.SubElement(buyer_party, '{%s}Name' % nsmap['ram'])
        buyer_name_elem.text = buyer_info.get('name', '')

        buyer_address = etree.SubElement(buyer_party, '{%s}PostalTradeAddress' % nsmap['ram'])
        buyer_address_line = etree.SubElement(buyer_address, '{%s}LineOne' % nsmap['ram'])
        buyer_address_line.text = buyer_info.get('address', '')
        buyer_city = etree.SubElement(buyer_address, '{%s}CityName' % nsmap['ram'])
        buyer_city.text = buyer_info.get('city', '')
        buyer_postal = etree.SubElement(buyer_address, '{%s}PostcodeCode' % nsmap['ram'])
        buyer_postal.text = buyer_info.get('postal_code', '')
        buyer_country = etree.SubElement(buyer_address, '{%s}CountryID' % nsmap['ram'])
        buyer_country.text = 'FR'

        # Trade Delivery
        delivery = etree.SubElement(transaction, '{%s}ApplicableHeaderTradeDelivery' % nsmap['ram'])

        # Trade Settlement (Payment terms, totals)
        settlement = etree.SubElement(transaction, '{%s}ApplicableHeaderTradeSettlement' % nsmap['ram'])

        # Currency
        currency = etree.SubElement(settlement, '{%s}InvoiceCurrencyCode' % nsmap['ram'])
        currency.text = 'EUR'

        # Payment means
        payment_means = etree.SubElement(settlement, '{%s}SpecifiedTradeSettlementPaymentMeans' % nsmap['ram'])
        payment_type = etree.SubElement(payment_means, '{%s}TypeCode' % nsmap['ram'])
        payment_type.text = '30'  # Credit transfer

        # Payment terms
        payment_terms = invoice_data.get('payment_terms', '30')
        payment_terms_elem = etree.SubElement(settlement, '{%s}SpecifiedTradePaymentTerms' % nsmap['ram'])
        payment_desc = etree.SubElement(payment_terms_elem, '{%s}Description' % nsmap['ram'])
        payment_desc.text = f'Paiement à {payment_terms} jours'

        # Due date
        if invoice_data.get('due_date'):
            payment_due = etree.SubElement(payment_terms_elem, '{%s}DueDateDateTime' % nsmap['ram'])
            due_date_str = etree.SubElement(payment_due, '{%s}DateTimeString' % nsmap['udt'], format='102')
            due_date_str.text = invoice_data['due_date'].replace('-', '')

        # VAT breakdown
        tax_total = etree.SubElement(settlement, '{%s}ApplicableTradeTax' % nsmap['ram'])
        tax_amount = etree.SubElement(tax_total, '{%s}CalculatedAmount' % nsmap['ram'])
        tax_amount.text = f"{invoice_data.get('total_vat', 0):.2f}"
        tax_type = etree.SubElement(tax_total, '{%s}TypeCode' % nsmap['ram'])
        tax_type.text = 'VAT'
        tax_basis = etree.SubElement(tax_total, '{%s}BasisAmount' % nsmap['ram'])
        tax_basis.text = f"{invoice_data.get('subtotal_ht', 0):.2f}"
        tax_category = etree.SubElement(tax_total, '{%s}CategoryCode' % nsmap['ram'])
        tax_category.text = 'S'
        tax_percent = etree.SubElement(tax_total, '{%s}RateApplicablePercent' % nsmap['ram'])
        tax_percent.text = '20.0'

        # Monetary summation
        monetary_summation = etree.SubElement(settlement, '{%s}SpecifiedTradeSettlementHeaderMonetarySummation' % nsmap['ram'])

        line_total_amount = etree.SubElement(monetary_summation, '{%s}LineTotalAmount' % nsmap['ram'])
        line_total_amount.text = f"{invoice_data.get('subtotal_ht', 0):.2f}"

        tax_basis_total = etree.SubElement(monetary_summation, '{%s}TaxBasisTotalAmount' % nsmap['ram'])
        tax_basis_total.text = f"{invoice_data.get('subtotal_ht', 0):.2f}"

        tax_total_amount = etree.SubElement(monetary_summation, '{%s}TaxTotalAmount' % nsmap['ram'], currencyID='EUR')
        tax_total_amount.text = f"{invoice_data.get('total_vat', 0):.2f}"

        grand_total = etree.SubElement(monetary_summation, '{%s}GrandTotalAmount' % nsmap['ram'])
        grand_total.text = f"{invoice_data.get('total_ttc', 0):.2f}"

        due_payable = etree.SubElement(monetary_summation, '{%s}DuePayableAmount' % nsmap['ram'])
        due_payable.text = f"{invoice_data.get('balance_due', invoice_data.get('total_ttc', 0)):.2f}"

        # Generate XML bytes
        xml_bytes = etree.tostring(
            root,
            pretty_print=True,
            xml_declaration=True,
            encoding='UTF-8'
        )

        return xml_bytes


@functions_framework.http
def generate_facturx(request):
    """Generate Factur-X compliant invoice PDF with embedded XML"""
    request_json = request.get_json(silent=True)
    invoice_id = request_json.get('invoice_id')

    if not invoice_id:
        return {'success': False, 'error': 'Missing invoice_id'}, 400

    try:
        # 1. Fetch invoice data from Supabase
        invoice_response = supabase.table('invoices').select('*, clients(*)').eq('id', invoice_id).single().execute()
        if not invoice_response.data:
            raise Exception('Invoice not found.')
        invoice_data = invoice_response.data

        # 2. Fetch seller (user profile) info
        user_id = invoice_data.get('user_id')
        profile_response = supabase.table('profiles').select('*').eq('id', user_id).single().execute()
        if not profile_response.data:
            raise Exception('User profile not found.')
        seller_info = profile_response.data

        # 3. Get buyer info
        buyer_info = invoice_data.get('clients', {})

        # 4. Parse line items
        line_items = invoice_data.get('line_items', [])
        if isinstance(line_items, str):
            import json
            line_items = json.loads(line_items)

        invoice_data_dict = {
            'invoice_number': invoice_data.get('invoice_number'),
            'invoice_date': invoice_data.get('invoice_date', datetime.now().strftime('%Y-%m-%d')),
            'due_date': invoice_data.get('due_date'),
            'payment_terms': invoice_data.get('payment_terms', '30'),
            'subtotal_ht': invoice_data.get('subtotal_ht', 0),
            'total_vat': invoice_data.get('total_vat', 0),
            'total_ttc': invoice_data.get('total_ttc', 0),
            'balance_due': invoice_data.get('balance_due', invoice_data.get('total_ttc', 0)),
            'line_items': line_items,
        }

        # 5. Generate EN16931 XML
        generator = FacturXGenerator()
        xml_bytes = generator.generate_en16931_xml(invoice_data_dict, seller_info, buyer_info)

        # 6. Get existing PDF or generate one
        existing_pdf_url = invoice_data.get('pdf_url')
        if not existing_pdf_url:
            raise Exception('Invoice PDF must be generated before creating Factur-X')

        # Download existing PDF
        pdf_response = supabase.storage.from_('invoices').download(f"{invoice_id}.pdf")
        pdf_bytes = pdf_response

        # 7. Embed XML into PDF using factur-x library
        with tempfile.NamedTemporaryFile(suffix='.pdf', delete=False) as pdf_temp:
            pdf_temp.write(pdf_bytes)
            pdf_temp_path = pdf_temp.name

        with tempfile.NamedTemporaryFile(suffix='.xml', delete=False) as xml_temp:
            xml_temp.write(xml_bytes)
            xml_temp_path = xml_temp.name

        # Generate Factur-X PDF
        facturx_pdf_path = f"/tmp/facturx_{invoice_id}.pdf"
        generate_facturx_from_file(
            pdf_temp_path,
            xml_temp_path,
            facturx_level='basic',
            output_pdf_file=facturx_pdf_path
        )

        # 8. Upload Factur-X PDF and XML to storage
        with open(facturx_pdf_path, 'rb') as f:
            supabase.storage.from_('invoices').upload(
                f"facturx_{invoice_id}.pdf",
                f,
                file_options={"upsert": "true"}
            )

        with open(xml_temp_path, 'rb') as f:
            supabase.storage.from_('invoices').upload(
                f"facturx_{invoice_id}.xml",
                f,
                file_options={"upsert": "true"}
            )

        # 9. Update invoice with Factur-X URLs
        facturx_pdf_url = supabase.storage.from_('invoices').get_public_url(f"facturx_{invoice_id}.pdf")
        facturx_xml_url = supabase.storage.from_('invoices').get_public_url(f"facturx_{invoice_id}.xml")

        supabase.table('invoices').update({
            'pdf_url': facturx_pdf_url,
            'facturx_xml_url': facturx_xml_url,
            'is_electronic_invoice': True,
        }).eq('id', invoice_id).execute()

        # Cleanup temp files
        os.unlink(pdf_temp_path)
        os.unlink(xml_temp_path)
        os.unlink(facturx_pdf_path)

        return {
            'success': True,
            'pdf_url': facturx_pdf_url,
            'xml_url': facturx_xml_url,
            'facturx_level': 'basic'
        }, 200

    except Exception as e:
        return {'success': False, 'error': str(e)}, 500
