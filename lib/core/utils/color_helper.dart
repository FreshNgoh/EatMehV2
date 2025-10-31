import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ColorHelper {
  static Color getCalorieColor(int calories) {
    if (calories > 700) {
      return AppColors.calorieHigh;
    } else if (calories >= 300) {
      return AppColors.calorieMedium;
    } else {
      return AppColors.calorieLow;
    }
  }

  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return AppColors.warning;
    } else if (bmi < 25) {
      return AppColors.success;
    } else if (bmi < 30) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  static Color getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static Color getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
