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

  String _urgencyLabel(Map<String, dynamic>? priority) {
    switch (priority?['level'] as String? ?? 'none') {
      case 'critical':
        return 'Critical';
      case 'high':
        return 'Urgent';
      case 'medium':
        return 'Moderate';
      case 'low':
        return 'Low';
      default:
        return 'Normal';
    }
  }

  bool _isUrgent(Map<String, dynamic>? priority) {
    final level = priority?['level'] as String? ?? 'none';
    return level == 'critical' || level == 'high';
  }

  String _computeRating(List<Post> allIssues) {
    if (allIssues.isEmpty) return 'N/A';
    final resolved = allIssues
        .where((i) =>
            ['resolved', 'completed'].contains(i.status.toLowerCase()))
        .length;
    final ratio = resolved / allIssues.length;
    if (ratio >= 0.7) return 'Superb';
    if (ratio >= 0.4) return 'Moderate';
    return 'Poor';
  }

  Color getRatingColor(String rating) {
    switch (rating) {
      case 'Superb':
        return Colors.green;
      case 'Moderate':
        return Colors.amber;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
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
      body: StreamBuilder<List<Post>>(
        stream: _postService.getPostsStream(type: 'issue'),
        builder: (context, issueSnap) {
          final allIssues = issueSnap.data ?? [];
          final isLoading =
              issueSnap.connectionState == ConnectionState.waiting;

          final pendingIssues = allIssues
              .where((i) =>
                  ['open', 'pending'].contains(i.status.toLowerCase()))
              .toList();
          final inProgressIssues = allIssues
              .where((i) => i.status.toLowerCase() == 'in progress')
              .toList();
          final rating = _computeRating(allIssues);

          // Clamp carousel page if pending list shrank
          if (_currentPendingPage >= pendingIssues.length &&
              pendingIssues.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _currentPendingPage = pendingIssues.length - 1);
              }
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting ──────────────────────────────────────────────
                Text(
                  'Good Morning, $firstName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Stats cards ───────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Pending Issues',
                        value: isLoading ? '…' : '${pendingIssues.length}',
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: 'In-Progress Task',
                        value: isLoading ? '…' : '${inProgressIssues.length}',
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: 'Rating',
                        value: isLoading ? '…' : rating,
                        backgroundColor: Colors.white,
                        valueColor: getRatingColor(rating),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // ── Pending Issues carousel ───────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pending Issue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (pendingIssues.length > 1)
                      Row(
                        children: [
                          if (_currentPendingPage > 0)
                            GestureDetector(
                              onTap: () {
                                _pendingIssuesController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
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
                                        offset: Offset(0, 2)),
                                  ],
                                ),
                                child: const Icon(Icons.chevron_left,
                                    color: AppTheme.primaryBlue, size: 20),
                              ),
                            ),
                          if (_currentPendingPage < pendingIssues.length - 1)
                            GestureDetector(
                              onTap: () {
                                _pendingIssuesController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
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
                                        offset: Offset(0, 2)),
                                  ],
                                ),
                                child: const Icon(Icons.chevron_right,
                                    color: AppTheme.primaryBlue, size: 20),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (isLoading)
                  const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()))
                else if (pendingIssues.isEmpty)
                  Container(
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Text('No pending issues.',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 14)),
                  )
                else
                  SizedBox(
                    height: 120,
                    child: PageView.builder(
                      controller: _pendingIssuesController,
                      itemCount: pendingIssues.length,
                      onPageChanged: (page) =>
                          setState(() => _currentPendingPage = page),
                      itemBuilder: (context, index) {
                        final issue = pendingIssues[index];
                        return GestureDetector(
                          onTap: () =>
                              context.push('/issue-detail/${issue.id}'),
                          child: PendingIssueCard(
                            title: issue.title,
                            description: issue.description,
                            urgency:
                                '${_urgencyLabel(issue.priority)} · ${_timeAgo(issue.createdAt)}',
                            isUrgent: _isUrgent(issue.priority),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 30),

                // ── Recent Announcements ──────────────────────────────────
                const Text(
                  'Recent Announcements',
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
                          'No announcements today.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      );
                    }

                    if (userId != null) {
                      for (final post in announcements) {
                        if (post.id != null) _loadVoteFor(post.id!, userId);
                      }
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          announcements.length > 3 ? 3 : announcements.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
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
                          status:
                              post.type == 'issue' ? post.status : null,
                          statusColor: post.status == 'Resolved'
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF2196F3),
                          title: post.title,
                          categoryIds: post.categoryIds,
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
                          onTap: () =>
                              context.push('/post-detail/$postId'),
                          onUpvote: userId != null && postId.isNotEmpty
                              ? () => _handleUpvote(postId, userId)
                              : null,
                          onDownvote: userId != null && postId.isNotEmpty
                              ? () => _handleDownvote(postId, userId)
                              : null,
                          onComment: () =>
                              context.push('/post-detail/$postId'),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),

                // ── In-Progress Tasks ─────────────────────────────────────
                const Text(
                  'In-Progress Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (inProgressIssues.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Text(
                      'No tasks in progress.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inProgressIssues.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final issue = inProgressIssues[index];
                      return GestureDetector(
                        onTap: () =>
                            context.push('/issue-detail/${issue.id}'),
                        child: InProgressTaskCard(
                          title: issue.title,
                          description: issue.description,
                          timeAgo: _timeAgo(issue.createdAt),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Reusable card widgets ──────────────────────────────────────────────────

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
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
  final bool isUrgent;

  const PendingIssueCard({
    super.key,
    required this.title,
    required this.description,
    required this.urgency,
    this.isUrgent = false,
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
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
              color: isUrgent ? AppTheme.errorColor : AppTheme.primaryBlue,
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
  final String timeAgo;

  const InProgressTaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'In Progress · $timeAgo',
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
