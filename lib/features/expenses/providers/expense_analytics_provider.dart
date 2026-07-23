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
    );
  }

  double total = 0;
  double highest = 0;

  for (final expense in expenses) {
    total += expense.amount;

    if (expense.amount > highest) {
      highest = expense.amount;
    }
  }
 
  return ExpenseAnalytics(
    totalSpent: total,
    averageExpense: total / expenses.length,
    highestExpense: highest,
    totalExpenses: expenses.length,
  );
}); 