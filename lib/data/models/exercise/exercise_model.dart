import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseRecordModel {
  final String uid;
  final String userId;
  final String exerciseName;
  final int duration; // in minutes
  final int caloriesBurnt;
  final Timestamp createdAt;

  ExerciseRecordModel({
    required this.uid,
    required this.userId,
    required this.exerciseName,
    required this.duration,
    required this.caloriesBurnt,
    required this.createdAt,
  });

  factory ExerciseRecordModel.fromMap(String uid, Map<String, dynamic> map) {
    return ExerciseRecordModel(
      uid: uid,
      userId: map['userId'] as String,
      exerciseName: map['exerciseName'] as String,
      duration: map['duration'] as int,
      caloriesBurnt: map['caloriesBurnt'] as int,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'exerciseName': exerciseName,
      'duration': duration,
      'caloriesBurnt': caloriesBurnt,
      'createdAt': createdAt,
    };
  }
}
