import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_notification_model.dart';

class AppNotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AppNotificationRepository(
    this._firestore,
    this._auth,
  );

  Future<String> _getCurrentFlatId() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final flatId =
        userDoc.data()?['currentFlatId'] as String?;

    if (flatId == null) {
      throw Exception('No flat found');
    }

    return flatId;
  }

  Future<void> addNotification({
    required String type,
    required String title,
    required String description,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;

    final flatId = await _getCurrentFlatId();

    await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('notifications')
        .add({
      'type': type,
      'title': title,
      'description': description,
      'isRead': false,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppNotificationModel>> watchNotifications() async* {
    final flatId = await _getCurrentFlatId();

    yield* _firestore
        .collection('flats')
        .doc(flatId)
        .collection('notifications')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(AppNotificationModel.fromFirestore)
              .toList(),
        );
  }

  Future<void> markAsRead(
    String notificationId,
  ) async {
    final flatId = await _getCurrentFlatId();

    await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead() async {
    final flatId = await _getCurrentFlatId();

    final snapshot = await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
      });
    }

    await batch.commit();
  }

  Future<void> deleteNotification(
    String notificationId,
  ) async {
    final flatId = await _getCurrentFlatId();

    await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}