import 'package:cloud_firestore/cloud_firestore.dart';
import '../trainer/trainer_profile_model.dart';
import 'user_settings_model.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role; // "user", "trainer", "admin"
  final String? imageUrl;
  final String? bio;
  final List<String> friends; // Friend UIDs
  final List<String> friendRequests; // Optional pending requests
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final UserSettings? settings;
  final TrainerProfile? trainerProfile;
  final bool isFrozen; // Admin control
  // age, gender, height, weight, diet type (vege?)

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.role = 'user',
    this.imageUrl,
    this.bio,
    this.friends = const [],
    this.friendRequests = const [],
    required this.createdAt,
    required this.updatedAt,
    this.settings,
    this.trainerProfile,
    this.isFrozen = false,
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
      friendRequests: List<String>.from(map['friendRequests'] ?? []),
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
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
      isFrozen: map['isFrozen'] as bool? ?? false,
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
      'friendRequests': friendRequests,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'settings': settings?.toMap(),
      'trainerProfile': trainerProfile?.toMap(),
      'isFrozen': isFrozen,
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
    List<String>? friendRequests,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    UserSettings? settings,
    TrainerProfile? trainerProfile,
    bool? isFrozen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      trainerProfile: trainerProfile ?? this.trainerProfile,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }
}
