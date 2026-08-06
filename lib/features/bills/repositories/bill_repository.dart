import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/notifications/notification_constants.dart';
import '../models/bill_model.dart';
import '../../activity/repository/activity_repository.dart';

class BillRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  BillRepository(this._firestore, this._firebaseAuth);

  Future<String> _getCurrentFlatId() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final userDocument =
        await _firestore.collection('users').doc(user.uid).get();

    if (!userDocument.exists) {
      throw Exception('User profile not found.');
    }

    final flatId = userDocument.data()?['currentFlatId'] as String?;

    if (flatId == null || flatId.isEmpty) {
      throw Exception('No active flat found.');
    }

    return flatId;
  }

  Future<void> addBill({
    required String title,
    required double amount,
    required String category,
    required DateTime dueDate,
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    if (title.trim().isEmpty) {
      throw Exception('Bill title cannot be empty.');
    }

    if (amount <= 0) {
      throw Exception('Amount must be greater than zero.');
    }

    final flatId = await _getCurrentFlatId();

    final document = _firestore
    .collection('flats')
    .doc(flatId)
    .collection('bills')
    .doc();

await document.set({
      'title': title.trim(),
      'amount': amount,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': false,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await NotificationService.instance.scheduleNotification(
  id: NotificationConstants.billNotificationOffset +
      document.id.hashCode.abs(),
  title: 'Bill Reminder',
  body: '$title is due today.',
  scheduledDate: dueDate,
);
await NotificationService.instance.printPendingNotifications();
await NotificationService.instance.showInstantNotification(
  id: 999,
  title: 'Test Notification',
  body: 'Instant notification works',
);
await _activityRepository.addActivity(
  type: 'bill',
  title: 'Bill Added',
  description:
      '$title • ₹${amount.toStringAsFixed(2)}',
);
  }

  Future<void> updateBill({
    required String billId,
    required String title,
    required double amount,
    required String category,
    required DateTime dueDate,
  }) async {
    final flatId = await _getCurrentFlatId();

    await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('bills')
        .doc(billId)
        .update({
      'title': title.trim(),
      'amount': amount,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await NotificationService.instance.cancelNotification(
  NotificationConstants.billNotificationOffset +
      billId.hashCode.abs(),
);

await NotificationService.instance.scheduleNotification(
  id: NotificationConstants.billNotificationOffset +
      billId.hashCode.abs(),
  title: 'Bill Reminder',
  body: '$title is due now.',
  scheduledDate: dueDate,
);
await NotificationService.instance.showInstantNotification(
  id: 999,
  title: 'Test Notification',
  body: 'Instant notification works',
);
  }

 Future<void> togglePaid({
  required String billId,
  required bool isPaid,
}) async {
  final flatId = await _getCurrentFlatId();

  await _firestore
      .collection('flats')
      .doc(flatId)
      .collection('bills')
      .doc(billId)
      .update({
    'isPaid': isPaid,
  });

  if (isPaid) {
    await NotificationService.instance.cancelNotification(
      NotificationConstants.billNotificationOffset +
          billId.hashCode.abs(),
    );
  }
}
 Future<void> deleteBill(String billId) async {
  final user = _firebaseAuth.currentUser;

  if (user == null) {
    throw Exception('User is not signed in.');
  }

  final flatId = await _getCurrentFlatId();

  final memberDocument = await _firestore
      .collection('flats')
      .doc(flatId)
      .collection('members')
      .doc(user.uid)
      .get();

  final role = memberDocument.data()?['role'] as String?;

  if (role != 'admin') {
    throw Exception('Only the flat admin can delete bills.');
  }

  await NotificationService.instance.cancelNotification(
    NotificationConstants.billNotificationOffset +
        billId.hashCode.abs(),
  );

  await _firestore
      .collection('flats')
      .doc(flatId)
      .collection('bills')
      .doc(billId)
      .delete();
}

  Stream<List<BillModel>> watchBills() async* {
    final flatId = await _getCurrentFlatId();

    yield* _firestore
        .collection('flats')
        .doc(flatId)
        .collection('bills')
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(BillModel.fromFirestore).toList(),
        );
  }
  final ActivityRepository _activityRepository =
    ActivityRepository(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
}