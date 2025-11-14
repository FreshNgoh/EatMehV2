import 'dart:math';
import 'package:flutter/material.dart';
import 'package:eatmehv2/core/theme/app_colors.dart';

/// Represents calorie balance states.
enum CalorieStatus { low, balanced, high }

/// Utility functions for calorie logic.
class CalorieUtils {
  /// Calculates net calories (taken - burnt)
  static double calculateNetCalories(
    double caloriesTaken,
    double caloriesBurnt,
  ) {
    return caloriesTaken - caloriesBurnt;
  }

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

  /// Returns a random image path based on calorie status
  /// Returns both the path and the index for tracking purposes
  static String getRandomStatusImage(CalorieStatus status) {
    String folder;
    switch (status) {
      case CalorieStatus.low:
        folder = 'assets/status/low';
        break;
      case CalorieStatus.balanced:
        folder = 'assets/status/health';
        break;
      case CalorieStatus.high:
        folder = 'assets/status/high';
        break;
    }

    final imageIndex = Random().nextInt(3) + 1; // 1–3
    final folderName = folder.split('/').last;
    return '$folder/${folderName}_$imageIndex.png';
  }

  /// Returns the appropriate icon based on calorie status (fallback for when images fail)
  static IconData getStatusIcon(CalorieStatus status) {
    switch (status) {
      case CalorieStatus.low:
        return Icons.sentiment_dissatisfied;
      case CalorieStatus.balanced:
        return Icons.sentiment_satisfied;
      case CalorieStatus.high:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  /// Calculates BMI using height in cm and weight in kg.
  static double? calculateBMI({
    required double? heightCm,
    required double? weightKg,
  }) {
    if (heightCm == null || weightKg == null) return null;
    if (heightCm <= 0 || weightKg <= 0) return null;

    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    return bmi;
  }
}
