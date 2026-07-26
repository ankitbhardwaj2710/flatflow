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
    if (analytics.categoryTotals.isEmpty ||
        analytics.topCategory == null) {
      return const SizedBox.shrink();
    }

    final topAmount =
        analytics.categoryTotals[analytics.topCategory!] ?? 0;

    final percentage = analytics.totalSpent == 0
        ? 0
        : (topAmount / analytics.totalSpent) * 100;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber,
                size: 34,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Spending Category',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    analytics.topCategory!,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${percentage.toStringAsFixed(1)}% of total spending',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${topAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Total'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}