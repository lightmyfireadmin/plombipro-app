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
  /// Generate simple quote PDF (client-side, for quick previews)
  static Future<Uint8List> generateQuotePdfSimple({
    required String quoteNumber,
    required String clientName,
    required double totalTtc,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Devis N°: $quoteNumber',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Client: $clientName', style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 10),
                pw.Text('Montant Total TTC: ${totalTtc.toStringAsFixed(2)}€',
                    style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 30),
                pw.Text('Ceci est un aperçu simplifié de votre devis.',
                    style: pw.TextStyle(fontSize: 12)),
                pw.Text('Utilisez "Générer PDF complet" pour la version professionnelle.',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
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
