import 'package:cloud_firestore/cloud_firestore.dart';
import '../trainer/trainer_profile_model.dart';
import 'user_status_model.dart';
import 'user_settings_model.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role; // "user", "trainer", "admin"
  final String? imageUrl;
  final String? bio;
  final List<String> friends;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final UserStatus? status;
  final UserSettings? settings;
  final TrainerProfile? trainerProfile;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.role = 'user',
    this.imageUrl,
    this.bio,
    this.friends = const [],
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.settings,
    this.trainerProfile,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      role: map['role'] as String? ?? 'user',
      imageUrl: map['imageUrl'] as String?,
      bio: map['bio'] as String?,
      friends: List<String>.from(map['friends'] ?? []),
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
      status:
          map['status'] != null
              ? UserStatus.fromMap(map['status'] as Map<String, dynamic>)
              : null,
      settings:
          map['settings'] != null
              ? UserSettings.fromMap(map['settings'] as Map<String, dynamic>)
              : null,
      trainerProfile:
          map['trainerProfile'] != null
              ? TrainerProfile.fromMap(
                map['trainerProfile'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'role': role,
      'imageUrl': imageUrl,
      'bio': bio,
      'friends': friends,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status?.toMap(),
      'settings': settings?.toMap(),
      'trainerProfile': trainerProfile?.toMap(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? role,
    String? imageUrl,
    String? bio,
    List<String>? friends,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    UserStatus? status,
    UserSettings? settings,
    TrainerProfile? trainerProfile,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      friends: friends ?? this.friends,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      trainerProfile: trainerProfile ?? this.trainerProfile,
    );
  }
}
