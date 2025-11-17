class AppConstants {
  // App Info
  static const String appName = 'EatMeh';
  static const String appVersion = '2.0.0';

  // Story Duration
  static const int storyDurationHours = 24;
  static const int storyDisplayDurationSeconds = 5;

  // Calorie Thresholds
  static const int highCalorieThreshold = 700;
  static const int mediumCalorieThreshold = 300;

  // Weight Management
  static const int caloriesPerPound = 3500;

  // BMI Categories
  static const double bmiUnderweight = 18.5;
  static const double bmiNormal = 25.0;
  static const double bmiOverweight = 30.0;

  // Image Settings
  static const int maxImageSizeMB = 4;
  static const int imageQuality = 85;

  // Pagination
  static const int itemsPerPage = 20;

  // Exercise Calorie Rates (calories per minute)
  static const Map<String, double> calorieRatePerMinute = {
    'Running': 10.0,
    'Walking': 4.0,
    'Cycling': 8.5,
    'Yoga': 3.5,
    'Swimming': 9.5,
    'Gym': 7.0,
  };
}
