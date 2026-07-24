class ExpenseAnalytics {
  final double totalSpent;
  final double averageExpense;
  final double highestExpense;
  final int totalExpenses;

  final Map<String, double> categoryTotals;
  final Map<int, double> monthlyTotals;

  const ExpenseAnalytics({
    required this.totalSpent,
    required this.averageExpense,
    required this.highestExpense,
    required this.totalExpenses,
    required this.categoryTotals,
    required this.monthlyTotals,
  });
}
