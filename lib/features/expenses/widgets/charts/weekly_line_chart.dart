import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/expense_analytics.dart';
import 'chart_card.dart';

class WeeklyLineChart extends StatelessWidget {
  final ExpenseAnalytics analytics;

  const WeeklyLineChart({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    if (analytics.weeklyTotals.isEmpty) {
      return const ChartCard(
        title: 'Weekly Spending',
        child: Center(
          child: Text('No weekly data available'),
        ),
      );
    }

    final weeks = analytics.weeklyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ChartCard(
      title: 'Weekly Spending',
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'W${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: weeks
                  .map(
                    (e) => FlSpot(
                      e.key.toDouble(),
                      e.value,
                    ),
                  )
                  .toList(),
              isCurved: true,
              barWidth: 4,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}