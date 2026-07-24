import 'package:flutter/material.dart';

import '../models/expense_analytics.dart';

class TopCategoryCard extends StatelessWidget {
  final ExpenseAnalytics analytics;

  const TopCategoryCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    if (analytics.categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final top = analytics.categoryTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return Card(
      child: ListTile(
        leading: const Icon(Icons.emoji_events),
        title: const Text('Top Spending Category'),
        subtitle: Text(top.key),
        trailing: Text(
          '₹${top.value.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}