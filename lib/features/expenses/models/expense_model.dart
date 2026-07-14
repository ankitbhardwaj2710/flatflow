import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String paidBy;
  final List<String> splitAmong;
  final Map<String, double> splits;
  final String note;
  final String createdBy;
  final DateTime? createdAt;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.splitAmong,
    required this.splits,
    required this.note,
    required this.createdBy,
    this.createdAt,
  });

  factory ExpenseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final rawSplits =
        Map<String, dynamic>.from(data['splits'] as Map? ?? {});

    return ExpenseModel(
      id: document.id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: data['category'] as String? ?? 'Other',
      paidBy: data['paidBy'] as String? ?? '',
      splitAmong: List<String>.from(
        data['splitAmong'] as List? ?? [],
      ),
      splits: rawSplits.map(
        (key, value) => MapEntry(
          key,
          (value as num).toDouble(),
        ),
      ),
      note: data['note'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}