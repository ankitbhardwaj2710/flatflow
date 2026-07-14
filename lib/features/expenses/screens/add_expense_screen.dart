import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../home/providers/home_provider.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() =>
      _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final List<String> _categories = [
    'Grocery',
    'Food',
    'Rent',
    'Utilities',
    'Transport',
    'Entertainment',
    'Other',
  ];

  String _selectedCategory = 'Grocery';
  String? _paidBy;
  final Set<String> _selectedMemberIds = {};

  bool _isLoading = false;
  bool _membersInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _amount {
    return double.tryParse(_amountController.text.trim()) ?? 0;
  }

  void _initializeMembers(
    List<Map<String, dynamic>> members,
  ) {
    if (_membersInitialized || members.isEmpty) return;

    _membersInitialized = true;

    _paidBy = members.first['id'] as String?;

    _selectedMemberIds.addAll(
      members
          .map((member) => member['id'] as String?)
          .whereType<String>(),
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (_paidBy == null) {
      _showMessage('Please select who paid.');
      return;
    }

    if (_selectedMemberIds.isEmpty) {
      _showMessage('Select at least one member to split with.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(expenseRepositoryProvider).addExpense(
            title: _titleController.text,
            amount: _amount,
            category: _selectedCategory,
            paidBy: _paidBy!,
            splitAmong: _selectedMemberIds.toList(),
            note: _noteController.text,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully!'),
        ),
      );

      context.pop();
    } catch (error) {
      if (!mounted) return;

      String message = error.toString();

      if (message.startsWith('Exception: ')) {
        message = message.replaceFirst('Exception: ', '');
      }

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(currentFlatMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: membersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => const Center(
          child: Text('Unable to load flat members.'),
        ),
        data: (members) {
          if (members.isEmpty) {
            return const Center(
              child: Text('No flat members found.'),
            );
          }

          _initializeMembers(members);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              40,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Expense title',
                      hintText: 'e.g. Monthly groceries',
                      prefixIcon: Icon(
                        Icons.receipt_long_outlined,
                      ),
                    ),
                    validator: (value) {
                      final title = value?.trim() ?? '';

                      if (title.length < 2) {
                        return 'Please enter an expense title';
                      }

                      if (title.length > 60) {
                        return 'Expense title is too long';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      hintText: '0.00',
                      prefixText: '₹ ',
                      prefixIcon: Icon(
                        Icons.currency_rupee_rounded,
                      ),
                    ),
                    validator: (value) {
                      final amount =
                          double.tryParse(value?.trim() ?? '');

                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Category',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.category_outlined,
                      ),
                    ),
                    items: _categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Paid by',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _paidBy,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                    ),
                    items: members.map((member) {
                      final id = member['id'] as String;
                      final name =
                          member['name'] as String? ?? 'Member';

                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _paidBy = value;
                      });
                    },
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Split among',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (_selectedMemberIds.length ==
                                members.length) {
                              _selectedMemberIds.clear();
                            } else {
                              _selectedMemberIds
                                ..clear()
                                ..addAll(
                                  members.map(
                                    (member) =>
                                        member['id'] as String,
                                  ),
                                );
                            }
                          });
                        },
                        child: Text(
                          _selectedMemberIds.length == members.length
                              ? 'Clear all'
                              : 'Select all',
                        ),
                      ),
                    ],
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: members.map((member) {
                        final id = member['id'] as String;
                        final name =
                            member['name'] as String? ?? 'Member';

                        final isSelected =
                            _selectedMemberIds.contains(id);

                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          secondary: CircleAvatar(
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedMemberIds.add(id);
                              } else {
                                _selectedMemberIds.remove(id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  if (_amount > 0 &&
                      _selectedMemberIds.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SplitPreview(
                      amount: _amount,
                      memberCount: _selectedMemberIds.length,
                    ),
                  ],

                  const SizedBox(height: 28),

                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    maxLength: 200,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      hintText: 'Add any details...',
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _saveExpense,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Expense',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SplitPreview extends StatelessWidget {
  final double amount;
  final int memberCount;

  const _SplitPreview({
    required this.amount,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    final approximateShare = amount / memberCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            Icons.call_split_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Split equally between $memberCount '
              '${memberCount == 1 ? 'person' : 'people'}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '₹${approximateShare.toStringAsFixed(2)} each',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}