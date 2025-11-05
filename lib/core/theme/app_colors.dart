import 'package:flutter/material.dart';

class AppColors {
  // 🌿 Primary Wellness Palette
  static const Color primary = Color(0xFF4CAF50); // Fresh green (health)
  static const Color secondary = Color(0xFFFFB74D); // Peach/orange (energy)

  // ✅ Supportive Status Colors
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF29B6F6);

  // 📝 Text
  static const Color textPrimary = Color(0xFF1B1B1B);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textHint = Color(0xFF9E9E9E);

  // 🎨 Backgrounds & Surfaces
  static const Color background = Color(0xFFFDFDFD);
  static const Color surface = Color(0xFFF6FBF7);
  static const Color border = Color(0xFFE0E0E0);

  // 🌈 Gradients
  static const List<Color> healthGradient = [
    Color(0xFF81C784), // soft green
    Color(0xFFA5D6A7), // mint
    Color(0xFFFFE0B2), // light peach
  ];

  static const List<Color> vitalityGradient = [
    Color(0xFF66BB6A),
    Color(0xFF43A047),
  ];

  // 🔥 Nutrition Colors
  static const Color caloriesHigh = Color(0xFFE57373); // red
  static const Color caloriesMedium = Color(0xFF66BB6A); // green
  static const Color caloriesLow = Color.fromARGB(255, 252, 154, 6); // orange

  static const Color protein = Color(0xFF42A5F5); // blue
  static const Color carbs = Color.fromARGB(255, 245, 199, 48); // yellow
  static const Color fat = Color(0xFFFF8A65); // orange-red
  static const Color fiber = Color(0xFF81C784); // light green

  /// Helper for calorie color selection
  static Color getCalorieColor(int calories) {
    if (calories > 700) return caloriesHigh;
    if (calories >= 300) return caloriesMedium;
    return caloriesLow;
  }
}
