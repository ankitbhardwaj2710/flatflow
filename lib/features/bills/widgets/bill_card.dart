import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// import '../../../core/theme/app_colors.dart';
import '../models/bill_model.dart';

class BillCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback onTogglePaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BillCard({
    super.key,
    required this.bill,
    required this.onTogglePaid,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');

    final dueColor = bill.isPaid
        ? Colors.green
        : bill.dueDate.isBefore(DateTime.now())
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bill.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: bill.isPaid
                        ? Colors.green.withOpacity(.12)
                        : Colors.orange.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bill.isPaid ? 'Paid' : 'Pending',
                    style: TextStyle(
                      color:
                          bill.isPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              '₹${bill.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Chip(
                  label: Text(bill.category),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: dueColor,
                ),
                const SizedBox(width: 6),
                Text(
                  formatter.format(bill.dueDate),
                  style: TextStyle(
                    color: dueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const Divider(height: 28),

            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onTogglePaid,
                    icon: Icon(
                      bill.isPaid
                          ? Icons.undo
                          : Icons.check,
                    ),
                    label: Text(
                      bill.isPaid
                          ? 'Mark Unpaid'
                          : 'Mark Paid',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),

                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  color: Colors.red,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}