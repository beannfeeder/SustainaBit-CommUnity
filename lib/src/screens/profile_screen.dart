import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/content_tab_toggle.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0; // 0 for My Posts, 1 for My Issues

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile header
        _buildProfileHeader(context),

        // Tab toggle
        ContentTabToggle(
          selectedTab: _selectedTab,
          tabs: const ['My Posts', 'My Issues'],
          onTabChanged: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
        ),

        // Tab content
        Expanded(
          child: _selectedTab == 0
              ? _buildMyPostsTab(context)
              : _buildMyIssuesTab(context),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF4A90E2),
                child: Icon(Icons.person, size: 44, color: Colors.white),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Joe!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jalan Jati Perkasa',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStat('3', 'Posts'),
                    const SizedBox(width: 20),
                    _buildStat('3', 'Issues'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A90E2),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMyPostsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeedCard(
            context,
            title: 'Free Herbs at Block A Garden – Take What You Need!',
            author: 'Block A Garden',
            timeAgo: '5 hours ago',
            tag: 'Community Sharing',
            tagColor: Colors.green,
            content:
                'Hi neighbours! The community herb garden at Block A is growing really well 🌱\n'
                'We currently have mint, pandan, and curry leaves. Feel free to take some, just don\'t uproot the plants please 😊',
          ),
        ],
      ),
    );
  }

  Widget _buildMyIssuesTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Filter by...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            items: const [],
            onChanged: (value) {},
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildIssueCard(
                context,
                title: 'Drainage blocked at Jalan 6/7, Persiaran Tujuan',
                date: 'First reported 25/12/2025',
                status: 'Completed',
                statusColor: const Color(0xFF4CAF50),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildIssueCard(
                context,
                title: 'Tree Fallen at 29, Jalan 2/12, Taman Mayang',
                date: 'First reported 2/1/2026',
                status: 'In Progress',
                statusColor: Colors.amber,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildIssueCard(
                context,
                title: 'Sinkhole formed at Bukit Jalil Recreational Park',
                date: 'First reported 1/2/2026',
                status: 'In Progress',
                statusColor: Colors.red,
                onTap: () {},
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedCard(
    BuildContext context, {
    required String title,
    required String author,
    required String timeAgo,
    required String tag,
    required Color tagColor,
    required String content,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.spa, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$author  $timeAgo',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueCard(
    BuildContext context, {
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.brown[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
