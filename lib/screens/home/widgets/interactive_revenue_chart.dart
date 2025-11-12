import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/quote.dart';
import '../../../models/invoice.dart';
import '../../../services/invoice_calculator.dart';

enum ChartPeriod { today, week, month, quarter, year }
enum ChartType { bar, line }

/// Interactive revenue chart with time period filters and multiple visualizations
class InteractiveRevenueChart extends StatefulWidget {
  final List<Quote> quotes;
  final List<Invoice> invoices;

  const InteractiveRevenueChart({
    super.key,
    required this.quotes,
    required this.invoices,
  });

  @override
  State<InteractiveRevenueChart> createState() => _InteractiveRevenueChartState();
}

class _InteractiveRevenueChartState extends State<InteractiveRevenueChart> {
  ChartPeriod _selectedPeriod = ChartPeriod.month;
  ChartType _chartType = ChartType.bar;
  bool _showComparison = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildPeriodFilters(),
            const SizedBox(height: 16),
            _buildChartTypeToggle(),
            const SizedBox(height: 24),
            _buildChart(),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final stats = _calculateStats();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chiffre d\'affaires',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              icon: Icon(
                _showComparison ? Icons.compare_arrows : Icons.show_chart,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _showComparison = !_showComparison;
                });
              },
              tooltip: _showComparison ? 'Masquer comparaison' : 'Comparer périodes',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          InvoiceCalculator.formatCurrency(stats['current']!),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        if (_showComparison) _buildComparison(stats),
      ],
    );
  }

  Widget _buildComparison(Map<String, double> stats) {
    final current = stats['current']!;
    final previous = stats['previous']!;
    final change = previous > 0 ? ((current - previous) / previous * 100) : 0.0;
    final isPositive = change >= 0;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '${change.abs().toStringAsFixed(1)}% vs période précédente',
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ChartPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_getPeriodLabel(period)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartTypeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SegmentedButton<ChartType>(
          segments: const [
            ButtonSegment(
              value: ChartType.bar,
              label: Text('Barres'),
              icon: Icon(Icons.bar_chart, size: 16),
            ),
            ButtonSegment(
              value: ChartType.line,
              label: Text('Courbe'),
              icon: Icon(Icons.show_chart, size: 16),
            ),
          ],
          selected: {_chartType},
          onSelectionChanged: (Set<ChartType> newSelection) {
            setState(() {
              _chartType = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChart() {
    return AspectRatio(
      aspectRatio: 1.5,
      child: _chartType == ChartType.bar ? _buildBarChart() : _buildLineChart(),
    );
  }

  Widget _buildBarChart() {
    final data = _getChartData();
    final maxY = data.isEmpty ? 100.0 : (data.values.reduce((a, b) => a > b ? a : b) * 1.2);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${InvoiceCalculator.formatCurrency(rod.toY)}\n${_getTooltipLabel(groupIndex)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4.0,
                  child: Text(
                    _getBottomTitle(value.toInt()),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatCompactCurrency(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(data),
      ),
    );
  }

  Widget _buildLineChart() {
    final data = _getChartData();
    final maxY = data.isEmpty ? 100.0 : (data.values.reduce((a, b) => a > b ? a : b) * 1.2);

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${InvoiceCalculator.formatCurrency(spot.y)}\n${_getTooltipLabel(spot.x.toInt())}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4.0,
                  child: Text(
                    _getBottomTitle(value.toInt()),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatCompactCurrency(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Theme.of(context).primaryColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Accepté', Colors.green),
        const SizedBox(width: 16),
        _buildLegendItem('Payé', Colors.blue),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Map<int, double> _getChartData() {
    final now = DateTime.now();
    Map<int, double> data = {};

    switch (_selectedPeriod) {
      case ChartPeriod.today:
        // Hourly data for today (24 hours)
        for (var i = 0; i < 24; i++) {
          data[i] = 0.0;
        }
        for (final invoice in widget.invoices) {
          if (invoice.date.year == now.year &&
              invoice.date.month == now.month &&
              invoice.date.day == now.day &&
              invoice.paymentStatus == 'paid') {
            final hour = invoice.date.hour;
            data[hour] = (data[hour] ?? 0) + invoice.totalTtc;
          }
        }
        break;

      case ChartPeriod.week:
        // Daily data for last 7 days
        for (var i = 0; i < 7; i++) {
          data[i] = 0.0;
        }
        for (var i = 0; i < 7; i++) {
          final day = now.subtract(Duration(days: 6 - i));
          for (final invoice in widget.invoices) {
            if (invoice.date.year == day.year &&
                invoice.date.month == day.month &&
                invoice.date.day == day.day &&
                invoice.paymentStatus == 'paid') {
              data[i] = (data[i] ?? 0) + invoice.totalTtc;
            }
          }
        }
        break;

      case ChartPeriod.month:
        // Weekly data for current month (4 weeks)
        for (var i = 0; i < 4; i++) {
          data[i] = 0.0;
        }
        for (final invoice in widget.invoices) {
          if (invoice.date.year == now.year &&
              invoice.date.month == now.month &&
              invoice.paymentStatus == 'paid') {
            final weekOfMonth = ((invoice.date.day - 1) / 7).floor();
            if (weekOfMonth < 4) {
              data[weekOfMonth] = (data[weekOfMonth] ?? 0) + invoice.totalTtc;
            }
          }
        }
        break;

      case ChartPeriod.quarter:
        // Monthly data for last 3 months
        for (var i = 0; i < 3; i++) {
          data[i] = 0.0;
        }
        for (var i = 0; i < 3; i++) {
          final month = DateTime(now.year, now.month - (2 - i), 1);
          for (final invoice in widget.invoices) {
            if (invoice.date.year == month.year &&
                invoice.date.month == month.month &&
                invoice.paymentStatus == 'paid') {
              data[i] = (data[i] ?? 0) + invoice.totalTtc;
            }
          }
        }
        break;

      case ChartPeriod.year:
        // Monthly data for last 12 months
        for (var i = 0; i < 12; i++) {
          data[i] = 0.0;
        }
        for (var i = 0; i < 12; i++) {
          final month = DateTime(now.year, now.month - (11 - i), 1);
          for (final invoice in widget.invoices) {
            if (invoice.date.year == month.year &&
                invoice.date.month == month.month &&
                invoice.paymentStatus == 'paid') {
              data[i] = (data[i] ?? 0) + invoice.totalTtc;
            }
          }
        }
        break;
    }

    return data;
  }

  Map<String, double> _calculateStats() {
    final now = DateTime.now();
    double current = 0.0;
    double previous = 0.0;

    for (final invoice in widget.invoices) {
      if (invoice.paymentStatus == 'paid') {
        final isInCurrentPeriod = _isInPeriod(invoice.date, now, _selectedPeriod);
        final isInPreviousPeriod = _isInPreviousPeriod(invoice.date, now, _selectedPeriod);

        if (isInCurrentPeriod) {
          current += invoice.totalTtc;
        } else if (isInPreviousPeriod) {
          previous += invoice.totalTtc;
        }
      }
    }

    return {'current': current, 'previous': previous};
  }

  bool _isInPeriod(DateTime date, DateTime now, ChartPeriod period) {
    switch (period) {
      case ChartPeriod.today:
        return date.year == now.year && date.month == now.month && date.day == now.day;
      case ChartPeriod.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return date.isAfter(weekAgo) && date.isBefore(now.add(const Duration(days: 1)));
      case ChartPeriod.month:
        return date.year == now.year && date.month == now.month;
      case ChartPeriod.quarter:
        final quarterStart = DateTime(now.year, now.month - 2, 1);
        return date.isAfter(quarterStart) && date.isBefore(now.add(const Duration(days: 1)));
      case ChartPeriod.year:
        return date.year == now.year;
    }
  }

  bool _isInPreviousPeriod(DateTime date, DateTime now, ChartPeriod period) {
    switch (period) {
      case ChartPeriod.today:
        final yesterday = now.subtract(const Duration(days: 1));
        return date.year == yesterday.year &&
            date.month == yesterday.month &&
            date.day == yesterday.day;
      case ChartPeriod.week:
        final twoWeeksAgo = now.subtract(const Duration(days: 14));
        final weekAgo = now.subtract(const Duration(days: 7));
        return date.isAfter(twoWeeksAgo) && date.isBefore(weekAgo);
      case ChartPeriod.month:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return date.year == lastMonth.year && date.month == lastMonth.month;
      case ChartPeriod.quarter:
        final prevQuarterStart = DateTime(now.year, now.month - 5, 1);
        final prevQuarterEnd = DateTime(now.year, now.month - 2, 1);
        return date.isAfter(prevQuarterStart) && date.isBefore(prevQuarterEnd);
      case ChartPeriod.year:
        return date.year == now.year - 1;
    }
  }

  List<BarChartGroupData> _buildBarGroups(Map<int, double> data) {
    return data.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Theme.of(context).primaryColor,
            width: 16,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    }).toList();
  }

  String _getPeriodLabel(ChartPeriod period) {
    switch (period) {
      case ChartPeriod.today:
        return 'Aujourd\'hui';
      case ChartPeriod.week:
        return 'Semaine';
      case ChartPeriod.month:
        return 'Mois';
      case ChartPeriod.quarter:
        return 'Trimestre';
      case ChartPeriod.year:
        return 'Année';
    }
  }

  String _getBottomTitle(int index) {
    switch (_selectedPeriod) {
      case ChartPeriod.today:
        return '${index}h';
      case ChartPeriod.week:
        final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
        return index < days.length ? days[index] : '';
      case ChartPeriod.month:
        return 'S${index + 1}';
      case ChartPeriod.quarter:
        final now = DateTime.now();
        final month = DateTime(now.year, now.month - (2 - index), 1);
        return _getMonthAbbr(month.month);
      case ChartPeriod.year:
        return _getMonthAbbr(index + 1);
    }
  }

  String _getTooltipLabel(int index) {
    switch (_selectedPeriod) {
      case ChartPeriod.today:
        return '${index}:00';
      case ChartPeriod.week:
        final now = DateTime.now();
        final day = now.subtract(Duration(days: 6 - index));
        return '${day.day}/${day.month}';
      case ChartPeriod.month:
        return 'Semaine ${index + 1}';
      case ChartPeriod.quarter:
        final now = DateTime.now();
        final month = DateTime(now.year, now.month - (2 - index), 1);
        return _getMonthName(month.month);
      case ChartPeriod.year:
        return _getMonthName(index + 1);
    }
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }

  String _formatCompactCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k€';
    }
    return '${value.toStringAsFixed(0)}€';
  }
}
