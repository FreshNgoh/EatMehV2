class MealData {
  final int calories;
  final String mealType;
  final List<String> foodItems;
  final String recommendation;

  MealData({
    required this.calories,
    required this.mealType,
    required this.foodItems,
    required this.recommendation,
  });

  factory MealData.fromMap(Map<String, dynamic> map) {
    return MealData(
      calories: map['calories'] as int,
      mealType: map['mealType'] as String,
      foodItems: List<String>.from(map['foodItems'] ?? []),
      recommendation: map['recommendation'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'mealType': mealType,
      'foodItems': foodItems,
      'recommendation': recommendation,
    };
  }
}

class FoodItem {
  final String name;
  final String quantity;
  final int calories;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.calories,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] as String,
      quantity: map['quantity'] as String,
      calories: map['calories'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'quantity': quantity, 'calories': calories};
  }
}

class NutritionInfo {
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  NutritionInfo({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  factory NutritionInfo.fromMap(Map<String, dynamic> map) {
    return NutritionInfo(
      protein: map['protein']?.toDouble() ?? 0.0,
      carbs: map['carbs']?.toDouble() ?? 0.0,
      fat: map['fat']?.toDouble() ?? 0.0,
      fiber: map['fiber']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'protein': protein, 'carbs': carbs, 'fat': fat, 'fiber': fiber};
  }
}
