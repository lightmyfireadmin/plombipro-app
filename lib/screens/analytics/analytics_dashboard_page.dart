import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/invoice_calculator.dart';
import '../../widgets/app_drawer.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  bool _isLoading = true;

  // Template stats
  List<Map<String, dynamic>> _topTemplates = [];
  int _totalTemplates = 0;
  int _systemTemplates = 0;
  int _userTemplates = 0;

  // Financial stats
  double _totalRevenue = 0.0;
  double _monthlyRevenue = 0.0;
  int _totalQuotes = 0;
  int _totalInvoices = 0;
  int _paidInvoices = 0;
  double _outstandingAmount = 0.0;

  // Recent activity
  List<Map<String, dynamic>> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load template statistics
      final templatesResponse = await supabase
          .from('templates')
          .select('id, template_name, category, times_used, is_system_template, last_used')
          .or('user_id.eq.$userId,is_system_template.eq.true')
          .order('times_used', ascending: false)
          .limit(10);

      final allTemplates = templatesResponse as List<dynamic>;

      // Load quote statistics
      final quotesResponse = await supabase
          .from('quotes')
          .select('total_ttc, created_at')
          .eq('user_id', userId);

      final quotes = quotesResponse as List<dynamic>;

      // Load invoice statistics
      final invoicesResponse = await supabase
          .from('invoices')
          .select('total_ttc, payment_status, balance_due, created_at')
          .eq('user_id', userId);

      final invoices = invoicesResponse as List<dynamic>;

      // Calculate stats
      setState(() {
        // Template stats
        _topTemplates = allTemplates.map((t) => t as Map<String, dynamic>).toList();
        _totalTemplates = allTemplates.length;
        _systemTemplates = allTemplates.where((t) => t['is_system_template'] == true).length;
        _userTemplates = _totalTemplates - _systemTemplates;

        // Quote stats
        _totalQuotes = quotes.length;

        // Invoice stats
        _totalInvoices = invoices.length;
        _paidInvoices = invoices.where((inv) =>
          inv['payment_status']?.toString().toLowerCase() == 'paid' ||
          inv['payment_status']?.toString().toLowerCase() == 'payée'
        ).length;

        _totalRevenue = invoices.fold(0.0, (sum, inv) =>
          sum + ((inv['total_ttc'] as num?)?.toDouble() ?? 0.0)
        );

        _outstandingAmount = invoices.fold(0.0, (sum, inv) {
          final status = inv['payment_status']?.toString().toLowerCase();
          if (status == 'paid' || status == 'payée') return sum;
          return sum + ((inv['balance_due'] as num?)?.toDouble() ??
                       (inv['total_ttc'] as num?)?.toDouble() ?? 0.0);
        });

        // Calculate monthly revenue (last 30 days)
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        _monthlyRevenue = invoices.where((inv) {
          try {
            final createdAt = DateTime.parse(inv['created_at'] as String);
            return createdAt.isAfter(thirtyDaysAgo);
          } catch (e) {
            return false;
          }
        }).fold(0.0, (sum, inv) =>
          sum + ((inv['total_ttc'] as num?)?.toDouble() ?? 0.0)
        );

        // Recent activity (last 5 quotes/invoices)
        _recentActivity = [
          ...quotes.take(3).map((q) => {
            'type': 'quote',
            'date': q['created_at'],
            'amount': q['total_ttc'],
          }),
          ...invoices.take(3).map((inv) => {
            'type': 'invoice',
            'date': inv['created_at'],
            'amount': inv['total_ttc'],
            'status': inv['payment_status'],
          }),
        ];

        _recentActivity.sort((a, b) =>
          DateTime.parse(b['date'] as String).compareTo(DateTime.parse(a['date'] as String))
        );
        _recentActivity = _recentActivity.take(5).toList();

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadAnalytics();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Financial Overview
                  const Text('Vue d\'ensemble financière',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildFinancialCards(),
                  const SizedBox(height: 24),

                  // Document Stats
                  const Text('Statistiques documents',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildDocumentStats(),
                  const SizedBox(height: 24),

                  // Template Usage
                  const Text('Modèles les plus utilisés',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTemplateUsage(),
                  const SizedBox(height: 24),

                  // Recent Activity
                  const Text('Activité récente',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildFinancialCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Chiffre d\'affaires total',
                value: InvoiceCalculator.formatCurrency(_totalRevenue),
                icon: Icons.euro,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'CA ce mois',
                value: InvoiceCalculator.formatCurrency(_monthlyRevenue),
                icon: Icons.trending_up,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Impayés',
                value: InvoiceCalculator.formatCurrency(_outstandingAmount),
                icon: Icons.warning_amber,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Factures payées',
                value: '$_paidInvoices / $_totalInvoices',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Devis',
            value: '$_totalQuotes',
            icon: Icons.description,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Factures',
            value: '$_totalInvoices',
            icon: Icons.receipt_long,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Modèles',
            value: '$_totalTemplates',
            icon: Icons.folder_special,
            color: Colors.purple,
            subtitle: '$_systemTemplates système, $_userTemplates perso',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateUsage() {
    if (_topTemplates.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Aucun modèle utilisé pour le moment.'),
        ),
      );
    }

    return Card(
      child: Column(
        children: _topTemplates.map((template) {
          final timesUsed = template['times_used'] as int? ?? 0;
          final isSystem = template['is_system_template'] as bool? ?? false;
          final lastUsed = template['last_used'] as String?;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isSystem ? Colors.blue.shade100 : Colors.purple.shade100,
              child: Icon(
                isSystem ? Icons.business : Icons.person,
                color: isSystem ? Colors.blue : Colors.purple,
                size: 20,
              ),
            ),
            title: Text(
              template['template_name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(template['category'] as String? ?? 'Sans catégorie'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$timesUsed utilisations',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                if (lastUsed != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatLastUsed(lastUsed),
                    style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivity() {
    if (_recentActivity.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Aucune activité récente.'),
        ),
      );
    }

    return Card(
      child: Column(
        children: _recentActivity.map((activity) {
          final type = activity['type'] as String;
          final isQuote = type == 'quote';
          final amount = (activity['amount'] as num?)?.toDouble() ?? 0.0;
          final date = activity['date'] as String;
          final status = activity['status'] as String?;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isQuote ? Colors.blue.shade100 : Colors.red.shade100,
              child: Icon(
                isQuote ? Icons.description : Icons.receipt_long,
                color: isQuote ? Colors.blue : Colors.red,
                size: 20,
              ),
            ),
            title: Text(
              isQuote ? 'Devis créé' : 'Facture créée',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(_formatDate(date)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  InvoiceCalculator.formatCurrency(amount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (status != null)
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(status),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatLastUsed(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Aujourd\'hui';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      } else if (difference.inDays < 30) {
        return 'Il y a ${(difference.inDays / 7).floor()} semaines';
      } else {
        return 'Il y a ${(difference.inDays / 30).floor()} mois';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return InvoiceCalculator.formatDate(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'payée':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
