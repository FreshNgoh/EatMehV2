import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  final String senderUid;
  final String receiverUid;
  final Timestamp createdAt;
  final String status; // "pending", "accepted", "declined"

  FriendRequestModel({
    required this.senderUid,
    required this.receiverUid,
    required this.createdAt,
    this.status = "pending",
  });

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'createdAt': createdAt,
      'status': status,
    };
  }

  factory FriendRequestModel.fromMap(Map<String, dynamic> map) {
    return FriendRequestModel(
      senderUid: map['senderUid'] as String,
      receiverUid: map['receiverUid'] as String,
      createdAt: map['createdAt'] as Timestamp,
      status: map['status'] as String? ?? "pending",
    );
  }

  String toJson() => json.encode(toMap());
  factory FriendRequestModel.fromJson(String source) =>
      FriendRequestModel.fromMap(json.decode(source));
}
