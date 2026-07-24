import '../models/expense_analytics.dart';
import '../models/expense_model.dart';

class ExpenseAnalyticsService {
  const ExpenseAnalyticsService();

  ExpenseAnalytics calculate(List<ExpenseModel> expenses) {
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

    double totalSpent = 0;
    double highestExpense = 0;

    final Map<String, double> categoryTotals = {};
    final Map<int, double> monthlyTotals = {};

    for (final expense in expenses) {
      totalSpent += expense.amount;

      if (expense.amount > highestExpense) {
        highestExpense = expense.amount;
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
      totalSpent: totalSpent,
      averageExpense: totalSpent / expenses.length,
      highestExpense: highestExpense,
      totalExpenses: expenses.length,
      categoryTotals: categoryTotals,
      monthlyTotals: monthlyTotals,
    );
  }
}