import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _prefs!;
  }

  // Settings
  static Future<void> setLanguage(String language) async {
    await instance.setString('language', language);
  }

  static String getLanguage() {
    return instance.getString('language') ?? 'en';
  }

  static Future<void> setDarkMode(bool enabled) async {
    await instance.setBool('darkMode', enabled);
  }

  static bool getDarkMode() {
    return instance.getBool('darkMode') ?? false;
  }

  static Future<void> setNotifications(bool enabled) async {
    await instance.setBool('notifications', enabled);
  }

  static bool getNotifications() {
    return instance.getBool('notifications') ?? true;
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    await instance.setBool('onboardingCompleted', completed);
  }

  static bool getOnboardingCompleted() {
    return instance.getBool('onboardingCompleted') ?? false;
  }

  // User Data Cache
  static Future<void> cacheUserId(String userId) async {
    await instance.setString('userId', userId);
  }

  static String? getCachedUserId() {
    return instance.getString('userId');
  }

  static Future<void> clearAll() async {
    await instance.clear();
  }
}
