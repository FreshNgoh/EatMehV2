import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String goalType; // e.g. "weight gain", "weight loss"
  final double goalCal;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final Timestamp? startDate;
  final Timestamp? endDate;

  Goal({
    required this.goalType,
    required this.goalCal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    this.startDate,
    this.endDate,
  });

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      goalType: map['goalType'] ?? '',
      goalCal: map['goalCal']?.toDouble() ?? 0.0,
      protein: map['protein']?.toDouble() ?? 0.0,
      carbs: map['carbs']?.toDouble() ?? 0.0,
      fat: map['fat']?.toDouble() ?? 0.0,
      fiber: map['fiber']?.toDouble() ?? 0.0,
      startDate: map['startDate'] is Timestamp ? map['startDate'] : null,
      endDate: map['endDate'] is Timestamp ? map['endDate'] : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goalType': goalType,
      'goalCal': goalCal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  Goal copyWith({
    String? goalType,
    double? goalCal,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    Timestamp? startDate,
    Timestamp? endDate,
  }) {
    return Goal(
      goalType: goalType ?? this.goalType,
      goalCal: goalCal ?? this.goalCal,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
