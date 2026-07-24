import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_analytics.dart';
import '../services/expense_analytics_service.dart';
import 'expense_filter_provider.dart';

final expenseAnalyticsServiceProvider =
    Provider((ref) => const ExpenseAnalyticsService());

final expenseAnalyticsProvider = Provider<ExpenseAnalytics>((ref) {
  final expenses = ref.watch(filteredExpensesProvider);

  final service = ref.watch(expenseAnalyticsServiceProvider);

  return service.calculate(expenses);
});