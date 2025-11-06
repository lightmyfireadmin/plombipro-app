import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../services/error_service.dart';
import '../../services/report_export_service.dart';
import '../../services/supabase_service.dart';
import '../../services/invoice_calculator.dart';
import '../../models/profile.dart';

/// Advanced reporting page with P&L and TVA reports
///
/// Features:
/// - Date range picker
/// - Profit & Loss (P&L) report
/// - TVA (VAT) report
/// - Export to PDF and Excel
class AdvancedReportsPage extends StatefulWidget {
  const AdvancedReportsPage({super.key});

  @override
  State<AdvancedReportsPage> createState() => _AdvancedReportsPageState();
}

class _AdvancedReportsPageState extends State<AdvancedReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isExporting = false;

  // Date range
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  // Report data
  Map<String, dynamic>? _plReportData;
  Map<String, dynamic>? _tvaReportData;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await SupabaseService.fetchUserProfile();
      if (mounted) {
        setState(() => _profile = profile);
      }
    } catch (e) {
      ErrorService.handleError(context, e);
    }
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Load invoices for the period
      final invoicesResponse = await supabase
          .from('invoices')
          .select('*, invoice_items(*)')
          .eq('user_id', userId)
          .gte('invoice_date', _dateRange.start.toIso8601String())
          .lte('invoice_date', _dateRange.end.toIso8601String());

      final invoices = invoicesResponse as List<dynamic>;

      // Load purchases for the period
      final purchasesResponse = await supabase
          .from('purchases')
          .select('*')
          .eq('user_id', userId)
          .gte('purchase_date', _dateRange.start.toIso8601String())
          .lte('purchase_date', _dateRange.end.toIso8601String());

      final purchases = purchasesResponse as List<dynamic>;

      // Calculate P&L data
      _plReportData = _calculatePLReport(invoices, purchases);

      // Calculate TVA data
      _tvaReportData = _calculateTVAReport(invoices, purchases);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ErrorService.handleError(context, e);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, dynamic> _calculatePLReport(
      List<dynamic> invoices, List<dynamic> purchases) {
    // Calculate revenue
    double revenueHT = 0.0;
    double revenueTVA = 0.0;
    double revenueTTC = 0.0;

    for (final invoice in invoices) {
      revenueHT += (invoice['total_ht'] as num?)?.toDouble() ?? 0.0;
      revenueTTC += (invoice['total_ttc'] as num?)?.toDouble() ?? 0.0;
    }
    revenueTVA = revenueTTC - revenueHT;

    // Calculate expenses
    double purchasesHT = 0.0;
    double purchasesTVA = 0.0;
    double purchasesTTC = 0.0;

    for (final purchase in purchases) {
      purchasesHT += (purchase['amount_ht'] as num?)?.toDouble() ?? 0.0;
      purchasesTTC += (purchase['amount_ttc'] as num?)?.toDouble() ?? 0.0;
    }
    purchasesTVA = purchasesTTC - purchasesHT;

    // For simplicity, we're treating all purchases as direct purchases
    // In a real app, you might categorize expenses differently
    final totalExpensesHT = purchasesHT;
    final totalExpensesTVA = purchasesTVA;
    final totalExpensesTTC = purchasesTTC;

    // Calculate net result
    final netResultHT = revenueHT - totalExpensesHT;
    final netResultTVA = revenueTVA - totalExpensesTVA;
    final netResultTTC = revenueTTC - totalExpensesTTC;

    return {
      'revenue': {
        'total_ht': revenueHT,
        'total_tva': revenueTVA,
        'total_ttc': revenueTTC,
      },
      'expenses': {
        'purchases_ht': purchasesHT,
        'purchases_tva': purchasesTVA,
        'purchases_ttc': purchasesTTC,
        'other_expenses_ht': 0.0,
        'other_expenses_tva': 0.0,
        'other_expenses_ttc': 0.0,
        'total_ht': totalExpensesHT,
        'total_tva': totalExpensesTVA,
        'total_ttc': totalExpensesTTC,
      },
      'net_result': {
        'ht': netResultHT,
        'tva': netResultTVA,
        'ttc': netResultTTC,
      },
    };
  }

  Map<String, dynamic> _calculateTVAReport(
      List<dynamic> invoices, List<dynamic> purchases) {
    // TVA Collectée (from sales)
    Map<String, Map<String, double>> collectedByRate = {};
    double totalCollected = 0.0;

    for (final invoice in invoices) {
      final items = invoice['invoice_items'] as List<dynamic>? ?? [];
      for (final item in items) {
        final taxRate = (item['tax_rate'] as num?)?.toDouble() ?? 20.0;
        final quantity = (item['quantity'] as num?)?.toDouble() ?? 0.0;
        final unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0.0;
        final discount = (item['discount_percent'] as num?)?.toDouble() ?? 0.0;

        final baseHT = quantity * unitPrice * (1 - discount / 100);
        final tvaAmount = baseHT * (taxRate / 100);

        final rateKey = '${taxRate.toStringAsFixed(1)}%';
        collectedByRate[rateKey] ??= {'base_ht': 0.0, 'amount': 0.0};
        collectedByRate[rateKey]!['base_ht'] =
            (collectedByRate[rateKey]!['base_ht'] ?? 0.0) + baseHT;
        collectedByRate[rateKey]!['amount'] =
            (collectedByRate[rateKey]!['amount'] ?? 0.0) + tvaAmount;
        totalCollected += tvaAmount;
      }
    }

    // TVA Déductible (from purchases)
    Map<String, Map<String, double>> deductibleByRate = {};
    double totalDeductible = 0.0;

    for (final purchase in purchases) {
      final amountHT = (purchase['amount_ht'] as num?)?.toDouble() ?? 0.0;
      final amountTTC = (purchase['amount_ttc'] as num?)?.toDouble() ?? 0.0;
      final tvaAmount = amountTTC - amountHT;

      // Calculate tax rate
      final taxRate = amountHT > 0 ? (tvaAmount / amountHT) * 100 : 20.0;
      final rateKey = '${taxRate.toStringAsFixed(1)}%';

      deductibleByRate[rateKey] ??= {'base_ht': 0.0, 'amount': 0.0};
      deductibleByRate[rateKey]!['base_ht'] =
          (deductibleByRate[rateKey]!['base_ht'] ?? 0.0) + amountHT;
      deductibleByRate[rateKey]!['amount'] =
          (deductibleByRate[rateKey]!['amount'] ?? 0.0) + tvaAmount;
      totalDeductible += tvaAmount;
    }

    // Net TVA
    final netTva = totalCollected - totalDeductible;

    return {
      'tva_collected': {
        'by_rate': collectedByRate,
        'total': totalCollected,
      },
      'tva_deductible': {
        'by_rate': deductibleByRate,
        'total': totalDeductible,
      },
      'net_tva': netTva,
    };
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateRange) {
      setState(() => _dateRange = picked);
      await _loadReports();
    }
  }

  Future<void> _exportReport(String type, String format) async {
    setState(() => _isExporting = true);

    try {
      String filePath;

      if (type == 'pl') {
        if (_plReportData == null) {
          throw Exception('Aucune donnée de rapport P&L disponible');
        }

        if (format == 'pdf') {
          filePath = await ReportExportService.exportPLToPDF(
            reportData: _plReportData!,
            dateRange: _dateRange,
            profile: _profile,
          );
        } else {
          filePath = await ReportExportService.exportPLToExcel(
            reportData: _plReportData!,
            dateRange: _dateRange,
            profile: _profile,
          );
        }
      } else {
        // TVA
        if (_tvaReportData == null) {
          throw Exception('Aucune donnée de rapport TVA disponible');
        }

        if (format == 'pdf') {
          filePath = await ReportExportService.exportTVAToPDF(
            reportData: _tvaReportData!,
            dateRange: _dateRange,
            profile: _profile,
          );
        } else {
          filePath = await ReportExportService.exportTVAToExcel(
            reportData: _tvaReportData!,
            dateRange: _dateRange,
            profile: _profile,
          );
        }
      }

      if (mounted) {
        ErrorService.showSuccess(
          context,
          'Rapport exporté avec succès',
        );

        // Ask if user wants to open the file
        final open = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export réussi'),
            content: Text('Le rapport a été exporté.\n\nOuvrir le fichier ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Plus tard'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Ouvrir'),
              ),
            ],
          ),
        );

        if (open == true) {
          await ReportExportService.openFile(filePath);
        }
      }
    } catch (e) {
      ErrorService.handleError(context, e);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports Avancés'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Compte de Résultat', icon: Icon(Icons.account_balance)),
            Tab(text: 'TVA', icon: Icon(Icons.euro)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date range selector
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Période sélectionnée',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(_dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange.end)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range),
                  label: const Text('Modifier'),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPLReport(),
                      _buildTVAReport(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPLReport() {
    if (_plReportData == null) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    final revenue = _plReportData!['revenue'] as Map<String, dynamic>;
    final expenses = _plReportData!['expenses'] as Map<String, dynamic>;
    final netResult = _plReportData!['net_result'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isExporting
                      ? null
                      : () => _exportReport('pl', 'pdf'),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exporter PDF'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isExporting
                      ? null
                      : () => _exportReport('pl', 'excel'),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Exporter Excel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Revenue section
          _buildSectionHeader('PRODUITS D\'EXPLOITATION'),
          _buildReportRow(
            'Chiffre d\'affaires',
            revenue['total_ht'],
            revenue['total_tva'],
            revenue['total_ttc'],
          ),
          const Divider(),

          // Expenses section
          const SizedBox(height: 16),
          _buildSectionHeader('CHARGES D\'EXPLOITATION'),
          _buildReportRow(
            'Achats de marchandises',
            expenses['purchases_ht'],
            expenses['purchases_tva'],
            expenses['purchases_ttc'],
          ),
          _buildReportRow(
            'Autres charges externes',
            expenses['other_expenses_ht'],
            expenses['other_expenses_tva'],
            expenses['other_expenses_ttc'],
          ),
          const SizedBox(height: 8),
          _buildReportRow(
            'TOTAL CHARGES',
            expenses['total_ht'],
            expenses['total_tva'],
            expenses['total_ttc'],
            bold: true,
          ),
          const Divider(),

          // Net result
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: netResult['ttc'] >= 0
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: netResult['ttc'] >= 0
                    ? Colors.green.shade200
                    : Colors.red.shade200,
              ),
            ),
            child: Column(
              children: [
                _buildReportRow(
                  'RÉSULTAT NET',
                  netResult['ht'],
                  netResult['tva'],
                  netResult['ttc'],
                  bold: true,
                  showHeaders: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTVAReport() {
    if (_tvaReportData == null) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    final tvaCollected = _tvaReportData!['tva_collected'] as Map<String, dynamic>;
    final tvaDeductible = _tvaReportData!['tva_deductible'] as Map<String, dynamic>;
    final netTva = _tvaReportData!['net_tva'] as double;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isExporting
                      ? null
                      : () => _exportReport('tva', 'pdf'),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exporter PDF'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isExporting
                      ? null
                      : () => _exportReport('tva', 'excel'),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Exporter Excel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // TVA Collectée
          _buildSectionHeader('TVA COLLECTÉE'),
          ..._buildTVAByRateRows(
              tvaCollected['by_rate'] as Map<String, dynamic>),
          _buildTVARow(
            'TOTAL TVA COLLECTÉE',
            null,
            tvaCollected['total'],
            bold: true,
          ),
          const Divider(),

          // TVA Déductible
          const SizedBox(height: 16),
          _buildSectionHeader('TVA DÉDUCTIBLE'),
          ..._buildTVAByRateRows(
              tvaDeductible['by_rate'] as Map<String, dynamic>),
          _buildTVARow(
            'TOTAL TVA DÉDUCTIBLE',
            null,
            tvaDeductible['total'],
            bold: true,
          ),
          const Divider(),

          // Net TVA
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  netTva >= 0 ? Colors.red.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: netTva >= 0
                    ? Colors.red.shade200
                    : Colors.green.shade200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      netTva >= 0 ? Icons.payment : Icons.account_balance_wallet,
                      color: netTva >= 0 ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        netTva >= 0 ? 'TVA À PAYER' : 'CRÉDIT DE TVA',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      InvoiceCalculator.formatCurrency(netTva.abs()),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: netTva >= 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildReportRow(
    String label,
    double? amountHT,
    double? amountTVA,
    double? amountTTC, {
    bool bold = false,
    bool showHeaders = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          if (showHeaders)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Expanded(flex: 2, child: SizedBox()),
                  Expanded(
                    child: Text(
                      'HT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'TVA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'TTC',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    fontSize: bold ? 16 : 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  amountHT != null
                      ? InvoiceCalculator.formatCurrency(amountHT)
                      : '-',
                  style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                child: Text(
                  amountTVA != null
                      ? InvoiceCalculator.formatCurrency(amountTVA)
                      : '-',
                  style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                child: Text(
                  amountTTC != null
                      ? InvoiceCalculator.formatCurrency(amountTTC)
                      : '-',
                  style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTVARow(
    String label,
    double? baseHT,
    double? amountTVA, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 16 : 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              baseHT != null ? InvoiceCalculator.formatCurrency(baseHT) : '-',
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              amountTVA != null
                  ? InvoiceCalculator.formatCurrency(amountTVA)
                  : '-',
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTVAByRateRows(Map<String, dynamic> byRate) {
    return byRate.entries.map((entry) {
      final rate = entry.key;
      final data = entry.value as Map<String, dynamic>;
      return _buildTVARow(
        'TVA à $rate',
        data['base_ht'],
        data['amount'],
      );
    }).toList();
  }
}
