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
        lowestExpense: 0,
        totalExpenses: 0,
        categoryTotals: {},
        monthlyTotals: {},
        weeklyTotals: {},
        paidByTotals: {},
        topCategory: null,
        topSpender: null,
        monthlyAverage: 0,
        dailyAverage: 0,
        currentMonthSpent: 0,
        previousMonthSpent: 0,
        monthlyGrowth: 0,
      );
    }

    double totalSpent = 0;
    double highestExpense = 0;
    double lowestExpense = expenses.first.amount;

    final categoryTotals = <String, double>{};
    final monthlyTotals = <int, double>{};
    final weeklyTotals = <int, double>{};
    final paidByTotals = <String, double>{};

    final uniqueDays = <DateTime>{};
    final uniqueMonths = <String>{};

    final now = DateTime.now();

    double currentMonthSpent = 0;
    double previousMonthSpent = 0;

    final previousMonth = now.month == 1 ? 12 : now.month - 1;
    final previousYear =
        now.month == 1 ? now.year - 1 : now.year;

    for (final expense in expenses) {
      totalSpent += expense.amount;

      if (expense.amount > highestExpense) {
        highestExpense = expense.amount;
      }

      if (expense.amount < lowestExpense) {
        lowestExpense = expense.amount;
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

        uniqueDays.add(
          DateTime(date.year, date.month, date.day),
        );

        uniqueMonths.add(
          '${date.year}-${date.month}',
        );

        if (date.month == now.month &&
            date.year == now.year) {
          currentMonthSpent += expense.amount;
        }

        if (date.month == previousMonth &&
            date.year == previousYear) {
          previousMonthSpent += expense.amount;
        }
      }
    }

    String? topCategory;
    if (categoryTotals.isNotEmpty) {
      topCategory = categoryTotals.entries
          .reduce(
            (a, b) => a.value > b.value ? a : b,
          )
          .key;
    }

    String? topSpender;
    if (paidByTotals.isNotEmpty) {
      topSpender = paidByTotals.entries
          .reduce(
            (a, b) => a.value > b.value ? a : b,
          )
          .key;
    }

    double monthlyGrowth = 0;

    if (previousMonthSpent > 0) {
      monthlyGrowth =
          ((currentMonthSpent - previousMonthSpent) /
                  previousMonthSpent) *
              100;
    }

    return ExpenseAnalytics(
      totalSpent: totalSpent,
      averageExpense: totalSpent / expenses.length,
      highestExpense: highestExpense,
      lowestExpense: lowestExpense,
      totalExpenses: expenses.length,
      categoryTotals: categoryTotals,
      monthlyTotals: monthlyTotals,
      weeklyTotals: weeklyTotals,
      paidByTotals: paidByTotals,
      topCategory: topCategory,
      topSpender: topSpender,
      monthlyAverage: uniqueMonths.isEmpty
          ? 0
          : totalSpent / uniqueMonths.length,
      dailyAverage: uniqueDays.isEmpty
          ? 0
          : totalSpent / uniqueDays.length,
      currentMonthSpent: currentMonthSpent,
      previousMonthSpent: previousMonthSpent,
      monthlyGrowth: monthlyGrowth,
    );
  }
}