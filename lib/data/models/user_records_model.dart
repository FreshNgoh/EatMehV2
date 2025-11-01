import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserRecordsModel {
  final String uid;
  final String calories;
  final String? recommendation;
  final String? imageUrl;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  UserRecordsModel({
    required this.uid,
    required this.calories,
    required this.imageUrl,
    this.recommendation,
    this.createdAt,
    this.updatedAt,
  });

  UserRecordsModel copyWith({
    String? uid,
    String? calories,
    String? recommendation,
    String? imageUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserRecordsModel(
      uid: uid ?? this.uid,
      calories: calories ?? this.calories,
      recommendation: recommendation ?? this.recommendation,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'calories': calories,
      'recommendation': recommendation,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserRecordsModel.fromMap(Map<String, dynamic> map) {
    return UserRecordsModel(
      uid: map['uid'] as String,
      calories: map['calories'] as String,
      recommendation: map['recommendation'] as String,
      imageUrl: map['imageUrl'] as String?,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
    );
  }

  String toJson() => json.encode(toMap());
  factory UserRecordsModel.fromJson(String source) =>
      UserRecordsModel.fromMap(json.decode(source));
}
