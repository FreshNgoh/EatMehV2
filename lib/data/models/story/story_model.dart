import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/data/models/story/comment_model.dart';

class StoryModel {
  final String uid;
  final String userId;
  final String username;
  final String userImageUrl;
  final String mediaUrl;
  final Timestamp createdAt;
  final Timestamp expiresAt;
  final List<String> views;
  final int viewCount;
  final List<CommentModel> comments;

  StoryModel({
    required this.uid,
    required this.userId,
    required this.username,
    required this.userImageUrl,
    required this.mediaUrl,
    required this.createdAt,
    required this.expiresAt,
    this.views = const [],
    this.viewCount = 0,
    this.comments = const [],
  });

  factory StoryModel.fromMap(String uid, Map<String, dynamic> map) {
    return StoryModel(
      uid: uid,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userImageUrl: map['userImageUrl'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      expiresAt: map['expiresAt'] ?? Timestamp.now(),
      views: List<String>.from(map['views'] ?? []),
      viewCount: map['viewCount'] ?? 0,
      comments:
          (map['comments'] as List<dynamic>?)
              ?.map((c) => CommentModel.fromMap(Map<String, dynamic>.from(c)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'userImageUrl': userImageUrl,
      'mediaUrl': mediaUrl,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'views': views,
      'viewCount': viewCount,
      'comments': comments.map((c) => c.toMap()).toList(),
    };
  }
}
