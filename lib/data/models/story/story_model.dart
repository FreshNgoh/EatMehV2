import 'package:cloud_firestore/cloud_firestore.dart';

import '../meal/nutrition_info_model.dart';

class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String userImageUrl;
  final String type; // "meal", "exercise", "achievement"
  final String mediaUrl;
  final String? thumbnail;
  final String? caption;
  final MealData? mealData;
  final Timestamp createdAt;
  final Timestamp expiresAt;
  final List<String> views;
  final int viewCount;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userImageUrl,
    required this.type,
    required this.mediaUrl,
    this.thumbnail,
    this.caption,
    this.mealData,
    required this.createdAt,
    required this.expiresAt,
    this.views = const [],
    this.viewCount = 0,
  });

  factory StoryModel.fromMap(String id, Map<String, dynamic> map) {
    return StoryModel(
      id: id,
      userId: map['userId'] as String,
      username: map['username'] as String,
      userImageUrl: map['userImageUrl'] as String,
      type: map['type'] as String,
      mediaUrl: map['mediaUrl'] as String,
      thumbnail: map['thumbnail'] as String?,
      caption: map['caption'] as String?,
      mealData:
          map['mealData'] != null
              ? MealData.fromMap(map['mealData'] as Map<String, dynamic>)
              : null,
      createdAt: map['createdAt'] as Timestamp,
      expiresAt: map['expiresAt'] as Timestamp,
      views: List<String>.from(map['views'] ?? []),
      viewCount: map['viewCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'userImageUrl': userImageUrl,
      'type': type,
      'mediaUrl': mediaUrl,
      'thumbnail': thumbnail,
      'caption': caption,
      'mealData': mealData?.toMap(),
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'views': views,
      'viewCount': viewCount,
    };
  }
}
