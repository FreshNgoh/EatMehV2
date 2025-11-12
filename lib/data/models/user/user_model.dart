import 'package:cloud_firestore/cloud_firestore.dart';
import '../trainer/trainer_profile_model.dart';
import './user_settings_model.dart';
import './goal_model.dart';

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
  final int? age;
  final String? gender;
  final double? height; // in cm
  final double? weight; // in kg
  final double? bmi;
  final String? dietType; // "vegetarian", "vegan", "omnivore", etc.
  final Goal? goal;
  final String? currentTrainerUid;

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
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.bmi,
    this.dietType,
    this.goal,
    this.currentTrainerUid,
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
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      bmi: map['bmi'] != null ? (map['bmi'] as num).toDouble() : null,
      dietType: map['dietType'] as String?,
      goal:
          map['goal'] != null
              ? Goal.fromMap(map['goal'] as Map<String, dynamic>)
              : null,
      currentTrainerUid: map['currentTrainerUid'] as String?,
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
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'dietType': dietType,
      'goal': goal?.toMap(),
      'currentTrainerUid': currentTrainerUid,
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
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? bmi,
    String? dietType,
    Goal? goal,
    String? currentTrainerUid,
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
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      dietType: dietType ?? this.dietType,
      goal: goal ?? this.goal,
      currentTrainerUid: currentTrainerUid ?? this.currentTrainerUid,
    );
  }
}
