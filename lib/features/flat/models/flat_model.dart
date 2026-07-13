import 'package:cloud_firestore/cloud_firestore.dart';

class FlatModel {
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;
  final DateTime? createdAt;

  const FlatModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    this.createdAt,
  });

  factory FlatModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return FlatModel(
      id: document.id,
      name: data['name'] as String? ?? '',
      inviteCode: data['inviteCode'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}