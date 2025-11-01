import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ColorHelper {
  /// Returns color based on calorie level
  static Color getCalorieColor(int calories) {
    if (calories > 700) {
      return const Color(0xFFE57373); // warm red – high calorie
    } else if (calories >= 300) {
      return const Color(0xFFFFB74D); // peach – moderate calorie
    } else {
      return const Color(0xFF81C784); // light green – low calorie
    }
  }

  /// Returns color based on BMI level
  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return const Color(0xFFFFD54F); // underweight – soft yellow
    } else if (bmi < 25) {
      return AppColors.success; // normal – green
    } else if (bmi < 30) {
      return const Color(0xFFFFB74D); // overweight – orange
    } else {
      return AppColors.error; // obese – red
    }
  }

  /// Returns color based on workout intensity
  static Color getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
        return const Color(0xFFA5D6A7); // soft mint green
      case 'medium':
        return const Color(0xFFFFE082); // gentle yellow
      case 'high':
        return const Color(0xFFE57373); // warm red
      default:
        return AppColors.textHint;
    }
  }

  /// Returns color based on meal type
  static Color getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFFB74D); // sunny peach/orange
      case 'lunch':
        return const Color(0xFF81C784); // green (fresh)
      case 'dinner':
        return const Color(0xFF64B5F6); // calm blue
      case 'snack':
        return const Color(0xFFBA68C8); // playful purple
      default:
        return AppColors.textHint;
    }
  }
}
