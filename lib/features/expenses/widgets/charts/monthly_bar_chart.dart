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
        child: Center(
          child: Text('No monthly data available'),
        ),
      );
    }

    final months = analytics.monthlyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ChartCard(
      title: 'Monthly Spending',
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
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

                  if (month >= 1 && month <= 12) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[month],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }

                  return const SizedBox();
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
                  color: ChartColors.colors[
                      entry.key % ChartColors.colors.length],
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}