import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderUid;
  final String receiverUid;
  final String message;
  final String status; // sent
  final Timestamp timestamp;

  MessageModel({
    this.id = '',
    required this.senderUid,
    required this.receiverUid,
    required this.message,
    required this.status,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      senderUid: map['senderUid'] ?? '',
      receiverUid: map['receiverUid'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'sent',
      timestamp: map['timestamp'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'message': message,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
