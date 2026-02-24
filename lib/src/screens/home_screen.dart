import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/content_tab_toggle.dart';
import '../widgets/post_card.dart';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0 = Announcement, 1 = Forum

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContentTabToggle(
          selectedTab: _selectedTab,
          onTabChanged: (index) => setState(() => _selectedTab = index),
        ),
        Expanded(
          child: _selectedTab == 1
              ? const _PostListView(postType: 'post')
              : const _PostListView(postType: 'announcement'),
        ),
      ],
    );
  }
}

// ── Reusable Post List View for both Forum and Announcements ─────────────────────────────
class _PostListView extends StatefulWidget {
  final String postType;

  const _PostListView({required this.postType});

  @override
  State<_PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<_PostListView> {
  final PostService _postService = PostService();

  // Cache of userVote per postId so cards can render active state
  final Map<String, String?> _userVotes = {};

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _loadVoteFor(String postId, String userId) async {
    if (_userVotes.containsKey(postId)) return; // already loaded
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
    final userId = context.watch<AuthProvider>().userId;

    return StreamBuilder<List<Post>>(
      stream: _postService.getPostsStream(type: widget.postType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.forum_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    widget.postType == 'announcement'
                        ? 'No announcements yet.'
                        : 'No posts yet.\nBe the first to share something!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        }

        // Trigger vote loads for all posts (non-blocking)
        if (userId != null) {
          for (final post in posts) {
            if (post.id != null) _loadVoteFor(post.id!, userId);
          }
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final post = posts[index];
            final postId = post.id ?? '';
            return PostCard(
              username: post.authorRole == 'management'
                  ? 'Management'
                  : (post.authorName.isNotEmpty
                      ? post.authorName
                      : post.authorId),
              location: post.location ?? 'Unknown Location',
              timeAgo: _timeAgo(post.createdAt),
              status: post.status,
              statusColor: post.status == 'Resolved'
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF2196F3),
              title: post.title,
              categoryIds: post.categoryIds,
              imageUrl: post.imageUrls.isNotEmpty ? post.imageUrls.first : null,
              authorPhotoUrl:
                  post.authorPhotoUrl.isNotEmpty ? post.authorPhotoUrl : null,
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
    );
  }
}
