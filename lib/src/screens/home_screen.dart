import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/content_tab_toggle.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0 for Announcement, 1 for Forum
  int _selectedNavIndex = 0; // Bottom navigation index

  @override
  Widget build(BuildContext context) {
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
          // TODO: Navigate to profile
          context.push('/profile');
        },
      ),
      body: Column(
        children: [
          ContentTabToggle(
            selectedTab: _selectedTab,
            onTabChanged: (index) {
              setState(() {
                _selectedTab = index;
              });
              // TODO: Load different content based on tab
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PostCard(
                    username: 'Management',
                    location: 'Jalan Jati Perkasa',
                    timeAgo: '1 hour ago',
                    status: 'Resolved',
                    statusColor: const Color(0xFF4CAF50),
                    title: 'Large Pothole on Main Road',
                    tags: const [
                      PostTag(label: 'Emergency', color: Color(0xFFFF8A80)),
                      PostTag(
                        label: 'Damaged Infrastructure',
                        color: Color(0xFFFFD54F),
                      ),
                    ],
                    imageUrl: 'placeholder', // Mock image
                    likes: 9,
                    views: '653,234 Views',
                    comments: '56 comments',
                    duplicatePostLabel: 'Duplicated Post',
                    onTap: () {
                      // TODO: Navigate to post detail
                      context.push('/issue-detail');
                    },
                    onLike: () {
                      // TODO: Handle like action
                    },
                    onComment: () {
                      // TODO: Navigate to comments
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          // TODO: Navigate based on index
          if (index == 0) {
            // Already on home
          } else if (index == 2) {
            context.push('/profile');
          }
        },
      ),
      floatingActionButton: CreateButton(
        onPressed: () {
          // TODO: Navigate to create post screen
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
