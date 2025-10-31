import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatus {
  final double? currentWeight;
  final double? goalWeight;
  final double? height;
  final double? bmi;
  final String statusEmoji;
  final Timestamp lastStatusUpdate;

  UserStatus({
    this.currentWeight,
    this.goalWeight,
    this.height,
    this.bmi,
    required this.statusEmoji,
    required this.lastStatusUpdate,
  });

  factory UserStatus.fromMap(Map<String, dynamic> map) {
    return UserStatus(
      currentWeight: map['currentWeight']?.toDouble(),
      goalWeight: map['goalWeight']?.toDouble(),
      height: map['height']?.toDouble(),
      bmi: map['bmi']?.toDouble(),
      statusEmoji: map['statusEmoji'] as String,
      lastStatusUpdate: map['lastStatusUpdate'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentWeight': currentWeight,
      'goalWeight': goalWeight,
      'height': height,
      'bmi': bmi,
      'statusEmoji': statusEmoji,
      'lastStatusUpdate': lastStatusUpdate,
    };
  }
}
