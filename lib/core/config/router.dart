import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_dream_solution/features/auth/presentation/screens/login_screen.dart';
import 'package:the_dream_solution/features/auth/presentation/screens/signup_screen.dart';
import 'package:the_dream_solution/features/board/presentation/screens/board_create_screen.dart';
import 'package:the_dream_solution/features/main/presentation/screens/main_screen.dart';
import 'package:the_dream_solution/core/storage/secure_storage.dart';
import 'package:the_dream_solution/core/services/navigation_service.dart';

final _secureStorage = SecureStorage();

final goRouter = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) async {
    final isLoggedIn = await _secureStorage.isLoggedIn();
    final isLoginRoute = state.matchedLocation == '/login';
    final isSignupRoute = state.matchedLocation == '/signup';

    if (isLoggedIn && (isLoginRoute || isSignupRoute)) {
      return '/main';
    }

    if (!isLoggedIn && !isLoginRoute && !isSignupRoute) {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/main', builder: (context, state) => const MainScreen()),
    GoRoute(
      path: '/board/create',
      builder: (context, state) => const BoardCreateScreen(),
    ),
  ],
);

// Initialize NavigationService with the router
void initializeNavigation() {
  NavigationService.setGoRouter(goRouter);
}
