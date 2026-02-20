import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/content_tab_toggle.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0 for Announcement, 1 for Forum

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContentTabToggle(
          selectedTab: _selectedTab,
          onTabChanged: (index) {
            setState(() {
              _selectedTab = index;
            });
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
                  imageUrl: 'placeholder',
                  likes: 9,
                  views: '653,234 Views',
                  comments: '56 comments',
                  duplicatePostLabel: 'Duplicated Post',
                  onTap: () {
                    context.push('/post-detail');
                  },
                  onLike: () {},
                  onComment: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
