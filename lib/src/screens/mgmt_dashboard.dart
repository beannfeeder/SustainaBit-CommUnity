import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/post_card.dart';

class MgmtDashboard extends StatefulWidget {
  const MgmtDashboard({super.key});

  @override
  State<MgmtDashboard> createState() => _MgmtDashboardState();
}

class _MgmtDashboardState extends State<MgmtDashboard> {
  final PageController _pendingIssuesController = PageController();
  int _currentPendingPage = 0;
  final int _totalPendingPages = 5; // Total number of pending issues

  final PostService _postService = PostService();
  final Map<String, String?> _userVotes = {};

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _loadVoteFor(String postId, String userId) async {
    if (_userVotes.containsKey(postId)) return;
    final vote = await _postService.getUserVote(postId, userId);
    if (mounted) setState(() => _userVotes[postId] = vote);
  }

  Future<void> _handleUpvote(String postId, String userId) async {
    await _postService.upvotePost(postId, userId);
    final vote = await _postService.getUserVote(postId, userId);
    if (mounted) setState(() => _userVotes[postId] = vote);
  }

  Future<void> _handleDownvote(String postId, String userId) async {
    await _postService.downvotePost(postId, userId);
    final vote = await _postService.getUserVote(postId, userId);
    if (mounted) setState(() => _userVotes[postId] = vote);
  }

  // Sample data for ratings
  String get currentRating => "Superb"; // Can be "Superb", "Moderate", "Poor"

  Color getRatingColor(String rating) {
    switch (rating) {
      case "Superb":
        return Colors.green;
      case "Moderate":
        return Colors.amber;
      case "Poor":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _nextPendingIssue() {
    if (_currentPendingPage < _totalPendingPages - 1) {
      _pendingIssuesController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPendingIssue() {
    if (_currentPendingPage > 0) {
      _pendingIssuesController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pendingIssuesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userId = auth.userId;
    final firstName = auth.displayNameOrFallback.split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting section
            Text(
              'Good Morning, $firstName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Stats cards row
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: "Pending Issues",
                    value: "15",
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: "In-Progress Task",
                    value: "4",
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: "Rating",
                    value: currentRating,
                    backgroundColor: Colors.white,
                    valueColor: getRatingColor(currentRating),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Pending Issues section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pending Issue",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    // Previous button - only show if not on first page
                    if (_currentPendingPage > 0)
                      GestureDetector(
                        onTap: _previousPendingIssue,
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    // Next button - only show if not on last page
                    if (_currentPendingPage < _totalPendingPages - 1)
                      GestureDetector(
                        onTap: _nextPendingIssue,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pending issues carousel
            SizedBox(
              height: 120,
              child: PageView(
                controller: _pendingIssuesController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPendingPage = page;
                  });
                },
                children: const [
                  PendingIssueCard(
                    title: "Tree has fallen",
                    description:
                        "Tree at Sungai Petani has fallen result in traffic jam, delay work could increase the severity to emergency",
                    urgency: "Urgent - Today 1:31pm",
                  ),
                  PendingIssueCard(
                    title: "Flash Flood",
                    description:
                        "Heavy rain caused flooding in the basement parking area.",
                    urgency: "Urgent - 2 hours ago",
                  ),
                  PendingIssueCard(
                    title: "Broken Bench",
                    description:
                        "A wooden bench in the community garden has a broken leg.",
                    urgency: "Normal - Today 10:00am",
                  ),
                  PendingIssueCard(
                    title: "Pothole on Main Road",
                    description:
                        "Small pothole starting to form near the guard house that needs immediate attention.",
                    urgency: "Normal - 5 hours ago",
                  ),
                  PendingIssueCard(
                    title: "Broken Water Pipe",
                    description:
                        "Water pipe burst near the community center causing water shortage issues.",
                    urgency: "Urgent - 30 minutes ago",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ── Recent Announcements Section ──
            const Text(
              "Recent Announcements",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            StreamBuilder<List<Post>>(
              stream: _postService.getPostsStream(type: 'announcement'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading announcements'));
                }
                final announcements = snapshot.data ?? [];

                if (announcements.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Text(
                      "No announcements today.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  );
                }

                // Load user votes safely
                if (userId != null) {
                  for (final post in announcements) {
                    if (post.id != null) _loadVoteFor(post.id!, userId);
                  }
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: announcements.length > 3
                      ? 3
                      : announcements
                          .length, // only show up to 3 latest in dashboard
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = announcements[index];
                    final postId = post.id ?? '';
                    return PostCard(
                      username: post.authorRole == 'management'
                          ? 'Management'
                          : (post.authorName.isNotEmpty
                              ? post.authorName
                              : post.authorId),
                      location: post.location ?? 'Unknown Location',
                      timeAgo: _timeAgo(post.createdAt),
                      status: post.type == 'issue' ? post.status : null,
                      statusColor: post.status == 'Resolved'
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2196F3),
                      title: post.title,
                      categoryIds: post.categoryIds, // tags
                      imageUrl: post.imageUrls.isNotEmpty
                          ? post.imageUrls.first
                          : null,
                      authorPhotoUrl: post.authorPhotoUrl.isNotEmpty
                          ? post.authorPhotoUrl
                          : null,
                      upvotes: post.upvotes,
                      downvotes: post.downvotes,
                      viewCount: post.views,
                      commentCount: post.commentCount,
                      userVote: _userVotes[postId],
                      onTap: () => context.push('/post-detail/$postId'),
                      onUpvote: userId != null && postId.isNotEmpty
                          ? () => _handleUpvote(postId, userId)
                          : null,
                      onDownvote: userId != null && postId.isNotEmpty
                          ? () => _handleDownvote(postId, userId)
                          : null,
                      onComment: () => context.push('/post-detail/$postId'),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            // In-Progress Tasks section
            const Text(
              "In-Progress Tasks",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Task items
            const InProgressTaskCard(
              title: "Broken Street Light near The Garden Mall",
              description:
                  "Street light was reportedly broken near the garden mall, worker has been dispatched and currently working on it.",
              status: "In Progress - Last updated on 7:30 a.m",
            ),
            const SizedBox(height: 12),
            const InProgressTaskCard(
              title: "Broken Street Light near The Garden Mall",
              description:
                  "Street light was reportedly broken near the garden mall, worker has been dispatched and currently working on it.",
              status: "In Progress - Last updated on 7:30 a.m",
            ),
          ],
        ),
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final Color? valueColor;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PendingIssueCard extends StatelessWidget {
  final String title;
  final String description;
  final String urgency;

  const PendingIssueCard({
    super.key,
    required this.title,
    required this.description,
    required this.urgency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            urgency,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: urgency.contains("Urgent")
                  ? AppTheme.errorColor
                  : AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class InProgressTaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String status;

  const InProgressTaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
