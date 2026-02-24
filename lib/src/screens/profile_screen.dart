import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/post.dart';
import '../widgets/content_tab_toggle.dart';
import '../widgets/post_card.dart';
import '../widgets/user_avatar.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;
  final PostService _postService = PostService();

  List<Post> _userPosts = [];
  List<Post> _userIssues = [];
  StreamSubscription<List<Post>>? _postsSubscription;
  StreamSubscription<List<Post>>? _issuesSubscription;
  String? _subscribedUserId;
  final Map<String, String?> _userVotes = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<AuthProvider>().userId;
    if (userId != null && userId != _subscribedUserId) {
      _subscribedUserId = userId;
      _postsSubscription?.cancel();
      _issuesSubscription?.cancel();
      _postsSubscription =
          _postService.getUserPostsStream(userId).listen((posts) {
        if (mounted) setState(() => _userPosts = posts);
      });
      _issuesSubscription =
          _postService.getUserPostsStream(userId, type: 'issue').listen((issues) {
        if (mounted) setState(() => _userIssues = issues);
      });
    }
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    _issuesSubscription?.cancel();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bool isManagement = auth.userRole == 'management';

    final List<String> currentTabs = ['My Posts', 'My Issues'];
    if (isManagement) currentTabs.add('Zone');

    return Column(
      children: [
        _buildProfileHeader(context, auth),
        ContentTabToggle(
          selectedTab: _selectedTab,
          tabs: currentTabs,
          onTabChanged: (index) {
            if (isManagement && index == 2) {
              context.push('/admin-zone');
            } else {
              setState(() => _selectedTab = index);
            }
          },
        ),
        Expanded(
          child: _selectedTab == 0
              ? _buildMyPostsTab(context, auth)
              : _buildMyIssuesTab(context, auth),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider auth) {
    return Container(
      color: AppTheme.surfaceWhite,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              UserAvatar(photoUrl: auth.photoUrl, radius: 40),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surfaceWhite, width: 2),
                ),
                child: const Icon(Icons.edit,
                    size: 14, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${auth.displayNameOrFallback.split(' ').first}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: auth.userRole == 'management'
                        ? Colors.amber[700]
                        : AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    auth.userRole.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (auth.email != null && auth.email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    auth.email!,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textMeta),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStat('${_userPosts.length}', 'Posts'),
                    const SizedBox(width: 20),
                    _buildStat('${_userIssues.length}', 'Issues'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.errorColor),
            tooltip: 'Sign Out',
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final messenger = ScaffoldMessenger.of(context);
              final router = GoRouter.of(context);

              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign Out',
                          style: TextStyle(color: AppTheme.errorColor)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await AuthService().signOut();
                  await authProvider.logout();
                  router.go('/registration');
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to sign out: $e')),
                  );
                }
              }
            },
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
            color: AppTheme.primaryBlue,
          ),
        ),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppTheme.textMeta)),
      ],
    );
  }

  Widget _buildMyPostsTab(BuildContext context, AuthProvider auth) {
    final userId = auth.userId;

    if (_userPosts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'You have not made any posts yet.',
            style: TextStyle(color: AppTheme.textMeta),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (userId != null) {
      for (final post in _userPosts) {
        if (post.id != null) _loadVoteFor(post.id!, userId);
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _userPosts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        final postId = post.id ?? '';
        return PostCard(
          username: auth.displayNameOrFallback,
          location: post.location ?? 'Unknown Location',
          timeAgo: _timeAgo(post.createdAt),
          status: post.type == 'issue' ? post.status : null,
          statusColor: post.status == 'Resolved'
              ? const Color(0xFF4CAF50)
              : AppTheme.primaryBlue,
          title: post.title,
          categoryIds: post.categoryIds,
          imageUrl: post.imageUrls.isNotEmpty ? post.imageUrls.first : null,
          authorPhotoUrl: auth.photoUrl,
          upvotes: post.upvotes,
          downvotes: post.downvotes,
          viewCount: post.views,
          commentCount: post.commentCount,
          userVote: _userVotes[postId],
          onTap: () => (post.type == 'issue' && auth.userRole == 'management')
              ? context.push('/issue-detail/$postId')
              : context.push('/post-detail/$postId'),
          onUpvote: userId != null && postId.isNotEmpty
              ? () => _handleUpvote(postId, userId)
              : null,
          onDownvote: userId != null && postId.isNotEmpty
              ? () => _handleDownvote(postId, userId)
              : null,
          onComment: () => (post.type == 'issue' && auth.userRole == 'management')
              ? context.push('/issue-detail/$postId')
              : context.push('/post-detail/$postId'),
        );
      },
    );
  }

  Widget _buildMyIssuesTab(BuildContext context, AuthProvider auth) {
    final userId = auth.userId;

    if (_userIssues.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'You have not reported any issues yet.',
            style: TextStyle(color: AppTheme.textMeta),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (userId != null) {
      for (final issue in _userIssues) {
        if (issue.id != null) _loadVoteFor(issue.id!, userId);
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _userIssues.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final issue = _userIssues[index];
        final issueId = issue.id ?? '';
        return PostCard(
          username: auth.displayNameOrFallback,
          location: issue.location ?? 'Unknown Location',
          timeAgo: _timeAgo(issue.createdAt),
          status: issue.status,
          statusColor: issue.status.toLowerCase() == 'resolved' ||
                  issue.status.toLowerCase() == 'completed'
              ? const Color(0xFF4CAF50)
              : AppTheme.primaryBlue,
          title: issue.title,
          categoryIds: issue.categoryIds,
          imageUrl: issue.imageUrls.isNotEmpty ? issue.imageUrls.first : null,
          authorPhotoUrl: auth.photoUrl,
          upvotes: issue.upvotes,
          downvotes: issue.downvotes,
          viewCount: issue.views,
          commentCount: issue.commentCount,
          userVote: _userVotes[issueId],
          onTap: issueId.isNotEmpty
              ? () => auth.userRole == 'management'
                  ? context.push('/issue-detail/$issueId')
                  : context.push('/post-detail/$issueId')
              : null,
          onUpvote: userId != null && issueId.isNotEmpty
              ? () => _handleUpvote(issueId, userId)
              : null,
          onDownvote: userId != null && issueId.isNotEmpty
              ? () => _handleDownvote(issueId, userId)
              : null,
          onComment: issueId.isNotEmpty
              ? () => auth.userRole == 'management'
                  ? context.push('/issue-detail/$issueId')
                  : context.push('/post-detail/$issueId')
              : null,
        );
      },
    );
  }
}
