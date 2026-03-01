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
import '../screens/mgmt_post_creation_screen.dart';
import '../screens/post_detail_screen.dart';
import '../screens/admin_assign_zone_screen.dart';
import '../screens/mgmt_dashboard.dart';
import '../screens/issue_page.dart';
import '../screens/issue_detail_page.dart';
import '../widgets/main_shell.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../src/screens/super_admin/heatmap_dashboard_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/registration',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isLoggedIn = auth.isLoggedIn;
      final isManagement = auth.userRole == 'management';
      final path = state.uri.path;

      final isAuthRoute = path == '/' || path == '/registration';

      if (!isLoggedIn && !isAuthRoute) return '/registration';

      if (isLoggedIn && isAuthRoute) {
        return isManagement ? '/mgmt-dashboard' : '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: '/registration',
          name: 'registration',
          builder: (context, state) => const RegistrationScreen()),
      GoRoute(
          path: '/welcome-registration',
          name: 'welcome-registration',
          builder: (context, state) => const WelcomeRegistrationScreen()),

      // ── Shell: 负责底部导航栏的页面组 ──
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // 管理层首页
          GoRoute(
            path: '/mgmt-dashboard',
            name: 'mgmt-dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MgmtDashboard()),
          ),
          // 普通用户 Feed
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          // 普通用户 Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
          // 🌟 新增：管理层专用的 Feed 分身
          GoRoute(
            path: '/mgmt-home',
            name: 'mgmt-home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          // 🌟 新增：管理层专用的 Profile 分身
          GoRoute(
            path: '/mgmt-profile',
            name: 'mgmt-profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
          // 🌟 新增：问题列表
          GoRoute(
            path: '/issues',
            name: 'issues',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: IssuePage()),
          ),
        ],
      ),

      // ── Non-shell routes (全屏页面) ──
      GoRoute(
        path: '/post-detail/:postId',
        name: 'post-detail',
        builder: (context, state) {
          final postId = state.pathParameters['postId'] ?? '';
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/issue-detail/:issueId',
        name: 'issue-detail',
        builder: (context, state) {
          final issueId = state.pathParameters['issueId'] ?? '';
          return IssueDetailPage(issueId: issueId);
        },
      ),
      GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen()),
      GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchScreen()),
      GoRoute(
          path: '/post-creation',
          builder: (context, state) => const PostCreationScreen()),
      GoRoute(
          path: '/mgmt-post-creation',
          builder: (context, state) => const MgmtPostCreationScreen()),
      GoRoute(
          path: '/admin-zone',
          builder: (context, state) => const AdminAssignZoneScreen()),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')));
  }
}
