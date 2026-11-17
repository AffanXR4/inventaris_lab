import 'package:flutter/material.dart';

import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/main_navigation_page.dart';
import '../pages/home/home_page.dart';
import '../pages/inventory/inventory_page.dart';
import '../pages/profile/profile_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String mainNavigation = '/main';
  static const String home = '/home';
  static const String inventory = '/inventory';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      mainNavigation: (context) => const MainNavigationPage(),
      home: (context) => const HomePage(),
      inventory: (context) => const InventoryPage(),
      profile: (context) => const ProfilePage(),
    };
  }
}
