import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../notifications/repository/app_notification_repository.dart';
import '../../expenses/models/expense_model.dart';
import '../models/settlement_model.dart';
import '../services/settlement_calculator.dart';
import '../../activity/repository/activity_repository.dart';

class SettlementRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SettlementRepository(
    this._firestore,
    this._auth,
  );

  Future<List<SettlementModel>> calculateSettlements() async {
    final user = _auth.currentUser;

    if (user == null) return [];

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final flatId =
        userDoc.data()?['currentFlatId'] as String?;

    if (flatId == null) return [];

    //==========================
    // Members
    //==========================

    final membersSnapshot = await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('members')
        .get();

    final memberNames = <String, String>{};

    for (final doc in membersSnapshot.docs) {
      memberNames[doc.id] =
          (doc.data()['name'] ?? 'Unknown')
              .toString();
    }

    //==========================
    // Expenses
    //==========================

    final expenseSnapshot = await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('expenses')
        .get();

    final expenses = expenseSnapshot.docs
        .map((e) => ExpenseModel.fromFirestore(e))
        .toList();

    //==========================
    // Settlements
    //==========================

    final settlementSnapshot =
        await _firestore
            .collection('flats')
            .doc(flatId)
            .collection('settlements')
            .get();

    final settlements = settlementSnapshot.docs
        .map((e) => e.data())
        .toList();

    return SettlementCalculator.calculate(
      currentUserId: user.uid,
      memberNames: memberNames,
      expenses: expenses,
      settlements: settlements,
    );
  }

  Future<void> markAsPaid({
    required String toUserId,
    required double amount,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final flatId =
        userDoc.data()?['currentFlatId'] as String?;

    if (flatId == null) return;

    await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('settlements')
        .add({
      'paidBy': user.uid,
      'paidTo': toUserId,
      'amount': amount,
      'status': 'paid',
      'createdAt':
          FieldValue.serverTimestamp(),
    });
    await _activityRepository.addActivity(
  type: 'settlement',
  title: 'Settlement Completed',
  description:
      'Paid ₹${amount.toStringAsFixed(2)}',
);
await _notificationRepository.addNotification(
  type: 'settlement',
  title: 'Settlement Completed',
  description:
      'Paid ₹${amount.toStringAsFixed(2)}',
);
  }
  final ActivityRepository _activityRepository =
    ActivityRepository(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
    final AppNotificationRepository _notificationRepository =
    AppNotificationRepository(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
}