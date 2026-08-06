import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../models/activity_model.dart';
import '../providers/activity_provider.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activity Timeline',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: activities.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(e.toString()),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'No activity yet',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final activity = list[index];

              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        _color(activity.type),
                    child: Icon(
                      _icon(activity.type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    activity.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(activity.description),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(
                          activity.createdAt,
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static IconData _icon(String type) {
    switch (type) {
      case 'expense':
        return Icons.payments;
      case 'bill':
        return Icons.receipt_long;
      case 'grocery':
        return Icons.shopping_cart;
      case 'settlement':
        return Icons.account_balance_wallet;
      default:
        return Icons.notifications;
    }
  }

  static Color _color(String type) {
    switch (type) {
      case 'expense':
        return Colors.red;
      case 'bill':
        return Colors.orange;
      case 'grocery':
        return Colors.green;
      case 'settlement':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static String _formatDate(
    DateTime? date,
  ) {
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    }

    if (diff.inHours < 1) {
      return '${diff.inMinutes} min ago';
    }

    if (diff.inDays < 1) {
      return '${diff.inHours} hr ago';
    }

    if (diff.inDays == 1) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}