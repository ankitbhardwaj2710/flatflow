import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../providers/expense_filter_provider.dart';
import '../widgets/expense_search_bar.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final filteredExpenses = ref.watch(filteredExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenses',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorView(
          onRetry: () {
            ref.invalidate(expensesProvider);
          },
        ),
        data: (expenses) {
          final expenses = filteredExpenses;

if (expenses.isEmpty) {
  return const _EmptyExpensesView();
}

final totalAmount = expenses.fold<double>(
  0,
  (total, expense) => total + expense.amount,
);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(expensesProvider);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                _TotalExpenseCard(
                  totalAmount: totalAmount,
                  expenseCount: expenses.length,
                ),
                const SizedBox(height: 24),

const ExpenseSearchBar(),

const SizedBox(height: 28),
                const SizedBox(height: 28),
                Text(
                  'Recent expenses',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                ...expenses.map(
                  (expense) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ExpenseCard(
                      expense: expense,
                      onTap: () {
                        context.push('/expense-details', extra: expense);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TotalExpenseCard extends StatelessWidget {
  final double totalAmount;
  final int expenseCount;

  const _TotalExpenseCard({
    required this.totalAmount,
    required this.expenseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total expenses',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_formatAmount(totalAmount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$expenseCount '
            '${expenseCount == 1 ? 'expense' : 'expenses'} recorded',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onTap;

  const _ExpenseCard({required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryData = _getCategoryData(expense.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: categoryData.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(categoryData.icon, color: categoryData.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _buildSubtitle(expense),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '₹${_formatAmount(expense.amount)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(ExpenseModel expense) {
    final date = expense.createdAt;

    if (date == null) {
      return expense.category;
    }

    return '${expense.category} • '
        '${DateFormat('dd MMM, hh:mm a').format(date)}';
  }
}

class _EmptyExpensesView extends StatelessWidget {
  const _EmptyExpensesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No expenses yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the + button to add your first shared expense.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 16),
            const Text('Unable to load expenses.', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final IconData icon;
  final Color color;

  const _CategoryData({required this.icon, required this.color});
}

_CategoryData _getCategoryData(String category) {
  switch (category.toLowerCase()) {
    case 'grocery':
      return const _CategoryData(
        icon: Icons.shopping_cart_outlined,
        color: Colors.green,
      );

    case 'food':
      return const _CategoryData(
        icon: Icons.restaurant_outlined,
        color: Colors.orange,
      );

    case 'rent':
      return const _CategoryData(
        icon: Icons.home_outlined,
        color: Colors.indigo,
      );

    case 'utilities':
      return const _CategoryData(
        icon: Icons.bolt_outlined,
        color: Colors.amber,
      );

    case 'transport':
      return const _CategoryData(
        icon: Icons.directions_car_outlined,
        color: Colors.blue,
      );

    case 'entertainment':
      return const _CategoryData(
        icon: Icons.movie_outlined,
        color: Colors.purple,
      );

    default:
      return const _CategoryData(
        icon: Icons.receipt_outlined,
        color: AppColors.primary,
      );
  }
}

String _formatAmount(double amount) {
  if (amount == amount.roundToDouble()) {
    return amount.toStringAsFixed(0);
  }

  return amount.toStringAsFixed(2);
}
