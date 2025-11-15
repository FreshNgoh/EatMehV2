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

  /// BMR (static)
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender, // 'male' or 'female'
  }) {
    if (gender.toLowerCase() == 'male') {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
  }

  /// Maintenance calories (static)
  static double calculateMaintenanceCalories({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    double activityFactor = 1.2, // sedentary default
  }) {
    final bmr = calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    return bmr * activityFactor;
  }

  /// NEW: Get the low calorie threshold (10% below maintenance)
  static double getLowCalorieThreshold({required double maintenanceCalories}) {
    return maintenanceCalories * 0.9;
  }

  /// NEW: Get the high calorie threshold (10% above maintenance)
  static double getHighCalorieThreshold({required double maintenanceCalories}) {
    return maintenanceCalories * 1.1;
  }

  /// Dynamic calorie status based on user maintenance calories
  static CalorieStatus getCalorieStatus({
    required double netCalories,
    required double maintenanceCalories,
  }) {
    final lowThreshold = getLowCalorieThreshold(
      maintenanceCalories: maintenanceCalories,
    );
    final highThreshold = getHighCalorieThreshold(
      maintenanceCalories: maintenanceCalories,
    );

    if (netCalories < lowThreshold) return CalorieStatus.low;
    if (netCalories > highThreshold) return CalorieStatus.high;

    return CalorieStatus.balanced;
  }

  /// Returns the display text for a given [CalorieStatus].
  static Color getStatusColor(CalorieStatus status) {
    switch (status) {
      case CalorieStatus.low:
        return AppColors.caloriesLow;
      case CalorieStatus.balanced:
        return AppColors.caloriesMedium;
      case CalorieStatus.high:
        return AppColors.caloriesHigh;
    }
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

  /// NEW: Get BMI category text
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// NEW: Get BMI category color
  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) return AppColors.caloriesLow;
    if (bmi < 25) return AppColors.caloriesMedium;
    if (bmi < 30) return AppColors.warning;
    return AppColors.caloriesHigh;
  }
}
