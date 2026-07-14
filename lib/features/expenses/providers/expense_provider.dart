import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';

final expenseRepositoryProvider =
    Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final expensesProvider =
    StreamProvider<List<ExpenseModel>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchExpenses();
});
class ExpenseSummary {
  final double monthlySpending;
  final double balance;

  const ExpenseSummary({
    required this.monthlySpending,
    required this.balance,
  });
}

final expenseSummaryProvider = Provider<ExpenseSummary>((ref) {
  final expensesAsync = ref.watch(expensesProvider);
  final currentUser = ref.watch(firebaseAuthProvider).currentUser;

  if (currentUser == null) {
    return const ExpenseSummary(
      monthlySpending: 0,
      balance: 0,
    );
  }

  final expenses = expensesAsync.value ?? [];

  final now = DateTime.now();

  double monthlySpending = 0;
  double totalPaidByUser = 0;
  double totalUserShare = 0;

  for (final expense in expenses) {
    final createdAt = expense.createdAt;

    if (createdAt != null &&
        createdAt.year == now.year &&
        createdAt.month == now.month) {
      monthlySpending += expense.amount;
    }

    if (expense.paidBy == currentUser.uid) {
      totalPaidByUser += expense.amount;
    }

    totalUserShare += expense.splits[currentUser.uid] ?? 0;
  }

  return ExpenseSummary(
    monthlySpending: monthlySpending,
    balance: totalPaidByUser - totalUserShare,
  );
});