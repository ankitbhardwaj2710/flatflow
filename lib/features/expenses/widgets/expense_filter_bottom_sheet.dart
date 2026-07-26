import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/expense_filter_provider.dart';

class ExpenseFilterBottomSheet extends ConsumerWidget {
  const ExpenseFilterBottomSheet({super.key});

  static const categories = [
    'All',
    'Food',
    'Rent',
    'Grocery',
    'Utilities',
    'Transport',
    'Entertainment',
    'Other',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(expenseFilterProvider);
    final notifier = ref.read(expenseFilterProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: filter.category == category,
                    onSelected: (selected) {
  if (selected) {
    notifier.setCategory(category);
  }
},
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

Wrap(
  spacing: 8,
  runSpacing: 8,
  children: ExpenseDateFilter.values.map((item) {
    return ChoiceChip(
      label: Text(item.name),
      selected: filter.dateFilter == item,
      onSelected: (_) async {
        if (item == ExpenseDateFilter.custom) {
          final startDate = await showDatePicker(
            context: context,
            initialDate: filter.startDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            helpText: 'Select Start Date',
          );

          if (startDate == null) return;

          final endDate = await showDatePicker(
            context: context,
            initialDate: startDate,
            firstDate: startDate,
            lastDate: DateTime.now(),
            helpText: 'Select End Date',
          );

          if (endDate == null) return;

          notifier.setCustomDateRange(startDate, endDate);
        } else {
          notifier.setDateFilter(item);
        }
      },
    );
  }).toList(),
),
if (filter.dateFilter == ExpenseDateFilter.custom &&
    filter.startDate != null &&
    filter.endDate != null) ...[
  const SizedBox(height: 20),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Date Range',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'From : ${filter.startDate!.day}/${filter.startDate!.month}/${filter.startDate!.year}',
        ),

        const SizedBox(height: 6),

        Text(
          'To : ${filter.endDate!.day}/${filter.endDate!.month}/${filter.endDate!.year}',
        ),

        const SizedBox(height: 16),

        FilledButton.icon(
          onPressed: () async {
            final startDate = await showDatePicker(
              context: context,
              initialDate: filter.startDate!,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );

            if (startDate == null) return;

            final endDate = await showDatePicker(
              context: context,
              initialDate: filter.endDate!,
              firstDate: startDate,
              lastDate: DateTime.now(),
            );

            if (endDate == null) return;

            notifier.setCustomDateRange(
              startDate,
              endDate,
            );
          },
          icon: const Icon(Icons.edit_calendar),
          label: const Text("Change Dates"),
        ),
      ],
    ),
  ),

  const SizedBox(height: 28),
],

              const Text(
                'Sort By',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              RadioListTile<ExpenseSort>(
                value: ExpenseSort.newest,
                groupValue: filter.sort,
                title: const Text('Newest'),
                onChanged: (value) {
                  if (value != null) {
                    notifier.setSort(value);
                  }
                },
              ),

              RadioListTile<ExpenseSort>(
                value: ExpenseSort.oldest,
                groupValue: filter.sort,
                title: const Text('Oldest'),
                onChanged: (value) {
                  if (value != null) {
                    notifier.setSort(value);
                  }
                },
              ),

              RadioListTile<ExpenseSort>(
                value: ExpenseSort.highest,
                groupValue: filter.sort,
                title: const Text('Highest Amount'),
                onChanged: (value) {
                  if (value != null) {
                    notifier.setSort(value);
                  }
                },
              ),

              RadioListTile<ExpenseSort>(
                value: ExpenseSort.lowest,
                groupValue: filter.sort,
                title: const Text('Lowest Amount'),
                onChanged: (value) {
                  if (value != null) {
                    notifier.setSort(value);
                  }
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    notifier.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear Filters'),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
