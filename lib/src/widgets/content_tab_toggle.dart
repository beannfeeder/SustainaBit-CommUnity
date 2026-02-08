import 'package:flutter/material.dart';

class ContentTabToggle extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;
  final List<String> tabs;

  const ContentTabToggle({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    this.tabs = const ['Announcement', 'Forum'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++) ...[
            _buildTabButton(tabs[i], i),
            if (i < tabs.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
