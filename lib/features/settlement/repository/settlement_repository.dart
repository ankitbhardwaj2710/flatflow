import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../expenses/models/expense_model.dart';
import '../models/settlement_model.dart';

class SettlementRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SettlementRepository(
    this._firestore,
    this._auth,
  );

  Future<List<SettlementModel>> calculateSettlements() async {
    final user = _auth.currentUser;

    if (user == null) {
      return [];
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final flatId =
        userDoc.data()?['currentFlatId'];

    if (flatId == null) {
      return [];
    }

    final membersSnapshot = await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('members')
        .get();

    final expenseSnapshot = await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('expenses')
        .get();

    final members = membersSnapshot.docs;

    final expenses = expenseSnapshot.docs
        .map((e) => ExpenseModel.fromFirestore(e))
        .toList();

    final List<SettlementModel> settlements = [];

    for (final member in members) {
      if (member.id == user.uid) continue;

      final memberName =
          member.data()['name'] ?? 'Member';

      double owesYou = 0;
      double youOwe = 0;

      for (final expense in expenses) {
        final split =
            expense.splits[member.id] ?? 0;

        if (expense.paidBy == user.uid) {
          owesYou += split;
        }

        if (expense.paidBy == member.id) {
          youOwe +=
              expense.splits[user.uid] ?? 0;
        }
      }

      settlements.add(
        SettlementModel(
          memberId: member.id,
          memberName: memberName,
          owesYou: owesYou,
          youOwe: youOwe,
        ),
      );
    }

    return settlements;
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
      userDoc.data()?['currentFlatId'];

  if (flatId == null) return;

  await _firestore
      .collection('flats')
      .doc(flatId)
      .collection('settlements')
      .add({
    'from': user.uid,
    'to': toUserId,
    'amount': amount,
    'status': 'paid',
    'createdAt':
        FieldValue.serverTimestamp(),
  });
}
}