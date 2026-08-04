import '../../expenses/models/expense_model.dart';
import '../models/settlement_model.dart';

class SettlementCalculator {
  static List<SettlementModel> calculate({
    required String currentUserId,
    required Map<String, String> memberNames,
    required List<ExpenseModel> expenses,
    required List<Map<String, dynamic>> settlements,
  }) {
    final Map<String, double> balance = {};

    // Initialize balances
    for (final id in memberNames.keys) {
      balance[id] = 0;
    }

    // ==========================
    // EXPENSES
    // ==========================

    for (final expense in expenses) {
      final payer = expense.paidBy;

      balance[payer] =
          (balance[payer] ?? 0) + expense.amount;

      expense.splits.forEach((memberId, amount) {
        balance[memberId] =
            (balance[memberId] ?? 0) - amount;
      });
    }

    // ==========================
    // PAID SETTLEMENTS
    // ==========================

    for (final settlement in settlements) {
  final from =
      (settlement['paidBy'] ??
       settlement['from'])?.toString();

  final to =
      (settlement['paidTo'] ??
       settlement['to'])?.toString();

  final amount =
      (settlement['amount'] as num?)?.toDouble() ?? 0;

  if (from == null || to == null) {
    continue;
  }

  balance[from] =
      (balance[from] ?? 0) + amount;

  balance[to] =
      (balance[to] ?? 0) - amount;
}

    // ==========================
    // CREATE RESULT
    // ==========================

    final List<SettlementModel> result = [];

    for (final entry in balance.entries) {
      if (entry.key == currentUserId) continue;

      final currentBalance =
          balance[currentUserId] ?? 0;

      final otherBalance = entry.value;

      if (currentBalance < 0 &&
          otherBalance > 0) {
        final amount =
            (-currentBalance < otherBalance)
                ? -currentBalance
                : otherBalance;

        result.add(
          SettlementModel(
            memberId: entry.key,
            memberName:
                memberNames[entry.key] ??
                    'Unknown',
            youOwe: amount,
            owesYou: 0,
            shouldPay: true,
            shouldReceive: false,
            isSettled: amount <= 1,
          ),
        );
      } else if (currentBalance > 0 &&
          otherBalance < 0) {
        final amount =
            (currentBalance < -otherBalance)
                ? currentBalance
                : -otherBalance;

        result.add(
          SettlementModel(
            memberId: entry.key,
            memberName:
                memberNames[entry.key] ??
                    'Unknown',
            youOwe: 0,
            owesYou: amount,
            shouldPay: false,
            shouldReceive: true,
            isSettled: amount <= 1,
          ),
        );
      }
    }

    return result;
  }
}