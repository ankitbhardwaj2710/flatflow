import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/expense_filter_provider.dart';
import 'expense_filter_bottom_sheet.dart';

class ExpenseFilterButton extends ConsumerWidget {
  const ExpenseFilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(expenseFilterProvider);

    int activeFilters = 0;

    if (filter.category != 'All') activeFilters++;

    if (filter.sort != ExpenseSort.newest) activeFilters++;

    if (filter.dateFilter != ExpenseDateFilter.all) activeFilters++;

    if (filter.search.isNotEmpty) activeFilters++;

    return Badge(
      isLabelVisible: activeFilters > 0,
      label: Text(activeFilters.toString()),
      offset: const Offset(-2, 2),
      backgroundColor: Colors.red,
      textColor: Colors.white,
      child: IconButton(
        tooltip: 'Filters',
        icon: const Icon(Icons.tune_rounded),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => const ExpenseFilterBottomSheet(),
          );
        },
      ),
    );
  }
}