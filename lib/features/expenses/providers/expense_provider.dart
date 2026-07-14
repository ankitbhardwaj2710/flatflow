import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../models/expense_model.dart';
import '../models/member_balance.dart';
import '../models/settlement_model.dart';
import '../repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final expensesProvider = StreamProvider<List<ExpenseModel>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchExpenses();
});

final settlementsProvider = StreamProvider<List<SettlementModel>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchSettlements();
});

class ExpenseSummary {
  final double monthlySpending;
  final double balance;

  const ExpenseSummary({required this.monthlySpending, required this.balance});
}

final expenseSummaryProvider = Provider<ExpenseSummary>((ref) {
  final expensesAsync = ref.watch(expensesProvider);
  final settlementsAsync = ref.watch(settlementsProvider);
  final currentUser = ref.watch(firebaseAuthProvider).currentUser;

  if (currentUser == null) {
    return const ExpenseSummary(monthlySpending: 0, balance: 0);
  }

  final expenses = expensesAsync.value ?? [];
  final settlements = settlementsAsync.value ?? [];

  final now = DateTime.now();

  double monthlySpending = 0;
  double totalPaidByUser = 0;
  double totalUserShare = 0;

  // Calculate expense totals.
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

  // Adjust balance using settlements.
  double settlementAdjustment = 0;

  for (final settlement in settlements) {
    // Someone paid the current user.
    // The amount the current user should receive decreases.
    if (settlement.paidTo == currentUser.uid) {
      settlementAdjustment -= settlement.amount;
    }

    // Current user paid someone else.
    // The amount the current user owes decreases.
    if (settlement.paidBy == currentUser.uid) {
      settlementAdjustment += settlement.amount;
    }
  }

  return ExpenseSummary(
    monthlySpending: monthlySpending,
    balance: totalPaidByUser - totalUserShare + settlementAdjustment,
  );
});

final memberBalancesProvider = Provider<List<MemberBalance>>((ref) {
  final currentUser = ref.watch(firebaseAuthProvider).currentUser;

  final expenses = ref.watch(expensesProvider).value ?? [];

  final settlements = ref.watch(settlementsProvider).value ?? [];

  final members = ref.watch(currentFlatMembersProvider).value ?? [];

  if (currentUser == null || members.isEmpty) {
    return [];
  }

  final currentUserId = currentUser.uid;

  final balances = <String, double>{};

  // Initialize every other flat member with zero balance.
  for (final member in members) {
    final memberId = member['id'] as String;

    if (memberId != currentUserId) {
      balances[memberId] = 0;
    }
  }

  // Calculate balances created by expenses.
  for (final expense in expenses) {
    final payerId = expense.paidBy;

    for (final entry in expense.splits.entries) {
      final participantId = entry.key;
      final share = entry.value;

      // Current user paid for another member.
      if (payerId == currentUserId && participantId != currentUserId) {
        balances[participantId] = (balances[participantId] ?? 0) + share;
      }

      // Another member paid for the current user.
      if (participantId == currentUserId && payerId != currentUserId) {
        balances[payerId] = (balances[payerId] ?? 0) - share;
      }
    }
  }

  // Apply settlement transactions.
  for (final settlement in settlements) {
    // Another member paid the current user.
    // That member now owes the current user less.
    if (settlement.paidTo == currentUserId &&
        settlement.paidBy != currentUserId) {
      balances[settlement.paidBy] =
          (balances[settlement.paidBy] ?? 0) - settlement.amount;
    }

    // Current user paid another member.
    // Current user now owes that member less.
    if (settlement.paidBy == currentUserId &&
        settlement.paidTo != currentUserId) {
      balances[settlement.paidTo] =
          (balances[settlement.paidTo] ?? 0) + settlement.amount;
    }
  }

  final result = <MemberBalance>[];

  for (final member in members) {
    final memberId = member['id'] as String;

    if (memberId == currentUserId) {
      continue;
    }

    final amount = balances[memberId] ?? 0;

    // Ignore settled balances and tiny floating-point differences.
    if (amount.abs() < 0.01) {
      continue;
    }

    result.add(
      MemberBalance(
        memberId: memberId,
        memberName: member['name'] as String? ?? 'Member',
        amount: amount,
      ),
    );
  }

  // Show the largest pending balances first.
  result.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));

  return result;
});
