import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String location;
  final String timeAgo;
  final String? status;
  final Color? statusColor;
  final String title;
  final List<PostTag> tags;
  final String? imageUrl;
  final int likes;
  final String views;
  final String comments;
  final String? duplicatePostLabel;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
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
    required this.likes,
    required this.views,
    required this.comments,
    this.duplicatePostLabel,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: const Color(0xFFF5F5F0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
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
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$location • $timeAgo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor ?? const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Post Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags
                      .map((tag) => _PostTag(
                            label: tag.label,
                            color: tag.color,
                          ))
                      .toList(),
                ),
              ],
              if (imageUrl != null) ...[
                const SizedBox(height: 12),
                // Post Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    // TODO: Replace with actual image when available
                    // child: Image.network(
                    //   imageUrl!,
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Stats Row
              Row(
                children: [
                  _buildStat(
                    Icons.thumb_up_outlined,
                    likes.toString(),
                    Colors.blue,
                    onLike,
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    Icons.visibility_outlined,
                    views,
                    Colors.grey[600]!,
                    null,
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    Icons.comment_outlined,
                    comments,
                    Colors.grey[600]!,
                    onComment,
                  ),
                  const Spacer(),
                  if (duplicatePostLabel != null)
                    Text(
                      duplicatePostLabel!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    IconData icon,
    String label,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
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
      ),
    );
  }
}

class _PostTag extends StatelessWidget {
  final String label;
  final Color color;

  const _PostTag({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PostTag {
  final String label;
  final Color color;

  const PostTag({
    required this.label,
    required this.color,
  });
}
