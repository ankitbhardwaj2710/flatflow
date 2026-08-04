import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settlement_provider.dart';

class SettlementScreen extends ConsumerWidget {
  const SettlementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settlements = ref.watch(settlementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settlement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: settlements.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No settlements found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(item.memberName[0].toUpperCase()),
                  ),

                  title: Text(
                    item.memberName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.owesYou > 0)
                        Text(
                          'Will Pay You ₹${item.owesYou.toStringAsFixed(2)}',
                        ),

                      if (item.youOwe > 0)
                        Text('You Owe ₹${item.youOwe.toStringAsFixed(2)}'),

                      if (item.isSettled) const Text('Settled'),
                    ],
                  ),

                  trailing: item.shouldPay
                      ? FilledButton(
                          onPressed: () async {
                            await ref
                                .read(settlementRepositoryProvider)
                                .markAsPaid(
                                  toUserId: item.memberId,
                                  amount: item.youOwe,
                                );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Settlement saved.'),
                                ),
                              );

                              ref.invalidate(settlementProvider);
                            }
                          },
                          child: const Text('Pay'),
                        )
                      : item.shouldReceive
                      ? FilledButton.tonal(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Reminder sent to ${item.memberName}',
                                ),
                              ),
                            );
                          },
                          child: const Text('Remind'),
                        )
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
