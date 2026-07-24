import 'package:flutter/material.dart';

import '../models/expense_analytics.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final ExpenseAnalytics analytics;

  const AnalyticsSummaryCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _tile(
              'Total Spent',
              '₹${analytics.totalSpent.toStringAsFixed(2)}',
            ),
            const Divider(),
            _tile(
              'Average Expense',
              '₹${analytics.averageExpense.toStringAsFixed(2)}',
            ),
            const Divider(),
            _tile(
              'Highest Expense',
              '₹${analytics.highestExpense.toStringAsFixed(2)}',
            ),
            const Divider(),
            _tile(
              'Total Expenses',
              analytics.totalExpenses.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}