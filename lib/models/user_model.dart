import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? imageUrl;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String? userRecordId;
  final List<String> friends;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.userRecordId = "",
    this.friends = const [],
  });

  // update user
  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? imageUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? userRecordId,
    List<String>? friends,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userRecordId: userRecordId ?? this.userRecordId,
      friends: friends ?? this.friends,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'imageUrl': imageUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'userRecordId': userRecordId,
      'friends': friends,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      imageUrl: map['imageUrl'] as String?,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
      userRecordId: map['userRecordId'] as String?,
      friends: List<String>.from(map['friends'] ?? []),
    );
  }

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
