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
      weeklyTotals: {},
      paidByTotals: {},
      topCategory: null,
      topSpender: null,
      monthlyAverage: 0,
      dailyAverage: 0,
    );
  }

  double totalSpent = 0;
  double highestExpense = 0;

  final categoryTotals = <String, double>{};
  final monthlyTotals = <int, double>{};
  final weeklyTotals = <int, double>{};
  final paidByTotals = <String, double>{};

  final uniqueDays = <DateTime>{};
  final uniqueMonths = <String>{};

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

    paidByTotals.update(
      expense.paidBy,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );

    if (expense.createdAt != null) {
      final date = expense.createdAt!;

      monthlyTotals.update(
        date.month,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );

      final week = ((date.day - 1) ~/ 7) + 1;

      weeklyTotals.update(
        week,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );

      uniqueDays.add(DateTime(date.year, date.month, date.day));
      uniqueMonths.add('${date.year}-${date.month}');
    }
  }

  String? topCategory;
  if (categoryTotals.isNotEmpty) {
    topCategory = categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String? topSpender;
  if (paidByTotals.isNotEmpty) {
    topSpender = paidByTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  return ExpenseAnalytics(
    totalSpent: totalSpent,
    averageExpense: totalSpent / expenses.length,
    highestExpense: highestExpense,
    totalExpenses: expenses.length,
    categoryTotals: categoryTotals,
    monthlyTotals: monthlyTotals,
    weeklyTotals: weeklyTotals,
    paidByTotals: paidByTotals,
    topCategory: topCategory,
    topSpender: topSpender,
    monthlyAverage:
        uniqueMonths.isEmpty ? 0 : totalSpent / uniqueMonths.length,
    dailyAverage:
        uniqueDays.isEmpty ? 0 : totalSpent / uniqueDays.length,
  );
  }
}

