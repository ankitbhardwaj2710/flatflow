import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/expense_filter_provider.dart';
import 'expense_filter_bottom_sheet.dart';

class ExpenseFilterButton extends ConsumerWidget {
  const ExpenseFilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(expenseFilterProvider);

    final activeFilters =
        (filter.category != 'All') || filter.sort != ExpenseSort.newest;

    return IconButton(
      tooltip: 'Filters',
      icon: Badge(isLabelVisible: activeFilters, child: const Icon(Icons.tune)),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => const ExpenseFilterBottomSheet(),
        );
      },
    );
  }
}
