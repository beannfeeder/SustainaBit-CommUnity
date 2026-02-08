import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  int _selectedNavIndex = 0;

  // TODO: Replace with actual post data from backend/API
  final Map<String, dynamic> _mockPostData = {
    'username': 'Management',
    'location': 'Jalan Jati Perkasa',
    'timeAgo': '1 hour ago',
    'status': 'Resolved',
    'statusColor': const Color(0xFF4CAF50),
    'title': 'Large Pothole on Main Road',
    'description':
        "There's a large pothole on the main road that causes a lot of minor incidents. This needs to be take into notice by management and act immediately!",
    'tags': [
      {'label': 'Emergency', 'color': const Color(0xFFFF8A80)},
      {'label': 'Damaged Infrastructure', 'color': const Color(0xFFFFD54F)},
    ],
    'imageUrl': 'placeholder',
    'likes': 9,
    'views': '653,234 Views',
    'comments': '56 comments',
  };

  // TODO: Replace with actual comments data from backend/API
  // Fetch from API endpoint like: GET /api/posts/{postId}/comments
  final List<Map<String, dynamic>> _mockComments = [
    {
      'id': '1',
      'username': 'derrick@home',
      'timeAgo': '1 hour ago',
      'comment': '@Management pls deal with this problem!',
    },
    {
      'id': '2',
      'username': 'derrick@home',
      'timeAgo': '1 hour ago',
      'comment': '@Management pls deal with this problem!',
    },
    {
      'id': '3',
      'username': 'vibe123',
      'timeAgo': '1 hour ago',
      'comment': 'Agreed. Please address this issue as soon as possible!',
    },
    {
      'id': '4',
      'username': 'derrick@home',
      'timeAgo': '1 hour ago',
      'comment': '@Management pls deal with this problem!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppTopBar(
        onMenuPressed: () {
          Navigator.pop(context);
        },
        onSearchPressed: () {
          // TODO: Navigate to search
        },
        onNotificationPressed: () {
          // TODO: Navigate to notifications
        },
        onProfilePressed: () {
          context.push('/profile');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mockPostData['username'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_mockPostData['location']} • ${_mockPostData['timeAgo']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _mockPostData['statusColor'],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _mockPostData['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Post Title
                  Text(
                    _mockPostData['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_mockPostData['tags'] as List)
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: tag['color'],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag['label'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  // Post Description
                  Text(
                    _mockPostData['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Post Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      // TODO: Replace with actual image from backend
                      // child: Image.network(
                      //   _mockPostData['imageUrl'],
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats Row
                  Row(
                    children: [
                      _buildStat(
                        Icons.thumb_up_outlined,
                        _mockPostData['likes'].toString(),
                        Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        Icons.visibility_outlined,
                        _mockPostData['views'],
                        Colors.grey[600]!,
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        Icons.comment_outlined,
                        _mockPostData['comments'],
                        Colors.grey[600]!,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Duplicate Post Notice
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFFF9800),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF795548),
                        ),
                        children: [
                          TextSpan(
                            text: 'This is a duplicated post. ',
                          ),
                          TextSpan(
                            text: 'View source post here.',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Divider(thickness: 1, color: Colors.grey[300]),

            // Comments Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comments (${_mockComments.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // TODO: Replace with actual comments from backend
                  // Fetch from API: GET /api/posts/{postId}/comments
                  // Map response to Comment widgets
                  ..._mockComments.map((comment) => _CommentItem(
                        username: comment['username'],
                        timeAgo: comment['timeAgo'],
                        comment: comment['comment'],
                      )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          if (index == 0) {
            context.go('/home');
          } else if (index == 2) {
            context.push('/profile');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A90E2),
        onPressed: () {
          // TODO: Navigate to create post or add comment
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CommentItem extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String comment;

  const _CommentItem({
    required this.username,
    required this.timeAgo,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCommentAction(Icons.thumb_up_outlined, '0'),
                    const SizedBox(width: 16),
                    _buildCommentAction(Icons.thumb_down_outlined, '0'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentAction(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
