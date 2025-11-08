import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { create } from 'https://esm.sh/xmlbuilder2@3.0.2'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4'
import { corsHeaders } from '../_shared/cors.ts'

// Initialize Supabase client with service role key for admin access
const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SPB_SERVICE_ROLE_KEY')!
)

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { invoice: invoiceData, company: companyData } = await req.json()

    if (!invoiceData || !companyData) {
      throw new Error('Missing invoice or company data in request.')
    }

    // Basic validation for critical fields
    if (!invoiceData.id || !invoiceData.number || !invoiceData.date || !invoiceData.client_name || !invoiceData.total_ttc || !invoiceData.total_ht || !invoiceData.total_tva || !invoiceData.items) {
      throw new Error('Incomplete invoice data provided.')
    }
    if (!companyData.company_name) {
      throw new Error('Incomplete company data provided.')
    }

    // Construct Factur-X XML using xmlbuilder2
    const root = create({ version: '1.0', encoding: 'UTF-8' })
      .ele('rsm:CrossIndustryInvoice', {
        'xmlns:rsm': 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100',
        'xmlns:ram': 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100',
        'xmlns:udt': 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100',
        'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
      })
      .ele('rsm:ExchangedDocumentContext')
        .ele('ram:GuidelineSpecifiedDocumentContextParameter')
          .ele('ram:ID').txt('urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:extended').up()
        .up()
      .up()
      .ele('rsm:ExchangedDocument')
        .ele('ram:ID').txt(invoiceData.number).up()
        .ele('ram:TypeCode').txt('380').up() // Commercial invoice
        .ele('ram:IssueDateTime')
          .ele('udt:DateTimeString', { format: '102' })
          .txt(invoiceData.date.replace(/-/g, '')) // YYYYMMDD
        .up()
      .up()
      .ele('rsm:SupplyChainTradeTransaction')
        // Line items
        .each(invoiceData.items, (item: any, idx: number) => {
          const lineItem = root.ele('ram:IncludedSupplyChainTradeLineItem')
          lineItem.ele('ram:AssociatedDocument').ele('ram:LineID').txt((idx + 1).toString())
          lineItem.ele('ram:SpecifiedTradeProduct').ele('ram:Name').txt(item.description)
          lineItem.ele('ram:SpecifiedLineTradeAgreement')
            .ele('ram:NetPriceProductTradePrice')
              .ele('ram:ChargeAmount').txt(item.unit_price.toFixed(2))
            .up()
          .up()
          lineItem.ele('ram:SpecifiedLineTradeSettlement')
            .ele('ram:ApplicableTradeTax')
              .ele('ram:TypeCode').txt('VAT').up()
              .ele('ram:CategoryCode').txt('S').up() // Standard rate
              .ele('ram:RateApplicablePercent').txt(item.tax_rate ? item.tax_rate.toFixed(2) : '20.00')
            .up()
            .ele('ram:SpecifiedTradeSettlementMonetarySummation')
              .ele('ram:LineTotalAmount').txt((item.quantity * item.unit_price).toFixed(2))
            .up()
          .up()
        })
        // Header Trade Settlement (Totals)
        .ele('ram:ApplicableHeaderTradeSettlement')
          .ele('ram:InvoiceCurrencyCode').txt('EUR').up()
          .ele('ram:BuyerTradeParty')
            .ele('ram:Name').txt(invoiceData.client_name).up()
          .up()
          .ele('ram:SellerTradeParty')
            .ele('ram:Name').txt(companyData.company_name).up()
            .ele('ram:SpecifiedLegalOrganization').ele('ram:ID').txt(companyData.siret || '').up().up()
          .up()
          .ele('ram:SpecifiedTradeSettlementHeaderMonetarySummation')
            .ele('ram:LineTotalAmount').txt(invoiceData.total_ht.toFixed(2)).up()
            .ele('ram:TaxBasisTotalAmount').txt(invoiceData.total_ht.toFixed(2)).up()
            .ele('ram:TaxTotalAmount', { currencyID: 'EUR' }).txt(invoiceData.total_tva.toFixed(2)).up()
            .ele('ram:GrandTotalAmount').txt(invoiceData.total_ttc.toFixed(2)).up()
            .ele('ram:DuePaymentAmount').txt(invoiceData.total_ttc.toFixed(2)).up()
          .up()
        .up()
      .up()

    const xmlString = root.end({ prettyPrint: true });

    // Upload the XML file to Supabase Storage
    const filePath = `factur-x/${invoiceData.number}.xml`;
    const { data, error } = await supabaseAdmin.storage
      .from('documents') // Assuming 'documents' bucket
      .upload(filePath, xmlString, {
        contentType: 'application/xml;charset=utf-8',
        upsert: true, // Overwrite if exists
      });

    if (error) {
      throw error;
    }

    const { data: publicUrlData } = supabaseAdmin.storage.from('documents').getPublicUrl(filePath);
    const xmlUrl = publicUrlData.publicUrl;

    // Update invoice with XML URL
    const { error: updateInvoiceError } = await supabaseAdmin
      .from('invoices')
      .update({ xml_url: xmlUrl, is_electronic: true })
      .eq('id', invoiceData.id);

    if (updateInvoiceError) {
      throw new Error(`Failed to update invoice with XML URL: ${updateInvoiceError.message}`);
    }

    return new Response(
      JSON.stringify({ success: true, xml_url: xmlUrl, xml_content: xmlString }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})