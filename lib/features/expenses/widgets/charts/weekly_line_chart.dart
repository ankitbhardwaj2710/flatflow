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
        child: SizedBox(
          height: 260,
          child: Center(
            child: Text(
              'No weekly data available',
            ),
          ),
        ),
      );
    }

    final weeks = analytics.weeklyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxValue = weeks
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return ChartCard(
      title: 'Weekly Spending',
      child: SizedBox(
        height: 280,
        child: LineChart(
          LineChartData(
            minX: 1,
            maxX: weeks.last.key.toDouble(),
            minY: 0,
            maxY: maxValue * 1.2,

            borderData: FlBorderData(show: false),

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxValue / 5,
            ),

            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) {
                  return spots.map((spot) {
                    return LineTooltipItem(
                      '₹${spot.y.toStringAsFixed(0)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
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
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'W${value.toInt()}',
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
                curveSmoothness: 0.35,

                color: Theme.of(context).colorScheme.primary,

                barWidth: 4,

                isStrokeCapRound: true,

                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(.12),
                ),

                dotData: FlDotData(
                  show: true,
                ),
              ),
            ],
          ),

          duration: const Duration(
            milliseconds: 700,
          ),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }
}