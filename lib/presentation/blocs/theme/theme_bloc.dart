import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/services/local/shared_prefs_service.dart';

// Events
abstract class ThemeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ThemeLoadRequested extends ThemeEvent {}

class ThemeToggled extends ThemeEvent {}

// States
abstract class ThemeState extends Equatable {
  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final bool isDarkMode;
  ThemeLoaded(this.isDarkMode);

  @override
  List<Object> get props => [isDarkMode];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    on<ThemeLoadRequested>(_onThemeLoadRequested);
    on<ThemeToggled>(_onThemeToggled);
  }

  void _onThemeLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) {
    final isDarkMode = SharedPrefsService.getDarkMode();
    emit(ThemeLoaded(isDarkMode));
  }

  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    final currentState = state;
    if (currentState is ThemeLoaded) {
      final newValue = !currentState.isDarkMode;
      await SharedPrefsService.setDarkMode(newValue);
      emit(ThemeLoaded(newValue));
    }
  }
}
