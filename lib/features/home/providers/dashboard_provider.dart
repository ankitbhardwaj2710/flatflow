import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../expenses/providers/expense_provider.dart';
import '../models/dashboard_stats.dart';
import 'home_provider.dart';

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  final members = ref.watch(currentFlatMembersProvider).value ?? [];

  double totalAmount = 0;
  double monthlyAmount = 0;

  final now = DateTime.now();

  for (final expense in expenses) {
    totalAmount += expense.amount;

    final createdAt = expense.createdAt;

    if (createdAt != null &&
        createdAt.year == now.year &&
        createdAt.month == now.month) {
      monthlyAmount += expense.amount;
    }
  }

  final double average =
    expenses.isEmpty ? 0.0 : totalAmount / expenses.length;

  return DashboardStats(
    totalExpenses: expenses.length,
    totalMembers: members.length,
    totalExpenseAmount: totalAmount,
    monthlyExpense: monthlyAmount,
    averageExpense: average,
  );
});