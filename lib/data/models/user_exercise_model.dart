import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

enum Exercise {
  jogging,
  running,
  walking,
  cycling,
  swimming,
  yoga,
  weightlifting,
  aerobics,
  other,
}

extension ExerciseExtension on Exercise {
  String get name {
    switch (this) {
      case Exercise.jogging:
        return 'jogging';
      case Exercise.running:
        return 'running';
      case Exercise.walking:
        return 'walking';
      case Exercise.cycling:
        return 'cycling';
      case Exercise.swimming:
        return 'swimming';
      case Exercise.yoga:
        return 'yoga';
      case Exercise.weightlifting:
        return 'weightlifting';
      case Exercise.aerobics:
        return 'aerobics';
      case Exercise.other:
        return 'other';
    }
  }
}

class UserExerciseModel {
  final String uid;
  final Exercise exerciseName;
  final String title;
  final double caloriesBurnt;
  final Timestamp? createdAt;
  final int duration;

  UserExerciseModel({
    required this.uid,
    required this.exerciseName,
    required this.title,
    required this.caloriesBurnt,
    this.createdAt,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'exerciseName': exerciseName.name,
      'title': title,
      'caloriesBurnt': caloriesBurnt,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'duration': duration,
    };
  }

  factory UserExerciseModel.fromMap(Map<String, dynamic> map) {
    return UserExerciseModel(
      uid: map['uid'] as String,
      exerciseName: Exercise.values.firstWhere(
        (e) => e.name == map['exerciseName'],
        orElse: () => Exercise.other,
      ),
      title: map['title'] as String,
      caloriesBurnt: (map['caloriesBurnt'] as num).toDouble(),
      createdAt: map['createdAt'] as Timestamp,
      duration: map['duration'] as int,
    );
  }

  String toJson() => json.encode(toMap());
  factory UserExerciseModel.fromJson(String source) =>
      UserExerciseModel.fromMap(json.decode(source));
}
