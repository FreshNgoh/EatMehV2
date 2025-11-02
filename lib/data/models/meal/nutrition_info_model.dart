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
