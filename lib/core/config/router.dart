import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_dream_solution/features/auth/presentation/screens/login_screen.dart';
import 'package:the_dream_solution/features/auth/presentation/screens/signup_screen.dart';
import 'package:the_dream_solution/features/main/presentation/screens/main_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/main', builder: (context, state) => const MainScreen()),
  ],
);
