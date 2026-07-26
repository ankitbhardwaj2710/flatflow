import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/expense_analytics.dart';
import '../../utils/chart_colors.dart';
import 'chart_card.dart';

class MonthlyBarChart extends StatelessWidget {
  final ExpenseAnalytics analytics;

  const MonthlyBarChart({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    if (analytics.monthlyTotals.isEmpty) {
      return const ChartCard(
        title: 'Monthly Spending',
        child: SizedBox(
          height: 260,
          child: Center(
            child: Text('No monthly data available'),
          ),
        ),
      );
    }

    final months = analytics.monthlyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxValue = months
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return ChartCard(
      title: 'Monthly Spending',
      child: SizedBox(
        height: 280,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValue * 1.2,

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxValue / 5,
            ),

            borderData: FlBorderData(show: false),

            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '₹${rod.toY.toStringAsFixed(0)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),

            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 34,
                  getTitlesWidget: (value, meta) {
                    const labels = [
                      '',
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec',
                    ];

                    final month = value.toInt();

                    if (month < 1 || month > 12) {
                      return const SizedBox();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[month],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            barGroups: months.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    width: 22,
                    borderRadius: BorderRadius.circular(8),
                    color: ChartColors.colors[
                        (entry.key - 1) %
                            ChartColors.colors.length],
                  ),
                ],
              );
            }).toList(),
          ),

          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }
}