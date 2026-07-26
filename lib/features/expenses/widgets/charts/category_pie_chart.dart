import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/expense_analytics.dart';
import '../../utils/chart_colors.dart';
import 'category_legend.dart';
import 'chart_card.dart';

class CategoryPieChart extends StatelessWidget {
  final ExpenseAnalytics analytics;

  const CategoryPieChart({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    if (analytics.categoryTotals.isEmpty) {
      return const ChartCard(
        title: 'Category Spending',
        child: SizedBox(
          height: 220,
          child: Center(
            child: Text(
              'No expense data available',
            ),
          ),
        ),
      );
    }

    final entries = analytics.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ChartCard(
      title: 'Category Spending',
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 55,
                sectionsSpace: 4,
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(
                  enabled: true,
                ),
                sections: List.generate(
                  entries.length,
                  (index) {
                    final entry = entries[index];

                    final percent =
                        (entry.value / analytics.totalSpent) * 100;

                    return PieChartSectionData(
                      value: entry.value,
                      color: ChartColors.colors[
                          index % ChartColors.colors.length],
                      radius: 90,
                      title:
                          '${percent.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    );
                  },
                ),
              ),
              duration: const Duration(
                milliseconds: 700,
              ),
              curve: Curves.easeOutCubic,
            ),
          ),

          const SizedBox(height: 24),

          CategoryLegend(
            categories: analytics.categoryTotals,
          ),
        ],
      ),
    );
  }
}