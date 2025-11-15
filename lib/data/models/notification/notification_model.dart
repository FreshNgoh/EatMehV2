import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? uid;
  final String senderUid;
  final String? senderName;
  final String? senderImage;
  final String receiverUid;
  final String title;
  final String message;
  final String type; // "system", "trainer_update", "friend_request", etc.
  final bool isRead;
  final String? status; // pending-> for trainer/friend requests
  final Timestamp createdAt;

  NotificationModel({
    this.uid,
    required this.senderUid,
    this.senderName,
    this.senderImage,
    required this.receiverUid,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.status,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(String uid, Map<String, dynamic> map) {
    return NotificationModel(
      uid: uid,
      senderUid: map['senderUid'] as String,
      senderName: map['senderName'] as String?,
      senderImage: map['senderImage'] as String?,
      receiverUid: map['receiverUid'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      isRead: map['isRead'] ?? false,
      status: map['status'] as String?,
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'senderName': senderName,
      'senderImage': senderImage,
      'receiverUid': receiverUid,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
