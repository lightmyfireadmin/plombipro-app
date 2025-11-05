import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Professional PDF generator service for invoices and quotes
///
/// This service provides two modes:
/// 1. Client-side generation (simple PDFs, for previews)
/// 2. Server-side generation (professional PDFs with cloud function)
class PdfGenerator {
  /// Generate quote PDF with line items
  static Future<Uint8List> generateQuotePdf({
    required String quoteNumber,
    required String clientName,
    required double totalTtc,
    String? companyName,
    String? companyAddress,
    List<Map<String, dynamic>>? lineItems,
    String? notes,
    double? subtotalHt,
    double? totalVat,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(companyName ?? 'PlombiPro',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    if (companyAddress != null)
                      pw.Text(companyAddress, style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('DEVIS',
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                    pw.Text(quoteNumber, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Client info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Client:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text(clientName, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Line items table
            if (lineItems != null && lineItems.isNotEmpty) ...[
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Description', isHeader: true),
                      _buildTableCell('Qté', isHeader: true, align: pw.TextAlign.center),
                      _buildTableCell('P.U. HT', isHeader: true, align: pw.TextAlign.right),
                      _buildTableCell('Total HT', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Items
                  ...lineItems.map((item) {
                    final quantity = item['quantity']?.toDouble() ?? 1.0;
                    final unitPrice = item['unit_price']?.toDouble() ?? 0.0;
                    final total = quantity * unitPrice;
                    return pw.TableRow(
                      children: [
                        _buildTableCell(item['description'] ?? ''),
                        _buildTableCell(quantity.toStringAsFixed(0), align: pw.TextAlign.center),
                        _buildTableCell('${unitPrice.toStringAsFixed(2)} €', align: pw.TextAlign.right),
                        _buildTableCell('${total.toStringAsFixed(2)} €', align: pw.TextAlign.right),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    children: [
                      if (subtotalHt != null) ...[
                        _buildTotalRow('Sous-total HT', '${subtotalHt.toStringAsFixed(2)} €'),
                        pw.SizedBox(height: 5),
                      ],
                      if (totalVat != null) ...[
                        _buildTotalRow('TVA', '${totalVat.toStringAsFixed(2)} €'),
                        pw.SizedBox(height: 5),
                      ],
                      pw.Divider(thickness: 2),
                      pw.SizedBox(height: 5),
                      _buildTotalRow('Total TTC', '${totalTtc.toStringAsFixed(2)} €', isBold: true),
                    ],
                  ),
                ),
              ],
            ),

            // Notes
            if (notes != null && notes.isNotEmpty) ...[
              pw.SizedBox(height: 30),
              pw.Text('Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text(notes, style: const pw.TextStyle(fontSize: 9)),
            ],

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Text('Document généré par PlombiPro',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Generate invoice PDF with line items
  static Future<Uint8List> generateInvoicePdf({
    required String invoiceNumber,
    required String clientName,
    required double totalTtc,
    String? companyName,
    String? companyAddress,
    String? iban,
    String? bic,
    List<Map<String, dynamic>>? lineItems,
    String? notes,
    String? legalMentions,
    double? subtotalHt,
    double? totalVat,
    String? dueDate,
    String? paymentMethod,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(companyName ?? 'PlombiPro',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    if (companyAddress != null)
                      pw.Text(companyAddress, style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('FACTURE',
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                    pw.Text(invoiceNumber, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    if (dueDate != null) ...[
                      pw.SizedBox(height: 5),
                      pw.Text('Échéance: $dueDate', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Client info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Facturé à:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text(clientName, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Line items table
            if (lineItems != null && lineItems.isNotEmpty) ...[
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Description', isHeader: true),
                      _buildTableCell('Qté', isHeader: true, align: pw.TextAlign.center),
                      _buildTableCell('P.U. HT', isHeader: true, align: pw.TextAlign.right),
                      _buildTableCell('Total HT', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Items
                  ...lineItems.map((item) {
                    final quantity = item['quantity']?.toDouble() ?? 1.0;
                    final unitPrice = item['unit_price']?.toDouble() ?? 0.0;
                    final total = quantity * unitPrice;
                    return pw.TableRow(
                      children: [
                        _buildTableCell(item['description'] ?? ''),
                        _buildTableCell(quantity.toStringAsFixed(0), align: pw.TextAlign.center),
                        _buildTableCell('${unitPrice.toStringAsFixed(2)} €', align: pw.TextAlign.right),
                        _buildTableCell('${total.toStringAsFixed(2)} €', align: pw.TextAlign.right),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    children: [
                      if (subtotalHt != null) ...[
                        _buildTotalRow('Sous-total HT', '${subtotalHt.toStringAsFixed(2)} €'),
                        pw.SizedBox(height: 5),
                      ],
                      if (totalVat != null) ...[
                        _buildTotalRow('TVA', '${totalVat.toStringAsFixed(2)} €'),
                        pw.SizedBox(height: 5),
                      ],
                      pw.Divider(thickness: 2),
                      pw.SizedBox(height: 5),
                      _buildTotalRow('Total TTC', '${totalTtc.toStringAsFixed(2)} €', isBold: true, fontSize: 16),
                    ],
                  ),
                ),
              ],
            ),

            // Payment instructions
            if (iban != null || bic != null || paymentMethod != null) ...[
              pw.SizedBox(height: 30),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Modalités de paiement:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    if (paymentMethod != null)
                      pw.Text('Méthode: $paymentMethod', style: const pw.TextStyle(fontSize: 10)),
                    if (iban != null)
                      pw.Text('IBAN: $iban', style: const pw.TextStyle(fontSize: 10)),
                    if (bic != null)
                      pw.Text('BIC: $bic', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],

            // Notes
            if (notes != null && notes.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text('Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text(notes, style: const pw.TextStyle(fontSize: 9)),
            ],

            // Legal mentions
            if (legalMentions != null && legalMentions.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Text('Mentions légales:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
              pw.SizedBox(height: 5),
              pw.Text(legalMentions, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
            ],

            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.Text('Document généré par PlombiPro',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Helper widgets
  static pw.Widget _buildTableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, String value, {bool isBold = false, double fontSize = 12}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(value, style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }

  /// Generate professional PDF using cloud function
  ///
  /// This generates a full French-compliant invoice/quote with:
  /// - Company logo
  /// - Legal mentions (SIRET, RCS, VAT)
  /// - VAT breakdown by rate
  /// - Payment instructions (IBAN, BIC)
  /// - Professional layout
  ///
  /// Returns the URL of the generated PDF stored in Supabase Storage
  static Future<String> generateProfessionalPdf({
    required Map<String, dynamic> invoiceData,
    required String cloudFunctionUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'invoice_data': invoiceData}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          return result['invoice_url'];
        } else {
          throw Exception(result['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception(
            'PDF generation failed with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  /// Prepare invoice data for cloud function
  ///
  /// This helper method formats the data structure expected by the cloud function
  static Map<String, dynamic> prepareInvoiceData({
    required String userId,
    required String documentType, // 'FACTURE' or 'DEVIS'
    required String invoiceNumber,
    required String invoiceDate,
    required String dueDate,
    required String paymentTerms,
    required Map<String, dynamic> company,
    required Map<String, dynamic> client,
    required List<Map<String, dynamic>> lineItems,
    double? subtotalHt,
    double? totalVat,
    double? totalTtc,
    Map<String, dynamic>? paymentInstructions,
    List<Map<String, dynamic>>? vatBreakdown,
  }) {
    return {
      'user_id': userId,
      'document_type': documentType,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'due_date': dueDate,
      'payment_terms': paymentTerms,
      'company': company,
      'client': client,
      'line_items': lineItems,
      if (subtotalHt != null) 'subtotal_ht': subtotalHt,
      if (totalVat != null) 'total_vat': totalVat,
      if (totalTtc != null) 'total_ttc': totalTtc,
      if (paymentInstructions != null)
        'payment_instructions': paymentInstructions,
      if (vatBreakdown != null) 'vat_breakdown': vatBreakdown,
    };
  }

  /// Example usage:
  ///
  /// ```dart
  /// // For simple preview
  /// final pdfBytes = await PdfGenerator.generateQuotePdfSimple(
  ///   quoteNumber: 'DEV-2025-0001',
  ///   clientName: 'John Doe',
  ///   totalTtc: 1200.50,
  /// );
  ///
  /// // For professional PDF
  /// final invoiceData = PdfGenerator.prepareInvoiceData(
  ///   userId: 'user-123',
  ///   documentType: 'FACTURE',
  ///   invoiceNumber: 'FACT-2025-0001',
  ///   invoiceDate: '2025-11-05T10:00:00Z',
  ///   dueDate: '2025-12-05T10:00:00Z',
  ///   paymentTerms: 'Net 30 jours',
  ///   company: {
  ///     'name': 'Plomberie Dupont',
  ///     'address': '123 Rue de la Paix',
  ///     'postal_code': '75001',
  ///     'city': 'Paris',
  ///     'phone': '01 23 45 67 89',
  ///     'email': 'contact@plomberie-dupont.fr',
  ///     'siret': '123 456 789 00012',
  ///     'vat_number': 'FR12345678901',
  ///     'rcs': 'Paris B 123 456 789',
  ///     'logo_url': 'https://example.com/logo.png',
  ///   },
  ///   client: {
  ///     'name': 'John Doe',
  ///     'address': '456 Avenue Victor Hugo',
  ///     'postal_code': '75016',
  ///     'city': 'Paris',
  ///     'siret': '987 654 321 00012',
  ///   },
  ///   lineItems: [
  ///     {
  ///       'description': 'Réparation fuite',
  ///       'quantity': 1,
  ///       'unit_price_ht': 150.00,
  ///       'vat_rate': 20,
  ///     },
  ///     {
  ///       'description': 'Remplacement robinet',
  ///       'quantity': 2,
  ///       'unit_price_ht': 75.00,
  ///       'vat_rate': 20,
  ///     },
  ///   ],
  ///   paymentInstructions: {
  ///     'method': 'Virement bancaire',
  ///     'iban': 'FR76 1234 5678 9012 3456 7890 123',
  ///     'bic': 'BNPAFRPPXXX',
  ///     'bank_name': 'BNP Paribas',
  ///   },
  /// );
  ///
  /// final pdfUrl = await PdfGenerator.generateProfessionalPdf(
  ///   invoiceData: invoiceData,
  ///   cloudFunctionUrl: 'https://your-project.cloudfunctions.net/invoice_generator',
  /// );
  ///
  /// print('PDF available at: $pdfUrl');
  /// ```
}
