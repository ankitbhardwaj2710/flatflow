import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dashboard_provider.dart';

class MonthlyAnalyticsCard extends ConsumerWidget {
  const MonthlyAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    Widget tile(String title, String value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(title),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            tile(
              "This Month",
              "₹${stats.monthlyExpense.toStringAsFixed(0)}",
            ),
            const SizedBox(width: 12),
            tile(
              "Average",
              "₹${stats.averageExpense.toStringAsFixed(0)}",
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            tile(
              "Transactions",
              stats.totalExpenses.toString(),
            ),
            const SizedBox(width: 12),
            tile(
              "Total",
              "₹${stats.totalExpenseAmount.toStringAsFixed(0)}",
            ),
          ],
        ),
      ],
    );
  }
}