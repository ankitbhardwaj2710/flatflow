import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_analytics.dart';
import 'expense_filter_provider.dart';

final expenseAnalyticsProvider = Provider<ExpenseAnalytics>((ref) {
  final expenses = ref.watch(filteredExpensesProvider);

  if (expenses.isEmpty) {
    return const ExpenseAnalytics(
      totalSpent: 0,
      averageExpense: 0,
      highestExpense: 0,
      totalExpenses: 0,
      categoryTotals: {},
      monthlyTotals: {},
    );
  }

  double total = 0;
  double highest = 0;

  final categoryTotals = <String, double>{};
  final monthlyTotals = <int, double>{};

  for (final expense in expenses) {
    total += expense.amount;

    if (expense.amount > highest) {
      highest = expense.amount;
    }

    categoryTotals.update(
      expense.category,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );

    final month = expense.createdAt?.month ?? DateTime.now().month;

    monthlyTotals.update(
      month,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }

  return ExpenseAnalytics(
    totalSpent: total,
    averageExpense: total / expenses.length,
    highestExpense: highest,
    totalExpenses: expenses.length,
    categoryTotals: categoryTotals,
    monthlyTotals: monthlyTotals,
  );
});