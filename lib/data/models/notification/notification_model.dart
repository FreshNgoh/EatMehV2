import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String uid;
  final String userId;
  final String title;
  final String message;
  final String type; // "system", "trainer_update", "friend_request", etc.
  final bool isRead;
  final Timestamp createdAt;

  NotificationModel({
    required this.uid,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(String uid, Map<String, dynamic> map) {
    return NotificationModel(
      uid: uid,
      userId: map['userId'],
      title: map['title'],
      message: map['message'],
      type: map['type'],
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
