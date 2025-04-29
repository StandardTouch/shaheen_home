import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_home/home_page.dart';
import 'package:shaheen_home/screens/admin/admin_dashboard_screen.dart';
import 'package:shaheen_home/screens/admin/admin_login_screen.dart';

final GoRouter router = GoRouter(
  // if web initial location is /admin/login
  // if mobile initial location is /
  initialLocation: kIsWeb ? '/admin/login' : '/',
  routes: [
    GoRoute(
      path: '/admin/login',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: "/",
      builder: (context, state) => const HomePage(),
    ),
  ],
);
