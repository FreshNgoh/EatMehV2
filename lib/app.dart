import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/common/onboarding/onboarding_screen.dart';
import 'routes/app_router.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';

class EatMehApp extends StatelessWidget {
  const EatMehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => UserRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>())
                  ..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => ThemeBloc()..add(ThemeLoadRequested()),
          ),
          BlocProvider(
            create: (context) => SettingsBloc()..add(SettingsLoadRequested()),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, settingsState) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'EatMeh',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeState is ThemeLoaded
                      ? (themeState.isDarkMode
                          ? ThemeMode.dark
                          : ThemeMode.light)
                      : ThemeMode.light,
                  locale: settingsState is SettingsLoaded
                      ? Locale(settingsState.settings.language)
                      : const Locale('en'),
                  supportedLocales: const [Locale('en', ''), Locale('zh', '')],
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  home: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      if (authState is AuthLoading) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (authState is Authenticated) {
                        // Check if onboarding is needed
                        if (settingsState is SettingsLoaded &&
                            settingsState.settings.showOnboarding) {
                          return const OnboardingScreen();
                        }
                        return AppRouter.getHomeScreen(authState.user.role);
                      }

                      return const LoginScreen();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
