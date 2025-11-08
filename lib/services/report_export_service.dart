import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/profile.dart';

/// Service for exporting reports to PDF and Excel formats
///
/// Supports:
/// - P&L (Profit & Loss) reports
/// - TVA (VAT) reports
/// - Financial summaries
class ReportExportService {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

  /// Export P&L report to Excel
  static Future<String> exportPLToExcel({
    required Map<String, dynamic> reportData,
    required DateTimeRange dateRange,
    Profile? profile,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Compte de Résultat'];

    // Title
    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('D1'),
    );
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('Compte de Résultat (P&L)');
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Company info
    int row = 2;
    if (profile != null) {
      sheet.cell(CellIndex.indexByString('A$row')).value =
          TextCellValue(profile.companyName ?? 'Entreprise');
      row++;
      if (profile.siret != null) {
        sheet.cell(CellIndex.indexByString('A$row')).value =
            TextCellValue('SIRET: ${profile.siret}');
        row++;
      }
    }

    // Date range
    row++;
    sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(
      'Période: ${_dateFormat.format(dateRange.start)} - ${_dateFormat.format(dateRange.end)}',
    );
    row += 2;

    // Headers
    final headers = ['Libellé', 'Montant HT', 'TVA', 'Montant TTC'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByString('${_getColumnLetter(i)}$row'));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#D3D3D3'),
      );
    }
    row++;

    // Revenue section
    final revenue = reportData['revenue'] as Map<String, dynamic>;
    _addExcelRow(sheet, row++, 'PRODUITS D\'EXPLOITATION', null, null, null,
        bold: true);
    _addExcelRow(
      sheet,
      row++,
      'Chiffre d\'affaires',
      revenue['total_ht'],
      revenue['total_tva'],
      revenue['total_ttc'],
    );

    // Expenses section
    row++;
    final expenses = reportData['expenses'] as Map<String, dynamic>;
    _addExcelRow(sheet, row++, 'CHARGES D\'EXPLOITATION', null, null, null,
        bold: true);
    _addExcelRow(
      sheet,
      row++,
      'Achats de marchandises',
      expenses['purchases_ht'],
      expenses['purchases_tva'],
      expenses['purchases_ttc'],
    );
    _addExcelRow(
      sheet,
      row++,
      'Autres charges externes',
      expenses['other_expenses_ht'],
      expenses['other_expenses_tva'],
      expenses['other_expenses_ttc'],
    );

    // Total expenses
    row++;
    _addExcelRow(
      sheet,
      row++,
      'TOTAL CHARGES',
      expenses['total_ht'],
      expenses['total_tva'],
      expenses['total_ttc'],
      bold: true,
    );

    // Net result
    row++;
    final netResult = reportData['net_result'] as Map<String, dynamic>;
    _addExcelRow(
      sheet,
      row++,
      'RÉSULTAT NET',
      netResult['ht'],
      netResult['tva'],
      netResult['ttc'],
      bold: true,
      backgroundColor: netResult['ttc'] >= 0
          ? ExcelColor.fromHexString('#C6EFCE')
          : ExcelColor.fromHexString('#FFC7CE'),
    );

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/pl_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return filePath;
  }

  /// Export TVA report to Excel
  static Future<String> exportTVAToExcel({
    required Map<String, dynamic> reportData,
    required DateTimeRange dateRange,
    Profile? profile,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Déclaration TVA'];

    // Title
    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('D1'),
    );
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('Déclaration de TVA');
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Company info
    int row = 2;
    if (profile != null) {
      sheet.cell(CellIndex.indexByString('A$row')).value =
          TextCellValue(profile.companyName ?? 'Entreprise');
      row++;
      if (profile.siret != null) {
        sheet.cell(CellIndex.indexByString('A$row')).value =
            TextCellValue('SIRET: ${profile.siret}');
        row++;
      }
      if (profile.vatNumber != null) {
        sheet.cell(CellIndex.indexByString('A$row')).value =
            TextCellValue('N° TVA: ${profile.vatNumber}');
        row++;
      }
    }

    // Date range
    row++;
    sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(
      'Période: ${_dateFormat.format(dateRange.start)} - ${_dateFormat.format(dateRange.end)}',
    );
    row += 2;

    // TVA Collectée (collected from sales)
    _addExcelRow(sheet, row++, 'TVA COLLECTÉE', null, null, null, bold: true);
    final tvaCollected = reportData['tva_collected'] as Map<String, dynamic>;

    final collectedByRate = tvaCollected['by_rate'] as Map<String, dynamic>;
    for (final entry in collectedByRate.entries) {
      final rate = entry.key;
      final data = entry.value as Map<String, dynamic>;
      _addExcelRow(
        sheet,
        row++,
        'TVA à $rate',
        data['base_ht'],
        data['amount'],
        null,
      );
    }

    row++;
    _addExcelRow(
      sheet,
      row++,
      'TOTAL TVA COLLECTÉE',
      null,
      tvaCollected['total'],
      null,
      bold: true,
    );

    // TVA Déductible (deductible from purchases)
    row += 2;
    _addExcelRow(sheet, row++, 'TVA DÉDUCTIBLE', null, null, null, bold: true);
    final tvaDeductible = reportData['tva_deductible'] as Map<String, dynamic>;

    final deductibleByRate = tvaDeductible['by_rate'] as Map<String, dynamic>;
    for (final entry in deductibleByRate.entries) {
      final rate = entry.key;
      final data = entry.value as Map<String, dynamic>;
      _addExcelRow(
        sheet,
        row++,
        'TVA à $rate',
        data['base_ht'],
        data['amount'],
        null,
      );
    }

    row++;
    _addExcelRow(
      sheet,
      row++,
      'TOTAL TVA DÉDUCTIBLE',
      null,
      tvaDeductible['total'],
      null,
      bold: true,
    );

    // Net TVA to pay/recover
    row += 2;
    final netTva = reportData['net_tva'] as double;
    _addExcelRow(
      sheet,
      row++,
      netTva >= 0 ? 'TVA À PAYER' : 'CRÉDIT DE TVA',
      null,
      netTva.abs(),
      null,
      bold: true,
      backgroundColor: netTva >= 0
          ? ExcelColor.fromHexString('#FFC7CE')
          : ExcelColor.fromHexString('#C6EFCE'),
    );

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/tva_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return filePath;
  }

  /// Export P&L report to PDF
  static Future<String> exportPLToPDF({
    required Map<String, dynamic> reportData,
    required DateTimeRange dateRange,
    Profile? profile,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                'Compte de Résultat (P&L)',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Company info
              if (profile != null) ...[
                pw.Text(
                  profile.companyName ?? 'Entreprise',
                  style: pw.TextStyle(fontSize: 16),
                ),
                if (profile.siret != null)
                  pw.Text('SIRET: ${profile.siret}', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
              ],

              // Date range
              pw.Text(
                'Période: ${_dateFormat.format(dateRange.start)} - ${_dateFormat.format(dateRange.end)}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),

              // Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _pdfCell('Libellé', bold: true),
                      _pdfCell('Montant HT', bold: true),
                      _pdfCell('TVA', bold: true),
                      _pdfCell('Montant TTC', bold: true),
                    ],
                  ),

                  // Revenue
                  pw.TableRow(
                    children: [
                      _pdfCell('PRODUITS D\'EXPLOITATION', bold: true),
                      _pdfCell(''),
                      _pdfCell(''),
                      _pdfCell(''),
                    ],
                  ),
                  _buildPLTableRow(
                    'Chiffre d\'affaires',
                    reportData['revenue']['total_ht'],
                    reportData['revenue']['total_tva'],
                    reportData['revenue']['total_ttc'],
                  ),

                  // Expenses
                  pw.TableRow(
                    children: [
                      _pdfCell('CHARGES D\'EXPLOITATION', bold: true),
                      _pdfCell(''),
                      _pdfCell(''),
                      _pdfCell(''),
                    ],
                  ),
                  _buildPLTableRow(
                    'Achats de marchandises',
                    reportData['expenses']['purchases_ht'],
                    reportData['expenses']['purchases_tva'],
                    reportData['expenses']['purchases_ttc'],
                  ),
                  _buildPLTableRow(
                    'Autres charges externes',
                    reportData['expenses']['other_expenses_ht'],
                    reportData['expenses']['other_expenses_tva'],
                    reportData['expenses']['other_expenses_ttc'],
                  ),
                  _buildPLTableRow(
                    'TOTAL CHARGES',
                    reportData['expenses']['total_ht'],
                    reportData['expenses']['total_tva'],
                    reportData['expenses']['total_ttc'],
                    bold: true,
                  ),

                  // Net result
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: reportData['net_result']['ttc'] >= 0
                          ? PdfColors.green100
                          : PdfColors.red100,
                    ),
                    children: [
                      _pdfCell('RÉSULTAT NET', bold: true),
                      _pdfCell(_currencyFormat.format(reportData['net_result']['ht']),
                          bold: true),
                      _pdfCell(_currencyFormat.format(reportData['net_result']['tva']),
                          bold: true),
                      _pdfCell(_currencyFormat.format(reportData['net_result']['ttc']),
                          bold: true),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/pl_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Export TVA report to PDF
  static Future<String> exportTVAToPDF({
    required Map<String, dynamic> reportData,
    required DateTimeRange dateRange,
    Profile? profile,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final rows = <pw.TableRow>[];

          // Header
          rows.add(
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _pdfCell('Libellé', bold: true),
                _pdfCell('Base HT', bold: true),
                _pdfCell('Montant TVA', bold: true),
              ],
            ),
          );

          // TVA Collectée
          rows.add(
            pw.TableRow(
              children: [
                _pdfCell('TVA COLLECTÉE', bold: true),
                _pdfCell(''),
                _pdfCell(''),
              ],
            ),
          );

          final tvaCollected = reportData['tva_collected'] as Map<String, dynamic>;
          final collectedByRate = tvaCollected['by_rate'] as Map<String, dynamic>;
          for (final entry in collectedByRate.entries) {
            final rate = entry.key;
            final data = entry.value as Map<String, dynamic>;
            rows.add(_buildTVATableRow('TVA à $rate', data['base_ht'], data['amount']));
          }

          rows.add(
            _buildTVATableRow(
              'TOTAL TVA COLLECTÉE',
              null,
              tvaCollected['total'],
              bold: true,
            ),
          );

          // TVA Déductible
          rows.add(
            pw.TableRow(
              children: [
                _pdfCell('TVA DÉDUCTIBLE', bold: true),
                _pdfCell(''),
                _pdfCell(''),
              ],
            ),
          );

          final tvaDeductible = reportData['tva_deductible'] as Map<String, dynamic>;
          final deductibleByRate = tvaDeductible['by_rate'] as Map<String, dynamic>;
          for (final entry in deductibleByRate.entries) {
            final rate = entry.key;
            final data = entry.value as Map<String, dynamic>;
            rows.add(_buildTVATableRow('TVA à $rate', data['base_ht'], data['amount']));
          }

          rows.add(
            _buildTVATableRow(
              'TOTAL TVA DÉDUCTIBLE',
              null,
              tvaDeductible['total'],
              bold: true,
            ),
          );

          // Net TVA
          final netTva = reportData['net_tva'] as double;
          rows.add(
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: netTva >= 0 ? PdfColors.red100 : PdfColors.green100,
              ),
              children: [
                _pdfCell(netTva >= 0 ? 'TVA À PAYER' : 'CRÉDIT DE TVA', bold: true),
                _pdfCell(''),
                _pdfCell(_currencyFormat.format(netTva.abs()), bold: true),
              ],
            ),
          );

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Déclaration de TVA',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              if (profile != null) ...[
                pw.Text(profile.companyName ?? 'Entreprise',
                    style: pw.TextStyle(fontSize: 16)),
                if (profile.siret != null)
                  pw.Text('SIRET: ${profile.siret}', style: pw.TextStyle(fontSize: 12)),
                if (profile.vatNumber != null)
                  pw.Text('N° TVA: ${profile.vatNumber}',
                      style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
              ],
              pw.Text(
                'Période: ${_dateFormat.format(dateRange.start)} - ${_dateFormat.format(dateRange.end)}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Table(border: pw.TableBorder.all(), children: rows),
            ],
          );
        },
      ),
    );

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/tva_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Open exported file with default application
  static Future<void> openFile(String filePath) async {
    await OpenFilex.open(filePath);
  }

  // Helper methods
  static void _addExcelRow(
    Sheet sheet,
    int row,
    String label,
    double? amountHT,
    double? amountTVA,
    double? amountTTC, {
    bool bold = false,
    ExcelColor? backgroundColor,
  }) {
    final labelCell = sheet.cell(CellIndex.indexByString('A$row'));
    labelCell.value = TextCellValue(label);
    if (bold || backgroundColor != null) {
      labelCell.cellStyle = CellStyle(
        bold: bold,
        backgroundColorHex: backgroundColor ?? ExcelColor.fromHexString('#FFFFFF'),
      );
    }

    if (amountHT != null) {
      final cell = sheet.cell(CellIndex.indexByString('B$row'));
      cell.value = DoubleCellValue(amountHT);
      if (bold || backgroundColor != null) {
        cell.cellStyle = CellStyle(
          bold: bold,
          backgroundColorHex: backgroundColor ?? ExcelColor.fromHexString('#FFFFFF'),
        );
      }
    }

    if (amountTVA != null) {
      final cell = sheet.cell(CellIndex.indexByString('C$row'));
      cell.value = DoubleCellValue(amountTVA);
      if (bold || backgroundColor != null) {
        cell.cellStyle = CellStyle(
          bold: bold,
          backgroundColorHex: backgroundColor ?? ExcelColor.fromHexString('#FFFFFF'),
        );
      }
    }

    if (amountTTC != null) {
      final cell = sheet.cell(CellIndex.indexByString('D$row'));
      cell.value = DoubleCellValue(amountTTC);
      if (bold || backgroundColor != null) {
        cell.cellStyle = CellStyle(
          bold: bold,
          backgroundColorHex: backgroundColor ?? ExcelColor.fromHexString('#FFFFFF'),
        );
      }
    }
  }

  static String _getColumnLetter(int index) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return letters[index];
  }

  static pw.Widget _pdfCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.TableRow _buildPLTableRow(
    String label,
    double? amountHT,
    double? amountTVA,
    double? amountTTC, {
    bool bold = false,
  }) {
    return pw.TableRow(
      children: [
        _pdfCell(label, bold: bold),
        _pdfCell(amountHT != null ? _currencyFormat.format(amountHT) : '',
            bold: bold),
        _pdfCell(amountTVA != null ? _currencyFormat.format(amountTVA) : '',
            bold: bold),
        _pdfCell(amountTTC != null ? _currencyFormat.format(amountTTC) : '',
            bold: bold),
      ],
    );
  }

  static pw.TableRow _buildTVATableRow(
    String label,
    double? baseHT,
    double? amountTVA, {
    bool bold = false,
  }) {
    return pw.TableRow(
      children: [
        _pdfCell(label, bold: bold),
        _pdfCell(baseHT != null ? _currencyFormat.format(baseHT) : '', bold: bold),
        _pdfCell(amountTVA != null ? _currencyFormat.format(amountTVA) : '',
            bold: bold),
      ],
    );
  }
}
