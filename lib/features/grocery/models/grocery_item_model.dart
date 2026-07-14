import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryItemModel {
  final String id;
  final String name;
  final String quantity;
  final bool isBought;
  final String addedBy;
  final String? boughtBy;
  final DateTime? createdAt;
  final DateTime? boughtAt;

  const GroceryItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.isBought,
    required this.addedBy,
    this.boughtBy,
    this.createdAt,
    this.boughtAt,
  });

  factory GroceryItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return GroceryItemModel(
      id: document.id,
      name: data['name'] as String? ?? '',
      quantity: data['quantity'] as String? ?? '',
      isBought: data['isBought'] as bool? ?? false,
      addedBy: data['addedBy'] as String? ?? '',
      boughtBy: data['boughtBy'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      boughtAt: (data['boughtAt'] as Timestamp?)?.toDate(),
    );
  }
}
