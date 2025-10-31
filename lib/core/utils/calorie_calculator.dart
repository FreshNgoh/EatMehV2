class CalorieCalculator {
  static const int caloriesPerPound = 3500;

  static int calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    // Mifflin-St Jeor Equation
    double bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    if (isMale) {
      bmr += 5;
    } else {
      bmr -= 161;
    }
    return bmr.round();
  }

  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  static String getBMIEmoji(double bmi) {
    if (bmi < 18.5) {
      return '😟';
    } else if (bmi < 25) {
      return '😊';
    } else if (bmi < 30) {
      return '😅';
    } else {
      return '😰';
    }
  }

  static int calculateWeightChangeCalories(double weightChangeLb) {
    return (weightChangeLb * caloriesPerPound).round();
  }

  static double estimateWeightChange(int netCalories) {
    return netCalories / caloriesPerPound;
  }
}
