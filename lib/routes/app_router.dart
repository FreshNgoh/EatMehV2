import 'package:eatmehv2/presentation/screens/admin/admin_screen.dart';
import 'package:eatmehv2/presentation/screens/onboarding/user_manual_screen.dart';
import 'package:eatmehv2/presentation/screens/user/home_screen.dart';
import 'package:flutter/material.dart';

import '../core/constants/route_constants.dart';
import '../data/models/user/user_model.dart';
import '../presentation/screens/auth/login_screen.dart';

class AppRouter {
  static Widget getHomeScreen(UserModel user) {
    if (user.settings?.showOnboarding == true) {
      return UserManualScreen(user: user);
    }

    switch (user.role) {
      case 'admin':
        return const AdminScreen();
      case 'trainer':
        return const HomeScreen();
      default:
        return const HomeScreen();
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteConstants.home:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => getHomeScreen(user));

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
