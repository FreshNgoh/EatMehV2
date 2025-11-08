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
  static const Color caloriesHigh = Color(0xFFE53E3E); // red
  static const Color caloriesMedium = Color(0xFF66BB6A); // green
  static const Color caloriesLow = Color.fromARGB(255, 252, 154, 6); // orange

  static const Color proteinColor = Color(0xFFE2C415);
  static const Color carbsColor = Color(0xFFDD6B20); // yellow
  static const Color fatColor = Color(0xFFD69E2E); // orange-red
  static const Color fiberColor = Color(0xFF38A169); // light green

  // Nutrition Icon
  static const IconData proteinIcon = Icons.egg_alt_outlined;
  static const IconData carbsIcon = Icons.bakery_dining_outlined;
  static const IconData fatIcon = Icons.water_drop_sharp;
  static const IconData fiberIcon = Icons.eco;

  /// Helper for calorie color selection
  static Color getCalorieColor(int calories) {
    if (calories > 700) return caloriesHigh;
    if (calories >= 300) return caloriesMedium;
    return caloriesLow;
  }

  // Exercise Icons & Colors
  static const Map<String, Map<String, dynamic>> exerciseIconData = {
    'Running': {'icon': Icons.directions_run, 'color': Color(0xFF8B5CF6)},
    'Walking': {'icon': Icons.directions_walk, 'color': Color(0xFF3B82F6)},
    'Cycling': {'icon': Icons.directions_bike, 'color': Color(0xFF10B981)},
    'Yoga': {'icon': Icons.self_improvement, 'color': Color(0xFFF59E0B)},
    'Swimming': {'icon': Icons.pool, 'color': Color(0xFF0EA5E9)},
    'Gym': {'icon': Icons.fitness_center, 'color': Color(0xFF353535)},
  };
}
