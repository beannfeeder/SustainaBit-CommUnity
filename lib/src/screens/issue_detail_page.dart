import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class IssueDetailPage extends StatelessWidget {
  final String issueId;
  const IssueDetailPage({super.key, required this.issueId});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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

  bool _isHighPriority(Map<String, dynamic>? priority) {
    final level = priority?['level'] as String? ?? 'none';
    return level == 'critical' || level == 'high';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        title:
            const Text('Issue Detail', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Post?>(
        future: PostService().getPostById(issueId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Issue not found.'));
          }
          final issue = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainInfoCard(issue),
                const SizedBox(height: 24),
                const Text(
                  'Done? Upload Proof of Work!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildUploadPlaceholder(),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[50],
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTimeline(issue),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainInfoCard(Post issue) {
    final urgency = _urgencyLabel(issue.priority);
    final highPriority = _isHighPriority(issue.priority);
    final badgeColor = highPriority ? AppTheme.errorColor : AppTheme.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            issue.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: badgeColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              urgency,
              style: TextStyle(color: badgeColor, fontSize: 10),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            issue.description,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          if (issue.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppTheme.textMeta),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    issue.location!,
                    style: const TextStyle(
                        color: AppTheme.textMeta, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
          if (issue.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: issue.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    issue.imageUrls[i],
                    width: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 220,
                      color: Colors.grey[200],
                      child:
                          Icon(Icons.broken_image, color: Colors.grey[400]),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Reported ${_timeAgo(issue.createdAt)}',
            style: const TextStyle(color: AppTheme.textMeta, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, color: Colors.grey),
          Text('Select Photos', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTimeline(Post issue) {
    final entries = <_TimelineEntry>[
      _TimelineEntry(
        color: Colors.greenAccent,
        title:
            'Issue raised by ${issue.authorName.isNotEmpty ? issue.authorName : "User"}',
        time: _timeAgo(issue.createdAt),
      ),
    ];

    if (issue.status.toLowerCase() == 'in progress') {
      entries.insert(
        0,
        _TimelineEntry(
          color: Colors.amber,
          title: 'Issue assigned and being worked on',
          time: '',
        ),
      );
    } else if (issue.status.toLowerCase() == 'resolved' ||
        issue.status.toLowerCase() == 'completed') {
      entries.insert(
        0,
        _TimelineEntry(
          color: Colors.green,
          title: 'Issue resolved',
          time: '',
        ),
      );
      if (entries.length > 1) {
        entries.insert(
          1,
          _TimelineEntry(
            color: Colors.amber,
            title: 'Issue assigned and worked on',
            time: '',
          ),
        );
      }
    }

    return Column(
      children: List.generate(entries.length, (i) {
        return _buildTimelineItem(
          entries[i].color,
          entries[i].title,
          entries[i].time,
          isLast: i == entries.length - 1,
        );
      }),
    );
  }

  Widget _buildTimelineItem(Color color, String title, String time,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 8,
              backgroundColor: color,
              child: CircleAvatar(
                radius: 6,
                backgroundColor: Colors.white,
                child: CircleAvatar(radius: 4, backgroundColor: color),
              ),
            ),
            if (!isLast) Container(width: 2, height: 30, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (time.isNotEmpty)
                  Text(time,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textMeta)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineEntry {
  final Color color;
  final String title;
  final String time;
  const _TimelineEntry(
      {required this.color, required this.title, required this.time});
}
