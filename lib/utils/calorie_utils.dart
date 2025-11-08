import 'package:flutter/material.dart';
import 'package:eatmehv2/core/theme/app_colors.dart';

/// Represents calorie balance states.
enum CalorieStatus { low, balanced, high }

/// Utility functions for calorie logic.
class CalorieUtils {
  /// Returns the [CalorieStatus] based on the given net calorie value.
  static CalorieStatus getCalorieStatus(double netCalories) {
    if (netCalories < 300) return CalorieStatus.low;
    if (netCalories > 600) return CalorieStatus.high;
    return CalorieStatus.balanced;
  }

  /// Returns the appropriate color for the given [CalorieStatus].
  static Color getStatusColor(double netCalories) {
    return AppColors.getCalorieColor(netCalories.toInt());
  }

  /// Returns the display text for a given [CalorieStatus].
  static String getStatusText(CalorieStatus status) {
    switch (status) {
      case CalorieStatus.low:
        return 'Too Low';
      case CalorieStatus.balanced:
        return 'Balanced';
      case CalorieStatus.high:
        return 'Too High';
    }
  }
}
