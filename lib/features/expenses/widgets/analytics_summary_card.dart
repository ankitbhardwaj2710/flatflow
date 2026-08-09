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
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
 
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Total',
                    value:
                        '₹${analytics.totalSpent.toStringAsFixed(0)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Expenses',
                    value: analytics.totalExpenses.toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.trending_up,
                    title: 'Highest',
                    value:
                        '₹${analytics.highestExpense.toStringAsFixed(0)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.bar_chart,
                    title: 'Average',
                    value:
                        '₹${analytics.averageExpense.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.calendar_month_outlined,
                    title: 'This Month',
                    value:
                        '₹${analytics.currentMonthSpent.toStringAsFixed(0)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: analytics.monthlyGrowth >= 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    title: 'Growth',
                    value:
                        '${analytics.monthlyGrowth.toStringAsFixed(1)}%',
                    valueColor:
                        analytics.monthlyGrowth >= 0
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}