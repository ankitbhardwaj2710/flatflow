import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../flat/models/flat_model.dart';

final currentUserDocumentProvider =
    StreamProvider<DocumentSnapshot<Map<String, dynamic>>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;

  if (user == null) {
    throw Exception('User is not signed in.');
  }

  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots();
});

final currentFlatProvider = StreamProvider<FlatModel?>((ref) {
  final userDocument = ref.watch(currentUserDocumentProvider);

  return userDocument.when(
    data: (document) {
      final data = document.data();
      final flatId = data?['currentFlatId'] as String?;

      if (flatId == null || flatId.isEmpty) {
        return Stream.value(null);
      }

      return ref
          .watch(firestoreProvider)
          .collection('flats')
          .doc(flatId)
          .snapshots()
          .map((document) {
        if (!document.exists) {
          return null;
        }

        return FlatModel.fromFirestore(document);
      });
    },
    loading: () => Stream.value(null),
    error: (error, stackTrace) => Stream.error(error),
  );
});

final currentFlatMembersProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final userDocument = ref.watch(currentUserDocumentProvider);

  return userDocument.when(
    data: (document) {
      final data = document.data();
      final flatId = data?['currentFlatId'] as String?;

      if (flatId == null || flatId.isEmpty) {
        return Stream.value([]);
      }

      return ref
          .watch(firestoreProvider)
          .collection('flats')
          .doc(flatId)
          .collection('members')
          .orderBy('joinedAt')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (document) => {
                    'id': document.id,
                    ...document.data(),
                  },
                )
                .toList(),
          );
    },
    loading: () => Stream.value([]),
    error: (error, stackTrace) => Stream.error(error),
  );
});