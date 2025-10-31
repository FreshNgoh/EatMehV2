import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user/user_settings_model.dart';
import '../../../data/services/local/shared_prefs_service.dart';

// Events
abstract class SettingsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {}

class SettingsLanguageChanged extends SettingsEvent {
  final String language;
  SettingsLanguageChanged(this.language);

  @override
  List<Object> get props => [language];
}

class SettingsDarkModeToggled extends SettingsEvent {}

class SettingsNotificationsToggled extends SettingsEvent {}

class SettingsOnboardingCompleted extends SettingsEvent {}

// States
abstract class SettingsState extends Equatable {
  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserSettings settings;
  SettingsLoaded(this.settings);

  @override
  List<Object> get props => [settings];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<SettingsLoadRequested>(_onSettingsLoadRequested);
    on<SettingsLanguageChanged>(_onSettingsLanguageChanged);
    on<SettingsDarkModeToggled>(_onSettingsDarkModeToggled);
    on<SettingsNotificationsToggled>(_onSettingsNotificationsToggled);
    on<SettingsOnboardingCompleted>(_onSettingsOnboardingCompleted);
  }

  void _onSettingsLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) {
    final settings = UserSettings(
      language: SharedPrefsService.getLanguage(),
      darkMode: SharedPrefsService.getDarkMode(),
      notifications: SharedPrefsService.getNotifications(),
      showOnboarding: !SharedPrefsService.getOnboardingCompleted(),
    );
    emit(SettingsLoaded(settings));
  }

  Future<void> _onSettingsLanguageChanged(
    SettingsLanguageChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      await SharedPrefsService.setLanguage(event.language);
      emit(SettingsLoaded(UserSettings(
        language: event.language,
        darkMode: currentState.settings.darkMode,
        notifications: currentState.settings.notifications,
        showOnboarding: currentState.settings.showOnboarding,
      )));
    }
  }

  Future<void> _onSettingsDarkModeToggled(
    SettingsDarkModeToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newValue = !currentState.settings.darkMode;
      await SharedPrefsService.setDarkMode(newValue);
      emit(SettingsLoaded(UserSettings(
        language: currentState.settings.language,
        darkMode: newValue,
        notifications: currentState.settings.notifications,
        showOnboarding: currentState.settings.showOnboarding,
      )));
    }
  }

  Future<void> _onSettingsNotificationsToggled(
    SettingsNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      final newValue = !currentState.settings.notifications;
      await SharedPrefsService.setNotifications(newValue);
      emit(SettingsLoaded(UserSettings(
        language: currentState.settings.language,
        darkMode: currentState.settings.darkMode,
        notifications: newValue,
        showOnboarding: currentState.settings.showOnboarding,
      )));
    }
  }

  Future<void> _onSettingsOnboardingCompleted(
    SettingsOnboardingCompleted event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      await SharedPrefsService.setOnboardingCompleted(true);
      emit(SettingsLoaded(UserSettings(
        language: currentState.settings.language,
        darkMode: currentState.settings.darkMode,
        notifications: currentState.settings.notifications,
        showOnboarding: false,
      )));
    }
  }
}
