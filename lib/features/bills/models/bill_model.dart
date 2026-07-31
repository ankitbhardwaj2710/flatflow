import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime dueDate;
  final bool isPaid;
  final String createdBy;
  final DateTime? createdAt;

  const BillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.dueDate,
    required this.isPaid,
    required this.createdBy,
    required this.createdAt,
  });

  factory BillModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return BillModel(
      id: document.id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: data['category'] as String? ?? 'Other',
      dueDate:
          (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPaid: data['isPaid'] as bool? ?? false,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'createdBy': createdBy,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  BillModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? dueDate,
    bool? isPaid,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}