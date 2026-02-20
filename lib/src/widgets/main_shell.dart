import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_top_bar.dart';
import 'app_bottom_nav.dart';

/// Persistent shell that wraps all bottom-nav destinations.
/// [IndexedStack] keeps every tab alive so state is preserved between switches.
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// Returns the bottom-nav index for the current GoRouter location.
  int _locationToIndex(String location) {
    if (location.startsWith('/profile')) return 2; // Profile is at index 2 in AppBottomNav
    return 0; // '/home' and anything else → Home tab
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppTopBar(
        onMenuPressed: () {
          // TODO: Open drawer/menu
        },
        onSearchPressed: () {
          context.push('/search');
        },
        onNotificationPressed: () {
          // TODO: Navigate to notifications
        },
        onProfilePressed: () {
          context.go('/profile');
        },
      ),
      // GoRouter's ShellRoute puts the matched child here.
      body: widget.child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 2: // profile
              context.go('/profile');
              break;
          }
        },
      ),
      floatingActionButton: CreateButton(
        onPressed: () {
          context.push('/post-creation');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
