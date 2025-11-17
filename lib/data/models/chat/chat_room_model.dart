import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastUpdated;
  final String lastSenderUid;

  ChatRoomModel({
    required this.participants,
    required this.lastMessage,
    required this.lastUpdated,
    required this.lastSenderUid,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastUpdated: map['lastUpdated'] as Timestamp,
      lastSenderUid: map['lastSenderUid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastUpdated': lastUpdated,
      'lastSenderUid': lastSenderUid,
    };
  }
}
