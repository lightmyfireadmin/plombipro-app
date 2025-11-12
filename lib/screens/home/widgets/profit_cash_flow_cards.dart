import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/invoice.dart';
import '../../../models/payment.dart';
import '../../../services/invoice_calculator.dart';

/// Profit margin and cash flow visualization cards
class ProfitCashFlowCards extends StatelessWidget {
  final List<Invoice> invoices;
  final List<Payment> payments;

  const ProfitCashFlowCards({
    super.key,
    required this.invoices,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProfitMarginCard(context),
        const SizedBox(height: 16),
        _buildCashFlowCard(context),
      ],
    );
  }

  Widget _buildProfitMarginCard(BuildContext context) {
    final stats = _calculateProfitMargin();
    final marginPercentage = stats['marginPercentage']!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Marge bénéficiaire',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getProfitColor(marginPercentage).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${marginPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getProfitColor(marginPercentage),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    context,
                    'Revenus',
                    InvoiceCalculator.formatCurrency(stats['revenue']!),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatColumn(
                    context,
                    'Coûts estimés',
                    InvoiceCalculator.formatCurrency(stats['costs']!),
                    Icons.trending_down,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatColumn(
                    context,
                    'Profit',
                    InvoiceCalculator.formatCurrency(stats['profit']!),
                    Icons.euro,
                    _getProfitColor(marginPercentage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProfitMarginBar(context, marginPercentage),
            const SizedBox(height: 12),
            _buildProfitInsights(context, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlowCard(BuildContext context) {
    final cashFlowData = _calculateCashFlow();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flux de trésorerie',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildCashFlowStat(
                    context,
                    'Entrées',
                    cashFlowData['inflow']!,
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCashFlowStat(
                    context,
                    'Sorties',
                    cashFlowData['outflow']!,
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCashFlowStat(
                    context,
                    'Solde',
                    cashFlowData['balance']!,
                    cashFlowData['balance']! >= 0 ? Colors.green : Colors.red,
                    Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCashFlowChart(context, cashFlowData),
            const SizedBox(height: 12),
            _buildCashFlowInsights(context, cashFlowData),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProfitMarginBar(BuildContext context, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Indicateur de marge',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              widthFactor: (percentage / 100).clamp(0.0, 1.0),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getProfitColor(percentage),
                      _getProfitColor(percentage).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfitInsights(BuildContext context, Map<String, double> stats) {
    final marginPercentage = stats['marginPercentage']!;
    String insight;
    IconData icon;
    Color color;

    if (marginPercentage >= 30) {
      insight = 'Excellente marge bénéficiaire! Continue comme ça.';
      icon = Icons.celebration;
      color = Colors.green;
    } else if (marginPercentage >= 20) {
      insight = 'Bonne marge. Il y a de la place pour l\'amélioration.';
      icon = Icons.thumb_up;
      color = Colors.lightGreen;
    } else if (marginPercentage >= 10) {
      insight = 'Marge correcte. Envisage d\'optimiser les coûts.';
      icon = Icons.warning;
      color = Colors.orange;
    } else {
      insight = 'Marge faible. Révise ta stratégie de prix.';
      icon = Icons.error;
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowStat(
    BuildContext context,
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          InvoiceCalculator.formatCurrency(value.abs()),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCashFlowChart(BuildContext context, Map<String, double> data) {
    return AspectRatio(
      aspectRatio: 2.5,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: Colors.green,
              value: data['inflow']!,
              title: 'Entrées',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.red,
              value: data['outflow']!.abs(),
              title: 'Sorties',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlowInsights(BuildContext context, Map<String, double> data) {
    final balance = data['balance']!;
    final isPositive = balance >= 0;
    String insight;
    IconData icon;
    Color color;

    if (isPositive) {
      if (balance > data['inflow']! * 0.5) {
        insight = 'Excellent flux de trésorerie positif!';
        icon = Icons.trending_up;
        color = Colors.green;
      } else {
        insight = 'Flux de trésorerie positif mais surveille les dépenses.';
        icon = Icons.info;
        color = Colors.lightGreen;
      }
    } else {
      insight = 'Attention: Flux de trésorerie négatif. Révise tes dépenses.';
      icon = Icons.warning;
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateProfitMargin() {
    double revenue = 0.0;
    double costs = 0.0;

    // Calculate revenue from paid invoices
    for (final invoice in invoices) {
      if (invoice.paymentStatus == 'paid') {
        revenue += invoice.totalTtc;

        // Estimate costs as 60% of revenue (materials, labor, etc.)
        // In a real app, this would come from actual expense tracking
        costs += invoice.totalTtc * 0.60;
      }
    }

    final profit = revenue - costs;
    final marginPercentage = revenue > 0 ? (profit / revenue) * 100 : 0.0;

    return {
      'revenue': revenue,
      'costs': costs,
      'profit': profit,
      'marginPercentage': marginPercentage,
    };
  }

  Map<String, double> _calculateCashFlow() {
    double inflow = 0.0;
    double outflow = 0.0;

    // Calculate inflow from payments received
    for (final payment in payments) {
      inflow += payment.amount;
    }

    // Calculate outflow (estimate as 70% of paid invoices)
    // In a real app, this would come from actual expense tracking
    for (final invoice in invoices) {
      if (invoice.paymentStatus == 'paid') {
        outflow += invoice.totalTtc * 0.70;
      }
    }

    final balance = inflow - outflow;

    return {
      'inflow': inflow,
      'outflow': outflow,
      'balance': balance,
    };
  }

  Color _getProfitColor(double percentage) {
    if (percentage >= 30) {
      return Colors.green;
    } else if (percentage >= 20) {
      return Colors.lightGreen;
    } else if (percentage >= 10) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
