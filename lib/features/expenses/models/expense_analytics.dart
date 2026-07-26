class ExpenseAnalytics {
  final double totalSpent;
  final double averageExpense;
  final double highestExpense;
  final double lowestExpense;

  final int totalExpenses;

  final Map<String, double> categoryTotals;
  final Map<int, double> monthlyTotals;
  final Map<int, double> weeklyTotals;
  final Map<String, double> paidByTotals;

  final String? topCategory;
  final String? topSpender;

  final double monthlyAverage;
  final double dailyAverage;

  // New Metrics
  final double currentMonthSpent;
  final double previousMonthSpent;
  final double monthlyGrowth;

  const ExpenseAnalytics({
    required this.totalSpent,
    required this.averageExpense,
    required this.highestExpense,
    required this.lowestExpense,
    required this.totalExpenses,
    required this.categoryTotals,
    required this.monthlyTotals,
    required this.weeklyTotals,
    required this.paidByTotals,
    required this.topCategory,
    required this.topSpender,
    required this.monthlyAverage,
    required this.dailyAverage,
    required this.currentMonthSpent,
    required this.previousMonthSpent,
    required this.monthlyGrowth,
  });
}