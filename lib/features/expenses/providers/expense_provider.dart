import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';
import '../../home/providers/home_provider.dart';
import '../models/member_balance.dart';

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
final memberBalancesProvider =
    Provider<List<MemberBalance>>((ref) {
  final currentUser =
      ref.watch(firebaseAuthProvider).currentUser;

  final expenses =
      ref.watch(expensesProvider).value ?? [];

  final members =
      ref.watch(currentFlatMembersProvider).value ?? [];

  if (currentUser == null || members.isEmpty) {
    return [];
  }

  final currentUserId = currentUser.uid;

  final balances = <String, double>{};

  for (final member in members) {
    final memberId = member['id'] as String;

    if (memberId != currentUserId) {
      balances[memberId] = 0;
    }
  }

  for (final expense in expenses) {
    final payerId = expense.paidBy;

    for (final entry in expense.splits.entries) {
      final participantId = entry.key;
      final share = entry.value;

      // Current user paid for another member.
      if (payerId == currentUserId &&
          participantId != currentUserId) {
        balances[participantId] =
            (balances[participantId] ?? 0) + share;
      }

      // Another member paid for current user.
      if (participantId == currentUserId &&
          payerId != currentUserId) {
        balances[payerId] =
            (balances[payerId] ?? 0) - share;
      }
    }
  }

  final result = <MemberBalance>[];

  for (final member in members) {
    final memberId = member['id'] as String;

    if (memberId == currentUserId) {
      continue;
    }

    final amount = balances[memberId] ?? 0;

    // Ignore settled / tiny floating-point values.
    if (amount.abs() < 0.01) {
      continue;
    }

    result.add(
      MemberBalance(
        memberId: memberId,
        memberName:
            member['name'] as String? ?? 'Member',
        amount: amount,
      ),
    );
  }

  result.sort(
    (a, b) => b.amount.abs().compareTo(
          a.amount.abs(),
        ),
  );

  return result;
});