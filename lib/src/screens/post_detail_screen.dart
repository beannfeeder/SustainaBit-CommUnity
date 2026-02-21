import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/user_avatar.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  int _selectedNavIndex = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  String? _userVote; // 'up', 'down', or null

  bool get _isDemo => widget.postId == 'demo';

  @override
  void initState() {
    super.initState();
    if (!_isDemo) {
      _loadUserVote();
      PostService().incrementViews(widget.postId);
    }
  }

  Future<void> _loadUserVote() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;
    final vote = await PostService().getUserVote(widget.postId, userId);
    if (mounted) setState(() => _userVote = vote);
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final auth = context.read<AuthProvider>();
    if (auth.userId == null) return;

    setState(() => _isSubmitting = true);
    try {
      await PostService().addComment(
        widget.postId,
        Comment(
          authorId: auth.userId!,
          authorName: auth.displayNameOrFallback,
          authorRole: auth.userRole,
          authorPhotoUrl: auth.photoUrl ?? '',
          content: text,
          createdAt: DateTime.now(),
        ),
      );
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to post comment: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleUpvote(Post post) async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;
    await PostService().upvotePost(post.id!, userId);
    await _loadUserVote();
  }

  Future<void> _handleDownvote(Post post) async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;
    await PostService().downvotePost(post.id!, userId);
    await _loadUserVote();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppTopBar(
        onMenuPressed: () => Navigator.pop(context),
        onSearchPressed: () {},
        onNotificationPressed: () {},
        onProfilePressed: () => context.push('/profile'),
      ),
      body: _isDemo ? _buildDemoBody() : _buildLiveBody(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
          if (index == 0) context.go('/home');
          if (index == 2) context.push('/profile');
        },
      ),
    );
  }

  // ── Live (real Firestore post) ────────────────────────────────────────────

  Widget _buildLiveBody() {
    return FutureBuilder<Post?>(
      future: PostService().getPostById(widget.postId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) {
          return const Center(child: Text('Post not found.'));
        }
        final post = snap.data!;
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _PostHeader(post: post, timeAgo: _timeAgo(post.createdAt)),
                  _VoteBar(
                    post: post,
                    userVote: _userVote,
                    onUpvote: () => _handleUpvote(post),
                    onDownvote: () => _handleDownvote(post),
                  ),
                  Divider(thickness: 1, color: Colors.grey[200]),
                  _CommentsList(postId: widget.postId, timeAgo: _timeAgo),
                ],
              ),
            ),
            _CommentInputBar(
              controller: _commentController,
              isSubmitting: _isSubmitting,
              onSubmit: _submitComment,
            ),
          ],
        );
      },
    );
  }

  // ── Demo fallback ─────────────────────────────────────────────────────────
  Widget _buildDemoBody() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Large Pothole on Main Road',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Jalan Jati Perkasa • 1 hour ago',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 16),
                    const Text(
                      "There's a large pothole on the main road that causes a lot of minor incidents.",
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _CommentInputBar(
          controller: _commentController,
          isSubmitting: _isSubmitting,
          onSubmit: _submitComment,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ────────────────────────────────────────────────────────────────────────────

class _PostHeader extends StatelessWidget {
  final Post post;
  final String timeAgo;
  const _PostHeader({required this.post, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              UserAvatar(
                photoUrl:
                    post.authorPhotoUrl.isNotEmpty ? post.authorPhotoUrl : null,
                radius: 20,
                isManagement: post.authorRole == 'management',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorRole == 'management'
                          ? 'Management'
                          : (post.authorName.isNotEmpty
                              ? post.authorName
                              : post.authorId),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      '${post.location ?? 'Unknown'} • $timeAgo',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: post.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(post.title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(post.description,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey[800], height: 1.5)),
          // Images
          if (post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: post.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrls[i],
                    width: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 280,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey[400]),
                    ),
                  ),
                ),
              ),
            ),
          ],
          // View counter
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.visibility_outlined,
                  size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('${post.views} views',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoteBar extends StatelessWidget {
  final Post post;
  final String? userVote;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  const _VoteBar({
    required this.post,
    required this.userVote,
    required this.onUpvote,
    required this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
    final score = post.upvotes - post.downvotes;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          // Upvote
          _VoteButton(
            icon: Icons.arrow_upward_rounded,
            active: userVote == 'up',
            activeColor: Colors.deepOrange,
            onTap: onUpvote,
          ),
          // Score
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              score >= 0 ? '+$score' : '$score',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: score > 0
                    ? Colors.deepOrange
                    : score < 0
                        ? Colors.indigo
                        : Colors.grey[700],
              ),
            ),
          ),
          // Downvote
          _VoteButton(
            icon: Icons.arrow_downward_rounded,
            active: userVote == 'down',
            activeColor: Colors.indigo,
            onTap: onDownvote,
          ),
          const SizedBox(width: 16),
          // Raw counts
          Text(
            '${post.upvotes}↑  ${post.downvotes}↓',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _VoteButton({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? activeColor : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Icon(icon,
            size: 20, color: active ? activeColor : Colors.grey[600]),
      ),
    );
  }
}

class _CommentsList extends StatelessWidget {
  final String postId;
  final String Function(DateTime) timeAgo;
  const _CommentsList({required this.postId, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Comment>>(
      stream: PostService().getCommentsStream(postId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final comments = snap.data ?? [];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comments (${comments.length})',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (comments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No comments yet. Be the first!',
                        style: TextStyle(color: Colors.grey[500])),
                  ),
                )
              else
                ...comments
                    .map((c) => _CommentTile(comment: c, timeAgo: timeAgo)),
            ],
          ),
        );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final String Function(DateTime) timeAgo;
  const _CommentTile({required this.comment, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            photoUrl: comment.authorPhotoUrl.isNotEmpty
                ? comment.authorPhotoUrl
                : null,
            radius: 16,
            isManagement: comment.authorRole == 'management',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorRole == 'management'
                          ? 'Management'
                          : (comment.authorName.isNotEmpty
                              ? comment.authorName
                              : comment.authorId),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black),
                    ),
                    if (comment.authorRole == 'management') ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('MOD',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(timeAgo(comment.createdAt),
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content,
                    style: TextStyle(fontSize: 13, color: Colors.grey[800])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  const _CommentInputBar({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Consumer<AuthProvider>(
            builder: (_, auth, __) => UserAvatar(
              photoUrl: auth.photoUrl,
              radius: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add a comment…',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:
                      const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          const SizedBox(width: 8),
          isSubmitting
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.send_rounded),
                  color: const Color(0xFF4A90E2),
                  tooltip: 'Post comment',
                ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'Resolved'
        ? const Color(0xFF4CAF50)
        : const Color(0xFF2196F3);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(status,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
