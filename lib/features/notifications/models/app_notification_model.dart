import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final bool isRead;
  final String createdBy;
  final DateTime? createdAt;

  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.isRead,
    required this.createdBy,
    required this.createdAt,
  });

  factory AppNotificationModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return AppNotificationModel(
      id: doc.id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isRead: data['isRead'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'isRead': isRead,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}