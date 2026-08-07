import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications =
        ref.watch(appNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref
                  .read(
                    appNotificationRepositoryProvider,
                  )
                  .markAllAsRead();
            },
            child: const Text(
              'Read All',
            ),
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder:
                (context, index) {
              final item = list[index];

              return Dismissible(
                key: ValueKey(item.id),
                background:
                    Container(
                  alignment:
                      Alignment.centerRight,
                  color: Colors.red,
                  padding:
                      const EdgeInsets.only(
                    right: 20,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) async {
                  await ref
                      .read(
                        appNotificationRepositoryProvider,
                      )
                      .deleteNotification(
                        item.id,
                      );
                },
                child: Card(
                  color: item.isRead
                      ? null
                      : Colors.blue
                          .withOpacity(
                            .08,
                          ),
                  child: ListTile(
                    leading:
                        CircleAvatar(
                      backgroundColor:
                          _color(
                        item.type,
                      ),
                      child: Icon(
                        _icon(
                          item.type,
                        ),
                        color:
                            Colors.white,
                      ),
                    ),

                    title: Text(
                      item.title,
                      style:
                          TextStyle(
                        fontWeight:
                            item.isRead
                                ? FontWeight
                                    .normal
                                : FontWeight
                                    .bold,
                      ),
                    ),

                    subtitle:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          item.description,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          _time(
                            item.createdAt,
                          ),
                          style:
                              const TextStyle(
                            fontSize:
                                12,
                          ),
                        ),
                      ],
                    ),

                    trailing:
                        item.isRead
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.mark_email_read,
                                ),
                                onPressed:
                                    () async {
                                  await ref
                                      .read(
                                        appNotificationRepositoryProvider,
                                      )
                                      .markAsRead(
                                        item.id,
                                      );
                                },
                              ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static IconData _icon(
    String type,
  ) {
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

  static Color _color(
    String type,
  ) {
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

  static String _time(
    DateTime? date,
  ) {
    if (date == null) {
      return '';
    }

    final diff =
        DateTime.now().difference(date);

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