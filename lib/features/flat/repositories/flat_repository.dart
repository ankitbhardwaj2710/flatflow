import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/flat_model.dart';

class FlatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FlatRepository(
    this._firestore,
    this._firebaseAuth,
  );

  Future<String> createFlat({
    required String flatName,
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final userDocument =
        await _firestore.collection('users').doc(user.uid).get();

    if (!userDocument.exists) {
      throw Exception('User profile not found.');
    }

    final userData = userDocument.data()!;
    final userName = userData['name'] as String? ?? 'User';
    final userEmail = userData['email'] as String? ?? user.email ?? '';

    final flatReference = _firestore.collection('flats').doc();

    final inviteCode = await _generateUniqueInviteCode();

    final batch = _firestore.batch();

    batch.set(flatReference, {
      'name': flatName.trim(),
      'inviteCode': inviteCode,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(
      flatReference.collection('members').doc(user.uid),
      {
        'userId': user.uid,
        'name': userName,
        'email': userEmail,
        'role': 'admin',
        'joinedAt': FieldValue.serverTimestamp(),
      },
    );

    batch.update(
      _firestore.collection('users').doc(user.uid),
      {
        'currentFlatId': flatReference.id,
      },
    );

    await batch.commit();

    return flatReference.id;
  }

  Future<String> _generateUniqueInviteCode() async {
    const characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();

    for (int attempt = 0; attempt < 10; attempt++) {
      final code = List.generate(
        6,
        (_) => characters[random.nextInt(characters.length)],
      ).join();

      final query = await _firestore
          .collection('flats')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return code;
      }
    }

    throw Exception('Unable to generate a unique invite code.');
  }

  Future<FlatModel?> getFlat(String flatId) async {
    final document =
        await _firestore.collection('flats').doc(flatId).get();

    if (!document.exists) {
      return null;
    }

    return FlatModel.fromFirestore(document);
  }
}