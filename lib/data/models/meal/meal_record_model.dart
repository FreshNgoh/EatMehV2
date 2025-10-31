import 'package:cloud_firestore/cloud_firestore.dart';

import 'nutrition_info_model.dart';

class MealRecordModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String? thumbnailUrl;
  final int calories;
  final String mealType;
  final List<FoodItem> foodItems;
  final NutritionInfo nutritionInfo;
  final String recommendation;
  final bool isPublic;
  final String? storyId;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  MealRecordModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.calories,
    required this.mealType,
    required this.foodItems,
    required this.nutritionInfo,
    required this.recommendation,
    this.isPublic = false,
    this.storyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealRecordModel.fromMap(String id, Map<String, dynamic> map) {
    return MealRecordModel(
      id: id,
      userId: map['userId'] as String,
      imageUrl: map['imageUrl'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      calories: map['calories'] as int,
      mealType: map['mealType'] as String,
      foodItems:
          (map['foodItems'] as List)
              .map((item) => FoodItem.fromMap(item as Map<String, dynamic>))
              .toList(),
      nutritionInfo: NutritionInfo.fromMap(
        map['nutritionInfo'] as Map<String, dynamic>,
      ),
      recommendation: map['recommendation'] as String,
      isPublic: map['isPublic'] as bool? ?? false,
      storyId: map['storyId'] as String?,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'calories': calories,
      'mealType': mealType,
      'foodItems': foodItems.map((item) => item.toMap()).toList(),
      'nutritionInfo': nutritionInfo.toMap(),
      'recommendation': recommendation,
      'isPublic': isPublic,
      'storyId': storyId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
