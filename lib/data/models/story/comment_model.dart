import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String uid;
  final String userId;
  final String username;
  final String userImageUrl;
  final String text;
  final Timestamp createdAt;

  CommentModel({
    required this.uid,
    required this.userId,
    required this.username,
    required this.userImageUrl,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'userImageUrl': userImageUrl,
      'text': text,
      'createdAt': createdAt,
    };
  }

  factory CommentModel.fromMap(String uid, Map<String, dynamic> map) {
    return CommentModel(
      uid: uid,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userImageUrl: map['userImageUrl'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
