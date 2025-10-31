import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseRecordModel {
  final String id;
  final String userId;
  final String exerciseName;
  final String exerciseType;
  final int duration; // in minutes
  final int caloriesBurnt;
  final String intensity; // "low", "medium", "high"
  final String? notes;
  final Timestamp createdAt;

  ExerciseRecordModel({
    required this.id,
    required this.userId,
    required this.exerciseName,
    required this.exerciseType,
    required this.duration,
    required this.caloriesBurnt,
    required this.intensity,
    this.notes,
    required this.createdAt,
  });

  factory ExerciseRecordModel.fromMap(String id, Map<String, dynamic> map) {
    return ExerciseRecordModel(
      id: id,
      userId: map['userId'] as String,
      exerciseName: map['exerciseName'] as String,
      exerciseType: map['exerciseType'] as String,
      duration: map['duration'] as int,
      caloriesBurnt: map['caloriesBurnt'] as int,
      intensity: map['intensity'] as String,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'exerciseName': exerciseName,
      'exerciseType': exerciseType,
      'duration': duration,
      'caloriesBurnt': caloriesBurnt,
      'intensity': intensity,
      'notes': notes,
      'createdAt': createdAt,
    };
  }
}
