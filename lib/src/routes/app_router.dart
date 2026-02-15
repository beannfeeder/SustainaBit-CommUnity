import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/welcome_registration_screen.dart';
import '../screens/search_screen.dart';
import '../screens/post_creation_screen.dart';
import '../screens/post_detail_screen.dart';
import '../screens/admin_assign_zone_screen.dart';
import '../screens/mgmt_dashboard.dart';
import '../screens/issue_page.dart';

/// Central routing configuration for the app
/// Uses go_router for declarative routing with deep linking support
class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/registration',
        name: 'registration',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/welcome-registration',
        name: 'welcome-registration',
        builder: (context, state) => const WelcomeRegistrationScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/post-detail',
        name: 'post-detail',
        builder: (context, state) => const PostDetailScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/post-creation',
        builder: (context, state) {
          return const PostCreationScreen(); 
        },
      ),
      GoRoute(
        path: '/admin-zone',
        builder: (context, state) => const AdminAssignZoneScreen(),
      ),
      // Management routes
      GoRoute(
        path: '/mgmt-dashboard',
        name: 'mgmt-dashboard',
        builder: (context, state) => const MgmtDashboard(),
      ),
      GoRoute(
        path: '/issues',
        name: 'issues',
        builder: (context, state) => const IssuePage(),
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

/// Error screen displayed when navigation fails
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(
        child: Text('Page not found'),
      ),
    );
  }
}
