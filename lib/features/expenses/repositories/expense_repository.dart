import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense_model.dart';
import '../models/settlement_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  ExpenseRepository(this._firestore, this._firebaseAuth);

  Future<String> _getCurrentFlatId() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final userDocument = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDocument.exists) {
      throw Exception('User profile not found.');
    }

    final flatId = userDocument.data()?['currentFlatId'] as String?;

    if (flatId == null || flatId.isEmpty) {
      throw Exception('No active flat found.');
    }

    return flatId;
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required List<String> splitAmong,
    String note = '',
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    if (title.trim().isEmpty) {
      throw Exception('Expense title cannot be empty.');
    }

    if (amount <= 0) {
      throw Exception('Expense amount must be greater than zero.');
    }

    if (splitAmong.isEmpty) {
      throw Exception('Select at least one member.');
    }

    final flatId = await _getCurrentFlatId();

    final splits = _calculateEqualSplits(amount: amount, memberIds: splitAmong);

    await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('expenses')
        .add({
          'title': title.trim(),
          'amount': amount,
          'category': category,
          'paidBy': paidBy,
          'splitAmong': splitAmong,
          'splits': splits,
          'note': note.trim(),
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<List<ExpenseModel>> watchExpenses() async* {
    final flatId = await _getCurrentFlatId();

    yield* _firestore
        .collection('flats')
        .doc(flatId)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(ExpenseModel.fromFirestore).toList(),
        );
  }

  Future<void> deleteExpense(String expenseId) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final flatId = await _getCurrentFlatId();

    final expenseReference = _firestore
        .collection('flats')
        .doc(flatId)
        .collection('expenses')
        .doc(expenseId);

    final expenseDocument = await expenseReference.get();

    if (!expenseDocument.exists) {
      throw Exception('Expense not found.');
    }

    final expenseData = expenseDocument.data()!;

    final createdBy = expenseData['createdBy'] as String?;

    final paidBy = expenseData['paidBy'] as String?;

    final memberDocument = await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('members')
        .doc(user.uid)
        .get();

    final role = memberDocument.data()?['role'] as String?;

    final canDelete =
        createdBy == user.uid || paidBy == user.uid || role == 'admin';

    if (!canDelete) {
      throw Exception('You do not have permission to delete this expense.');
    }

    await expenseReference.delete();
  }

  Future<void> addSettlement({
    required String paidBy,
    required String paidTo,
    required double amount,
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    if (paidBy == paidTo) {
      throw Exception('Settlement members cannot be the same.');
    }

    if (amount <= 0) {
      throw Exception('Settlement amount must be greater than zero.');
    }

    final flatId = await _getCurrentFlatId();

    await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('settlements')
        .add({
          'paidBy': paidBy,
          'paidTo': paidTo,
          'amount': amount,
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<List<SettlementModel>> watchSettlements() async* {
    final flatId = await _getCurrentFlatId();

    yield* _firestore
        .collection('flats')
        .doc(flatId)
        .collection('settlements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(SettlementModel.fromFirestore).toList(),
        );
  }

  Map<String, double> _calculateEqualSplits({
    required double amount,
    required List<String> memberIds,
  }) {
    final totalPaise = (amount * 100).round();
    final memberCount = memberIds.length;

    final baseShare = totalPaise ~/ memberCount;

    final remainingPaise = totalPaise % memberCount;

    final splits = <String, double>{};

    for (int index = 0; index < memberCount; index++) {
      final memberShare = baseShare + (index < remainingPaise ? 1 : 0);

      splits[memberIds[index]] = memberShare / 100;
    }

    return splits;
  }
}
