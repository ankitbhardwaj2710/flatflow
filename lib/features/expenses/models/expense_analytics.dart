class ExpenseAnalytics {
  final double totalSpent;
  final double averageExpense;
  final double highestExpense;
  final int totalExpenses;

  final Map<String, double> categoryTotals;
  final Map<int, double> monthlyTotals;
  final Map<int, double> weeklyTotals;
  final Map<String, double> paidByTotals;

  final String? topCategory;
  final String? topSpender;

  final double monthlyAverage;
  final double dailyAverage;

  const ExpenseAnalytics({
    required this.totalSpent,
    required this.averageExpense,
    required this.highestExpense,
    required this.totalExpenses,
    required this.categoryTotals,
    required this.monthlyTotals,
    required this.weeklyTotals,
    required this.paidByTotals,
    required this.topCategory,
    required this.topSpender,
    required this.monthlyAverage,
    required this.dailyAverage,
  });
}