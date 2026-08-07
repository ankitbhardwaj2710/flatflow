import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification_model.dart';
import '../repository/app_notification_repository.dart';

final appNotificationRepositoryProvider =
    Provider<AppNotificationRepository>(
  (ref) => AppNotificationRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  ),
);

final appNotificationsProvider =
    StreamProvider<List<AppNotificationModel>>(
  (ref) {
    return ref
        .read(appNotificationRepositoryProvider)
        .watchNotifications();
  },
);

final unreadNotificationCountProvider =
    Provider<int>((ref) {
  final notifications =
      ref.watch(appNotificationsProvider);

  return notifications.maybeWhen(
    data: (list) => list
        .where((e) => !e.isRead)
        .length,
    orElse: () => 0,
  );
});