import 'package:cloud_firestore/cloud_firestore.dart';

class SettlementModel {
  final String id;
  final String paidBy;
  final String paidTo;
  final double amount;
  final String createdBy;
  final DateTime? createdAt;

  const SettlementModel({
    required this.id,
    required this.paidBy,
    required this.paidTo,
    required this.amount,
    required this.createdBy,
    this.createdAt,
  });

  factory SettlementModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return SettlementModel(
      id: document.id,
      paidBy: data['paidBy'] as String? ?? '',
      paidTo: data['paidTo'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}