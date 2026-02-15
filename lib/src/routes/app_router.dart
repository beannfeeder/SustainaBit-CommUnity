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

/// Central routing configuration for the app
/// Uses go_router for declarative routing with deep linking support
class AppRouter {
  static final router = GoRouter(
    initialLocation: '/registration',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // --- 2. 添加注册页面路由 ---
      GoRoute(
        path: '/registration',
        name: 'registration',
        builder: (context, state) => const RegistrationScreen(),
      ),
      // --- 3. 添加社区选择页面路由 ---
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
        path: '/post-creation', // 或者你的路径名
        builder: (context, state) {
          // 这一行非常关键：它把 URL 里的 ?user_location=xxx 提取出来
          // 这样 PostCreationScreen 里的 state.uri.queryParameters 才有值
          return const PostCreationScreen(); 
        },
      ),
      GoRoute(
        path: '/admin-zone',
        builder: (context, state) => const AdminAssignZoneScreen(),
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
