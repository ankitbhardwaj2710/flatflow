import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/activity_model.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ActivityRepository(
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

  Future<void> addActivity({
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
        .collection('activities')
        .add({
      'type': type,
      'title': title,
      'description': description,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ActivityModel>> watchActivities() async* {
    final flatId = await _getCurrentFlatId();

    yield* _firestore
        .collection('flats')
        .doc(flatId)
        .collection('activities')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ActivityModel.fromFirestore)
              .toList(),
        );
  }
}