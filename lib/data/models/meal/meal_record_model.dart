import 'package:cloud_firestore/cloud_firestore.dart';

import 'nutrition_info_model.dart';

class MealRecordModel {
  final String uid;
  final String userId;
  final int calories;
  final String foodName;
  final String? imageUrl;
  final NutritionInfo nutritionInfo;
  final String recommendation;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  MealRecordModel({
    required this.uid,
    required this.userId,
    required this.imageUrl,
    required this.calories,
    required this.foodName,
    required this.nutritionInfo,
    required this.recommendation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealRecordModel.fromMap(String uid, Map<String, dynamic> map) {
    return MealRecordModel(
      uid: uid,
      userId: map['userId'] as String,
      imageUrl: map['imageUrl'] as String,
      calories: map['calories'] as int,
      foodName: map['foodName'] as String,
      nutritionInfo: NutritionInfo.fromMap(
        map['nutritionInfo'] as Map<String, dynamic>,
      ),
      recommendation: map['recommendation'] as String,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'calories': calories,
      'nutritionInfo': nutritionInfo.toMap(),
      'recommendation': recommendation,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
