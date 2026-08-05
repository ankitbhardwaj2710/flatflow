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

  for (final id in memberNames.keys) {
    balance[id] = 0;
  }

  // Expenses
  for (final expense in expenses) {
    expense.splits.forEach((memberId, share) {
      if (memberId == expense.paidBy) {
        balance[memberId] =
            (balance[memberId] ?? 0) +
                (expense.amount - share);
      } else {
        balance[memberId] =
            (balance[memberId] ?? 0) - share;
      }
    });
  }

  // Previous Settlements
  for (final settlement in settlements) {
    final from =
        (settlement['paidBy'] ??
                settlement['from'])
            ?.toString();

    final to =
        (settlement['paidTo'] ??
                settlement['to'])
            ?.toString();

    final amount =
        (settlement['amount'] as num?)
                ?.toDouble() ??
            0;

    if (from == null || to == null) continue;

    balance[from] =
        (balance[from] ?? 0) + amount;

    balance[to] =
        (balance[to] ?? 0) - amount;
  }

  final List<SettlementModel> result = [];

  for (final id in memberNames.keys) {
    if (id == currentUserId) continue;

    final myBalance =
        balance[currentUserId] ?? 0;

    final otherBalance =
        balance[id] ?? 0;

    if (myBalance < 0 &&
        otherBalance > 0) {
      final pay =
          (-myBalance < otherBalance)
              ? -myBalance
              : otherBalance;

      result.add(
        SettlementModel(
          memberId: id,
          memberName:
              memberNames[id] ?? 'Unknown',
          youOwe: pay,
          owesYou: 0,
          shouldPay: true,
          shouldReceive: false,
          isSettled: false,
        ),
      );
    } else if (myBalance > 0 &&
        otherBalance < 0) {
      final receive =
          (myBalance < -otherBalance)
              ? myBalance
              : -otherBalance;

      result.add(
        SettlementModel(
          memberId: id,
          memberName:
              memberNames[id] ?? 'Unknown',
          youOwe: 0,
          owesYou: receive,
          shouldPay: false,
          shouldReceive: true,
          isSettled: false,
        ),
      );
    }
  }

  return result;
}}