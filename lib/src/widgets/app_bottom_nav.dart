import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onCreatePressed;
  // 🌟 新增：区分身份的参数
  final bool isManagement;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isManagement = false, // 默认为普通用户
    this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    // 🌟 根据身份动态决定显示的按钮列表
    List<Widget> navItems;

    if (isManagement) {
    navItems = [
      _buildNavItem(Icons.dashboard, 'Dashboard', 0),
      _buildNavItem(Icons.dynamic_feed, 'Feed', 1), // 管理频道里也可以看 Feed
      const SizedBox(width: 48), 
      _buildNavItem(Icons.report_problem, 'Issues', 3),
      _buildNavItem(Icons.person, 'Profile', 4),
    ];
  } else {
    navItems = [
      _buildNavItem(Icons.home, 'Home', 0),
      const SizedBox(width: 48), 
      _buildNavItem(Icons.person, 'Profile', 2),
    ];
  }

    return BottomAppBar(
      color: const Color(0xFFE8E8E3),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4A90E2) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF4A90E2) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class CreateButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CreateButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF4A90E2),
      onPressed: onPressed ?? () {},
      elevation: 4,
      shape: const CircleBorder(), // 确保是正圆形
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}