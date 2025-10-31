import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      'assets/languages/${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Getters for common translations
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get username => translate('username');
  String get forgotPassword => translate('forgot_password');

  // Navigation
  String get friends => translate('friends');
  String get records => translate('records');
  String get camera => translate('camera');
  String get consult => translate('consult');
  String get profile => translate('profile');

  // Camera & Stories
  String get takePhoto => translate('take_photo');
  String get analyzeMeal => translate('analyze_meal');
  String get postStory => translate('post_story');
  String get viewStories => translate('view_stories');
  String get yourStory => translate('your_story');

  // Meal Analysis
  String get calories => translate('calories');
  String get recommendation => translate('recommendation');
  String get breakfast => translate('breakfast');
  String get lunch => translate('lunch');
  String get dinner => translate('dinner');
  String get snack => translate('snack');

  // Settings
  String get settings => translate('settings');
  String get language => translate('language');
  String get darkMode => translate('dark_mode');
  String get notifications => translate('notifications');
  String get userManual => translate('user_manual');
  String get logout => translate('logout');

  // Status
  String get healthy => translate('healthy');
  String get underweight => translate('underweight');
  String get overweight => translate('overweight');
  String get needsAttention => translate('needs_attention');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access
extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}
