class UserSettings {
  final String language;
  final bool darkMode;
  final bool notifications;
  final bool showOnboarding;

  UserSettings({
    this.language = 'en',
    this.darkMode = false,
    this.notifications = true,
    this.showOnboarding = true,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      language: map['language'] as String? ?? 'en',
      darkMode: map['darkMode'] as bool? ?? false,
      notifications: map['notifications'] as bool? ?? true,
      showOnboarding: map['showOnboarding'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'darkMode': darkMode,
      'notifications': notifications,
      'showOnboarding': showOnboarding,
    };
  }
}
