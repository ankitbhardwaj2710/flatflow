import '../../expenses/models/expense_model.dart';
import '../../bills/models/bill_model.dart';
import '../models/insight_model.dart';

class InsightService {
  List<InsightModel> generateInsights({
    required List<ExpenseModel> expenses,
    required List<BillModel> bills,
    required List<Map<String, dynamic>> members,
  }) {
    final List<InsightModel> insights = [];

    //---------------------------------------
    // Total Expense
    //---------------------------------------

    final totalExpense = expenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    insights.add(
      InsightModel(
        title: 'Total Expenses',
        value: '₹${totalExpense.toStringAsFixed(0)}',
        subtitle: 'Total money spent',
        icon: '💸',
        isPositive: false,
      ),
    );

    //---------------------------------------
    // Pending Bills
    //---------------------------------------

    final pendingBills =
        bills.where((e) => !e.isPaid).toList();

    final pendingAmount =
        pendingBills.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    insights.add(
      InsightModel(
        title: 'Pending Bills',
        value: '₹${pendingAmount.toStringAsFixed(0)}',
        subtitle:
            '${pendingBills.length} bill(s) pending',
        icon: '⚠',
        isPositive: pendingBills.isEmpty,
      ),
    );

    //---------------------------------------
    // Highest Category
    //---------------------------------------

    final categoryMap = <String, double>{};

    for (final expense in expenses) {
      categoryMap.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    if (categoryMap.isNotEmpty) {
      final highest = categoryMap.entries.reduce(
        (a, b) =>
            a.value > b.value ? a : b,
      );

      insights.add(
        InsightModel(
          title: 'Highest Category',
          value: highest.key,
          subtitle:
              '₹${highest.value.toStringAsFixed(0)} spent',
          icon: '🛒',
          isPositive: false,
        ),
      );
    }

    //---------------------------------------
    // Top Spender
    //---------------------------------------

    final memberNames = <String, String>{};

    for (final member in members) {
      memberNames[member['id']] =
          member['name'] ?? 'Unknown';
    }

    final spendMap = <String, double>{};

    for (final expense in expenses) {
      spendMap.update(
        expense.paidBy,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    if (spendMap.isNotEmpty) {
      final highest = spendMap.entries.reduce(
        (a, b) =>
            a.value > b.value ? a : b,
      );

      insights.add(
        InsightModel(
          title: 'Top Spender',
          value:
              memberNames[highest.key] ??
                  'Unknown',
          subtitle:
              '₹${highest.value.toStringAsFixed(0)} spent',
          icon: '👤',
          isPositive: true,
        ),
      );
    }

    //---------------------------------------
    // Smart Tip
    //---------------------------------------

    if (categoryMap.isNotEmpty) {
      final highest = categoryMap.entries.reduce(
        (a, b) =>
            a.value > b.value ? a : b,
      );

      insights.add(
        InsightModel(
          title: 'Smart Tip',
          value: highest.key,
          subtitle:
              'Consider reducing ${highest.key.toLowerCase()} expenses.',
          icon: '💡',
          isPositive: true,
        ),
      );
    }

    return insights;
  }
}