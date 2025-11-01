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

  // Login & Register
  String get appName => translate('appName');
  String get tagline => translate('tagline');

  String get emailLabel => translate('emailLabel');
  String get emailHint => translate('emailHint');
  String get emailErrorEmpty => translate('emailErrorEmpty');
  String get emailErrorInvalid => translate('emailErrorInvalid');

  String get passwordLabel => translate('passwordLabel');
  String get passwordHint => translate('passwordHint');
  String get passwordErrorEmpty => translate('passwordErrorEmpty');
  String get passwordErrorShort => translate('passwordErrorShort');

  String get forgotPassword => translate('forgotPassword');
  String get loginButton => translate('loginButton');
  String get noAccount => translate('noAccount');
  String get registerNow => translate('registerNow');
  String get loginError => translate('loginError');

  String get createAccount => translate('createAccount');

  String get usernameLabel => translate('usernameLabel');
  String get usernameHint => translate('usernameHint');
  String get usernameErrorEmpty => translate('usernameErrorEmpty');
  String get usernameErrorShort => translate('usernameErrorShort');

  String get confirmPasswordLabel => translate('confirmPasswordLabel');
  String get confirmPasswordHint => translate('confirmPasswordHint');
  String get confirmPasswordErrorEmpty =>
      translate('confirmPasswordErrorEmpty');
  String get confirmPasswordErrorMismatch =>
      translate('confirmPasswordErrorMismatch');

  String get registerButton => translate('registerButton');
  String get termsNotice => translate('termsNotice');
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
