import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/bill_provider.dart';
// import '../repositories/bill_repository.dart';
import '../widgets/bill_card.dart';
import 'add_bill_screen.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billsProvider);
    final summary = ref.watch(billSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bills'), centerTitle: true),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBillScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Bill'),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(billsProvider);
          await ref.read(billsProvider.future);
        },

        child: Column(
          children: [
            /// Summary Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total',
                      value: summary.totalBills.toString(),
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _SummaryCard(
                      title: 'Pending',
                      value: summary.unpaidBills.toString(),
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _SummaryCard(
                      title: 'Paid',
                      value: summary.paidBills.toString(),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.currency_rupee),
                  title: const Text('Pending Amount'),
                  subtitle: Text(
                    '₹${summary.unpaidAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: billsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),

                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error.toString(), textAlign: TextAlign.center),
                  ),
                ),

                data: (bills) {
                  if (bills.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 70),

                          SizedBox(height: 16),

                          Text(
                            'No bills added yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text('Tap the + button to add your first bill.'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: bills.length,
                    itemBuilder: (context, index) {
                      final bill = bills[index];

                      return BillCard(
                        bill: bill,

                        onTogglePaid: () async {
                          await ref
                              .read(billRepositoryProvider)
                              .togglePaid(
                                billId: bill.id,
                                isPaid: !bill.isPaid,
                              );
                        },

                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddBillScreen(bill: bill),
                            ),
                          );
                        },
                        onDelete: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Delete Bill'),
                              content: const Text(
                                'Are you sure you want to delete this bill?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete != true) return;

                          try {
                            await ref
                                .read(billRepositoryProvider)
                                .deleteBill(bill.id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bill deleted successfully'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
