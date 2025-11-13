import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:app/models/quote.dart';

class RevenueChart extends StatelessWidget {
  final List<Quote> quotes;

  const RevenueChart({super.key, required this.quotes});

  @override
  Widget build(BuildContext context) {
    final monthlyData = _calculateMonthlyRevenue();
    // Handle empty data or all-zeros case to prevent crashes and rendering issues
    final maxValue = monthlyData.values.isEmpty
        ? 0.0
        : monthlyData.values.reduce((a, b) => a > b ? a : b);
    final maxY = (maxValue == 0 ? 100.0 : maxValue * 1.2).toDouble();

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toStringAsFixed(0),
                      const TextStyle(color: Colors.white),
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
                      final month = _getAbbreviatedMonthName(value.toInt() + 1);
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4.0,
                        child: Text(month, style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(monthlyData),
            ),
          ),
        ),
      ),
    );
  }

  Map<int, double> _calculateMonthlyRevenue() {
    final now = DateTime.now();
    final last12Months = List.generate(12, (index) {
      return DateTime(now.year, now.month - index, 1);
    });

    final Map<int, double> monthlyRevenue = {};
    for (var i = 0; i < 12; i++) {
      monthlyRevenue[i] = 0.0;
    }

    for (final quote in quotes) {
      if (quote.status == 'accepted') {
        final quoteMonth = quote.date.month;
        final quoteYear = quote.date.year;

        for (var i = 0; i < last12Months.length; i++) {
          final month = last12Months[i];
          if (quoteYear == month.year && quoteMonth == month.month) {
            monthlyRevenue[11 - i] = (monthlyRevenue[11 - i] ?? 0) + quote.totalTtc;
            break;
          }
        }
      }
    }
    return monthlyRevenue;
  }

  List<BarChartGroupData> _buildBarGroups(Map<int, double> monthlyData) {
    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: monthlyData[index] ?? 0,
            color: Colors.lightBlueAccent,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  String _getAbbreviatedMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Fev';
      case 3:
        return 'Mar';
      case 4:
        return 'Avr';
      case 5:
        return 'Mai';
      case 6:
        return 'Juin';
      case 7:
        return 'Juil';
      case 8:
        return 'Aou';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
