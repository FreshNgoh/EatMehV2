import 'package:eatmehv2/presentation/screens/admin/admin_screen.dart';
import 'package:eatmehv2/presentation/screens/user/home_screen.dart';
import 'package:flutter/material.dart';

import '../core/constants/route_constants.dart';
import '../presentation/screens/auth/login_screen.dart';

class AppRouter {
  static Widget getHomeScreen(String role) {
    switch (role) {
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
        final role = settings.arguments as String? ?? 'user';
        return MaterialPageRoute(builder: (_) => getHomeScreen(role));

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
