import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final String createdBy;
  final DateTime? createdAt;

  const ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory ActivityModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return ActivityModel(
      id: doc.id,
      type: data['type'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description:
          data['description'] as String? ?? '',
      createdBy:
          data['createdBy'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)
              ?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}