class DashboardStats {
  final int totalExpenses;
  final int totalMembers;
  final double totalExpenseAmount;
  final double monthlyExpense;
  final double averageExpense;

  const DashboardStats({
    required this.totalExpenses,
    required this.totalMembers,
    required this.totalExpenseAmount,
    required this.monthlyExpense,
    required this.averageExpense,
  });
}