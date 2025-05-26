import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static GoRouter? _goRouter;

  static void setGoRouter(GoRouter router) {
    _goRouter = router;
  }

  static void navigateToLogin() {
    if (_goRouter != null) {
      _goRouter!.go('/login');
    } else {
      debugPrint('⚠️ GoRouter not initialized in NavigationService');
    }
  }

  static void clearAllAndNavigateToLogin() {
    if (_goRouter != null) {
      // Clear all routes and navigate to login
      _goRouter!.go('/login');
    } else {
      debugPrint('⚠️ GoRouter not initialized in NavigationService');
    }
  }
}
