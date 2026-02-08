import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onCreatePressed;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFFE8E8E3),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(Icons.person, 'Profile', 2),
          ],
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
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
