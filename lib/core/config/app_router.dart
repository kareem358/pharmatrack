

class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';
  static const String pos = '/pos';
  static const String customers = '/customers';
  static const String reports = '/reports';
  static const String settingsRoute = '/settings'; // ✅ renamed to avoid conflict

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const RoleDashboard());
      case inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      case pos:
        return MaterialPageRoute(builder: (_) => const PosScreen());
      case customers:
        return MaterialPageRoute(builder: (_) => const CustomersScreen());
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      case settingsRoute: // ✅ use new constant
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route not found")),
          ),
        );
    }
  }
}




/*

import 'package:flutter/material.dart';
import 'package:pharmatrack/features/auth/presentation/login_screen.dart';
import 'package:pharmatrack/features/auth/presentation/role_dashboard.dart';

import '../../features/customers/presentation/customers_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/pos/presentation/pos_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';


class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';
  static const String pos = '/pos';
  static const String customers = '/customers';
  static const String reports = '/reports';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const RoleDashboard());
      case inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      case pos:
        return MaterialPageRoute(builder: (_) => const PosScreen());
      case customers:
        return MaterialPageRoute(builder: (_) => const CustomersScreen());
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route not found")),
          ),
        );
    }
  }
}
*/
