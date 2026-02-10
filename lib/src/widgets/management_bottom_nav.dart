import 'package:flutter/material.dart';
import '../screens/issue_page.dart';
import '../screens/mgmt_dashboard.dart';

class ManagementBottomNav extends StatefulWidget {
  final int currentIndex;
  
  const ManagementBottomNav({super.key, this.currentIndex = 0});

  @override
  State<ManagementBottomNav> createState() => _ManagementBottomNavState();
}

class _ManagementBottomNavState extends State<ManagementBottomNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return; // Don't navigate to same page
    
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MgmtDashboard()),
        );
        break;
      case 1: // Feed
        _showToBeImplemented('Feed');
        break;
      case 2: // Issues
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IssuePage()),
        );
        break;
      case 3: // Profile
        _showToBeImplemented('Profile');
        break;
    }
  }

  void _showToBeImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - To Be Implemented'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1E5BB8),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Issues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}