import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'app_top_bar.dart';
import 'app_bottom_nav.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  
  // 🌟 修改：把 /mgmt-home 和 /mgmt-profile 加入“管理模式阵营”
  bool _isViewingManagement(String location) {
    return location.startsWith('/mgmt-dashboard') || 
           location.startsWith('/mgmt-home') || 
           location.startsWith('/mgmt-profile') || 
           location.startsWith('/issues') || 
           location.startsWith('/admin-zone');
  }

  int _locationToIndex(String location, bool isMgmtView) {
    if (isMgmtView) {
      if (location.startsWith('/mgmt-dashboard')) return 0;
      if (location.startsWith('/mgmt-home')) return 1; // 🌟 对应 Feed
      if (location.startsWith('/issues')) return 3;
      if (location.startsWith('/mgmt-profile')) return 4; // 🌟 对应 Profile
      return 0;
    } else {
      if (location.startsWith('/profile')) return 2;
      return 0; // /home
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final location = GoRouterState.of(context).uri.toString();
    
    final bool isManagementRole = auth.userRole == 'management';
    final bool isInMgmtView = isManagementRole && _isViewingManagement(location);

    final currentIndex = _locationToIndex(location, isInMgmtView);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppTopBar(
        onMenuPressed: () {},
        onSearchPressed: () => context.push('/search'),
        onNotificationPressed: () {},
        onProfilePressed: () {
          // 顶部栏的头像点击：如果当前在管理模式，跳到管理层 Profile
          if (isInMgmtView) {
            context.go('/mgmt-profile');
          } else {
            context.go('/profile');
          }
        },
      ),
      body: widget.child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        isManagement: isInMgmtView, 
        onTap: (index) {
          if (isInMgmtView) {
            // 🌟 核心修改：在 5 按钮模式下，跳转走专门的 /mgmt- 路径
            switch (index) {
              case 0: context.go('/mgmt-dashboard'); break;
              case 1: context.go('/mgmt-home'); break; // 看这里！
              case 3: context.go('/issues'); break;
              case 4: context.go('/mgmt-profile'); break; // 还有这里！
            }
          } else {
            switch (index) {
              case 0: context.go('/home'); break;
              case 2: context.go('/profile'); break;
            }
          }
        },
      ),
      floatingActionButton: CreateButton(
        onPressed: () => context.push('/post-creation'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}