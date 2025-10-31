import 'package:flutter/material.dart';
import '../core/constants/route_constants.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/common/home/home_screen.dart';
import '../presentation/screens/trainer/trainer_home_screen.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';

class AppRouter {
  static Widget getHomeScreen(String role) {
    switch (role) {
      case 'admin':
        return const AdminDashboardScreen();
      case 'trainer':
        return const TrainerHomeScreen();
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
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
