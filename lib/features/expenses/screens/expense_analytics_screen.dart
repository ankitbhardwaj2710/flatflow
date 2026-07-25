import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/expense_analytics_provider.dart';
import '../widgets/analytics_summary_card.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/top_category_card.dart';

class ExpenseAnalyticsScreen extends ConsumerWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(expenseAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnalyticsSummaryCard(
            analytics: analytics,
          ),

          const SizedBox(height: 20),

          CategoryBreakdownCard(
            analytics: analytics,
          ),

          const SizedBox(height: 20),

          TopCategoryCard(
            analytics: analytics,
          ),
        ],
      ),
    );
  }
}