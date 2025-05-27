import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_dream_solution/features/auth/presentation/screens/login_screen.dart';
import 'package:the_dream_solution/features/auth/presentation/screens/signup_screen.dart';
import 'package:the_dream_solution/features/board/presentation/screens/board_create_screen.dart';
import 'package:the_dream_solution/features/board/presentation/screens/board_detail_screen.dart';
import 'package:the_dream_solution/features/board/presentation/screens/board_list_screen.dart';
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
    GoRoute(
      path: '/board/list',
      builder: (context, state) => const BoardListScreen(),
    ),
    GoRoute(
      path: '/board/:id/edit',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return BoardCreateScreen(boardId: id);
      },
    ),
    GoRoute(
      path: '/board/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return BoardDetailScreen(boardId: id);
      },
    ),
  ],
);

// Token 유무에 따른 /main screen 자동 이동.
void initializeNavigation() {
  NavigationService.setGoRouter(goRouter);
}
