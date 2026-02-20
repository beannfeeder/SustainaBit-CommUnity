import 'package:flutter/material.dart';

/// A Reddit-inspired post card that shows a vote bar, image, and stats.
class PostCard extends StatelessWidget {
  final String username;
  final String location;
  final String timeAgo;
  final String? status;
  final Color? statusColor;
  final String title;
  final List<PostTag> tags;
  final String? imageUrl;

  // ── Vote / stats ──────────────────────────────────────────────────────────
  final int upvotes;
  final int downvotes;
  final int viewCount;
  final int commentCount;
  final String? userVote; // 'up', 'down', or null

  final String? duplicatePostLabel;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onComment;

  const PostCard({
    super.key,
    required this.username,
    required this.location,
    required this.timeAgo,
    this.status,
    this.statusColor,
    required this.title,
    this.tags = const [],
    this.imageUrl,
    this.upvotes = 0,
    this.downvotes = 0,
    this.viewCount = 0,
    this.commentCount = 0,
    this.userVote,
    this.duplicatePostLabel,
    this.onTap,
    this.onUpvote,
    this.onDownvote,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final score = upvotes - downvotes;
    final scoreColor = score > 0
        ? const Color(0xFFFF6314) // Reddit orange
        : score < 0
            ? Colors.indigo
            : Colors.grey[600]!;

    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: username == 'Management'
                        ? const Color(0xFF4A90E2)
                        : Colors.grey[300],
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                            if (username == 'Management') ...[
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
                          ],
                        ),
                        Text('$location • $timeAgo',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  if (status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor ?? const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(status!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),

            // ── Title ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ),

            // ── Tags ────────────────────────────────────────────────────────
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: tag.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(tag.label,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ),

            // ── Image ───────────────────────────────────────────────────────
            if (imageUrl != null && imageUrl != 'placeholder') ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.zero),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: Image.network(
                    imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.grey[100],
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (context, _, __) => Container(
                      height: 180,
                      color: Colors.grey[100],
                      child: Center(
                          child: Icon(Icons.broken_image_outlined,
                              size: 48, color: Colors.grey[400])),
                    ),
                  ),
                ),
              ),
            ],

            // ── Reddit Vote Bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 10),
              child: Row(
                children: [
                  // Upvote button
                  _VoteButton(
                    icon: Icons.arrow_upward_rounded,
                    active: userVote == 'up',
                    activeColor: const Color(0xFFFF6314),
                    onTap: onUpvote,
                  ),
                  // Score
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      score >= 0 ? '+$score' : '$score',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: scoreColor),
                    ),
                  ),
                  // Downvote button
                  _VoteButton(
                    icon: Icons.arrow_downward_rounded,
                    active: userVote == 'down',
                    activeColor: Colors.indigo,
                    onTap: onDownvote,
                  ),

                  const SizedBox(width: 12),

                  // Comment count
                  InkWell(
                    onTap: onTap, // tap comment chip = open post
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('$commentCount',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // View count
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined,
                          size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text('$viewCount',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),

                  if (duplicatePostLabel != null) ...[
                    const Spacer(),
                    Text(duplicatePostLabel!,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            decoration: TextDecoration.underline)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback? onTap;
  const _VoteButton(
      {required this.icon,
      required this.active,
      required this.activeColor,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? activeColor : Colors.grey[300]!, width: 1.5),
        ),
        child: Icon(icon,
            size: 18, color: active ? activeColor : Colors.grey[500]),
      ),
    );
  }
}

class _PostTag extends StatelessWidget {
  final String label;
  final Color color;
  const _PostTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class PostTag {
  final String label;
  final Color color;
  const PostTag({required this.label, required this.color});
}
