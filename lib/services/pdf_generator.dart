import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// For loading fonts
import 'dart:typed_data'; // For Uint8List

class PdfGenerator {
  /// Generate quote PDF
  static Future<Uint8List> generateQuotePdf({
    required String quoteNumber,
    // Add other parameters as needed for the PDF content
    required String clientName,
    required double totalTtc,
  }) async {
    final pdf = pw.Document();

    // Load a font that supports French characters if needed
    // final fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    // final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Devis N°: $quoteNumber', style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 20),
                pw.Text('Client: $clientName', style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 10),
                pw.Text('Montant Total TTC: ${totalTtc.toStringAsFixed(2)}€', style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 30),
                pw.Text('Ceci est un aperçu de votre devis.', style: pw.TextStyle(fontSize: 12)),
                // Add more detailed PDF layout logic here
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
