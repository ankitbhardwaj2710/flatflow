import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlatRepository {
  FlatRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<String> getCurrentFlatId() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    final userDoc =
        await _firestore.collection('users').doc(user.uid).get();

    final flatId = userDoc.data()?['currentFlatId'] as String?;

    if (flatId == null) {
      throw Exception("No flat found.");
    }

    return flatId;
  }

  Future<void> renameFlat(String newName) async {
    final flatId = await getCurrentFlatId();

    await _firestore.collection('flats').doc(flatId).update({
      'name': newName,
    });
  }

  Future<void> transferAdmin({
    required String newAdminId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    final flatId = await getCurrentFlatId();

    await _firestore.runTransaction((transaction) async {
      final currentAdminRef = _firestore
          .collection('flats')
          .doc(flatId)
          .collection('members')
          .doc(user.uid);

      final newAdminRef = _firestore
          .collection('flats')
          .doc(flatId)
          .collection('members')
          .doc(newAdminId);

      transaction.update(currentAdminRef, {
        'role': 'member',
      });

      transaction.update(newAdminRef, {
        'role': 'admin',
      });
    });
  }
}