import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/expense_analytics.dart';
import 'chart_card.dart';
import 'category_legend.dart';
import '../../utils/chart_colors.dart';

class CategoryPieChart extends StatelessWidget {
  final ExpenseAnalytics analytics;

  const CategoryPieChart({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    if (analytics.categoryTotals.isEmpty) {
      return const ChartCard(
        title: 'Category Spending',
        child: Center(child: Text('No expense data available')),
      );
    }

    final entries = analytics.categoryTotals.entries.toList();

    return ChartCard(
      title: 'Category Spending',
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sectionsSpace: 3,
                sections: List.generate(entries.length, (index) {
                  final entry = entries[index];

                  return PieChartSectionData(
                    value: entry.value,
                    title:
                        '${((entry.value / analytics.totalSpent) * 100).toStringAsFixed(0)}%',
                        color: ChartColors.colors[index % ChartColors.colors.length],
                    radius: 80,
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          CategoryLegend(categories: analytics.categoryTotals),
        ],
      ),
    );
  }
}
