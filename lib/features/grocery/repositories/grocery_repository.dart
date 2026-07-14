import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/grocery_item_model.dart';

class GroceryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  GroceryRepository(this._firestore, this._firebaseAuth);

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

  Future<void> addItem({required String name, String quantity = ''}) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final trimmedName = name.trim();
    final trimmedQuantity = quantity.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Item name cannot be empty.');
    }

    if (trimmedName.length > 60) {
      throw Exception('Item name is too long.');
    }

    final flatId = await _getCurrentFlatId();

    await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('groceryItems')
        .add({
          'name': trimmedName,
          'quantity': trimmedQuantity,
          'isBought': false,
          'addedBy': user.uid,
          'boughtBy': null,
          'createdAt': FieldValue.serverTimestamp(),
          'boughtAt': null,
        });
  }

  Stream<List<GroceryItemModel>> watchItems() async* {
    final flatId = await _getCurrentFlatId();

    yield* _firestore
        .collection('flats')
        .doc(flatId)
        .collection('groceryItems')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(GroceryItemModel.fromFirestore).toList(),
        );
  }

  Future<void> toggleBought(GroceryItemModel item) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final flatId = await _getCurrentFlatId();

    final newBoughtStatus = !item.isBought;

    await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('groceryItems')
        .doc(item.id)
        .update({
          'isBought': newBoughtStatus,
          'boughtBy': newBoughtStatus ? user.uid : null,
          'boughtAt': newBoughtStatus ? FieldValue.serverTimestamp() : null,
        });
  }

  Future<void> deleteItem(String itemId) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final flatId = await _getCurrentFlatId();

    final itemReference = _firestore
        .collection('flats')
        .doc(flatId)
        .collection('groceryItems')
        .doc(itemId);

    final itemDocument = await itemReference.get();

    if (!itemDocument.exists) {
      throw Exception('Grocery item not found.');
    }

    final itemData = itemDocument.data()!;

    final addedBy = itemData['addedBy'] as String?;

    final memberDocument = await _firestore
        .collection('flats')
        .doc(flatId)
        .collection('members')
        .doc(user.uid)
        .get();

    final role = memberDocument.data()?['role'] as String?;

    final canDelete = addedBy == user.uid || role == 'admin';

    if (!canDelete) {
      throw Exception(
        'Only the item creator or flat admin can delete this item.',
      );
    }

    await itemReference.delete();
  }
}
