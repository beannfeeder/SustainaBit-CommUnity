import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for the splash to display briefly
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // If still loading, wait for the auth provider to finish
    if (authProvider.isLoading) {
      void listener() {
        if (!authProvider.isLoading && mounted) {
          authProvider.removeListener(listener);
          _navigateByRole(authProvider);
        }
      }
      authProvider.addListener(listener);
    } else {
      _navigateByRole(authProvider);
    }
  }

  void _navigateByRole(AuthProvider authProvider) {
    if (!mounted) return;
    if (authProvider.isAuthenticated) {
      if (authProvider.userRole == UserRole.management) {
        context.go('/mgmt-dashboard');
      } else {
        context.go('/home');
      }
    } else {
      context.go('/registration');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'SustainaBit CommUnity',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
