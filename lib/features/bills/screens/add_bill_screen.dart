import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bill_model.dart';
import '../providers/bill_provider.dart';

class AddBillScreen extends ConsumerStatefulWidget {
  final BillModel? bill;

  const AddBillScreen({
    super.key,
    this.bill,
  });

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  bool _isSaving = false;

  late DateTime _dueDate;
  late TimeOfDay _dueTime;

  final List<String> _categories = [
    'Electricity',
    'Water',
    'Internet',
    'Gas',
    'Maintenance',
    'Rent',
    'Other',
  ];

  late String _selectedCategory;

  bool get isEditing => widget.bill != null;

  @override
  void initState() {
    super.initState();

    final bill = widget.bill;

    _titleController =
        TextEditingController(text: bill?.title ?? '');

    _amountController = TextEditingController(
      text: bill?.amount.toString() ?? '',
    );

    _selectedCategory =
        bill?.category ?? _categories.first;

    _dueDate = bill?.dueDate ?? DateTime.now();

    _dueTime = TimeOfDay(
      hour: _dueDate.hour,
      minute: _dueDate.minute,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );

    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    try {
      final repository =
          ref.read(billRepositoryProvider);

      if (isEditing) {
        await repository.updateBill(
          billId: widget.bill!.id,
          title: _titleController.text.trim(),
          amount: double.parse(
            _amountController.text,
          ),
          category: _selectedCategory,
          dueDate: dueDateTime,
        );
      } else {
        await repository.addBill(
          title: _titleController.text.trim(),
          amount: double.parse(
            _amountController.text,
          ),
          category: _selectedCategory,
          dueDate: dueDateTime,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Bill' : 'Add Bill',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Bill Title',
                prefixIcon: Icon(Icons.receipt_long),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter bill title';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter amount';
                }

                final amount =
                    double.tryParse(value);

                if (amount == null ||
                    amount <= 0) {
                  return 'Enter a valid amount';
                }

                return null;
              },
            ),
                        const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
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
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Due Date'),
              subtitle: Text(
                '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
              ),
              trailing: FilledButton.tonal(
                onPressed: _pickDate,
                child: const Text('Select'),
              ),
            ),

            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Due Time'),
              subtitle: Text(
                _dueTime.format(context),
              ),
              trailing: FilledButton.tonal(
                onPressed: _pickTime,
                child: const Text('Select'),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveBill,
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing
                            ? 'Update Bill'
                            : 'Add Bill',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}