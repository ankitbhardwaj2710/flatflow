import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_model.dart';
import 'expense_provider.dart';

enum ExpenseSort { newest, oldest, highest, lowest }

enum ExpenseDateFilter {
  all,
  thisWeek,
  thisMonth,
  lastMonth,
  last3Months,
  custom,
}

class ExpenseFilterState {
  final String search;
  final String category;
  final ExpenseSort sort;
  final ExpenseDateFilter dateFilter;

  final DateTime? startDate;
  final DateTime? endDate;

  const ExpenseFilterState({
    this.search = '',
    this.category = 'All',
    this.sort = ExpenseSort.newest,
    this.dateFilter = ExpenseDateFilter.all,
    this.startDate,
    this.endDate,
  });

  ExpenseFilterState copyWith({
    String? search,
    String? category,
    ExpenseSort? sort,
    ExpenseDateFilter? dateFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ExpenseFilterState(
      search: search ?? this.search,
      category: category ?? this.category,
      sort: sort ?? this.sort,
      dateFilter: dateFilter ?? this.dateFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class ExpenseFilterNotifier extends Notifier<ExpenseFilterState> {
  @override
  ExpenseFilterState build() {
    return const ExpenseFilterState();
  }

  void setSearch(String value) {
    state = state.copyWith(search: value.trim());
  }

  void setCategory(String value) {
    state = state.copyWith(category: value);
  }

  void setSort(ExpenseSort value) {
    state = state.copyWith(sort: value);
  }

  void setDateFilter(ExpenseDateFilter filter) {
    state = state.copyWith(dateFilter: filter);
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = state.copyWith(
      dateFilter: ExpenseDateFilter.custom,
      startDate: start,
      endDate: end,
    );
  }

  void clear() {
    state = const ExpenseFilterState();
  }
}

final expenseFilterProvider =
    NotifierProvider<ExpenseFilterNotifier, ExpenseFilterState>(
      ExpenseFilterNotifier.new,
    );

final filteredExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  final filter = ref.watch(expenseFilterProvider);

  List<ExpenseModel> filtered = List.from(expenses);

  // Search
  if (filter.search.isNotEmpty) {
    final search = filter.search.toLowerCase();

    filtered = filtered.where((expense) {
      return expense.title.toLowerCase().contains(search) ||
          expense.category.toLowerCase().contains(search);
    }).toList();
  }

  // Category
  if (filter.category != 'All') {
    filtered = filtered
        .where((expense) => expense.category == filter.category)
        .toList();
  }

  // Date Filter
  if (filter.dateFilter != ExpenseDateFilter.all) {
    final now = DateTime.now();

    filtered = filtered.where((expense) {
      final expenseDate = expense.createdAt;

      if (expenseDate == null) return false;

      switch (filter.dateFilter) {
        case ExpenseDateFilter.thisWeek:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          return expenseDate.isAfter(
                weekStart.subtract(const Duration(seconds: 1)),
              ) &&
              expenseDate.isBefore(now.add(const Duration(days: 1)));

        case ExpenseDateFilter.thisMonth:
          return expenseDate.month == now.month && expenseDate.year == now.year;

        case ExpenseDateFilter.lastMonth:
          final lastMonth = DateTime(now.year, now.month - 1);

          return expenseDate.month == lastMonth.month &&
              expenseDate.year == lastMonth.year;

        case ExpenseDateFilter.last3Months:
          final start = DateTime(now.year, now.month - 2, 1);

          return expenseDate.isAfter(
            start.subtract(const Duration(seconds: 1)),
          );

        case ExpenseDateFilter.custom:
          if (filter.startDate == null || filter.endDate == null) {
            return true;
          }

          return !expenseDate.isBefore(filter.startDate!) &&
              !expenseDate.isAfter(filter.endDate!);

        case ExpenseDateFilter.all:
          return true;
      }
    }).toList();
  }

  // Sorting
  switch (filter.sort) {
    case ExpenseSort.newest:
      filtered.sort(
        (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
          a.createdAt ?? DateTime(2000),
        ),
      );
      break;

    case ExpenseSort.oldest:
      filtered.sort(
        (a, b) => (a.createdAt ?? DateTime(2000)).compareTo(
          b.createdAt ?? DateTime(2000),
        ),
      );
      break;

    case ExpenseSort.highest:
      filtered.sort((a, b) => b.amount.compareTo(a.amount));
      break;

    case ExpenseSort.lowest:
      filtered.sort((a, b) => a.amount.compareTo(b.amount));
      break;
  }

  return filtered;
});
