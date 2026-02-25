import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';

class IssuePage extends StatefulWidget {
  const IssuePage({super.key});

  @override
  State<IssuePage> createState() => _IssuePageState();
}

class _IssuePageState extends State<IssuePage> {
  int _selectedTabIndex = 0;
  final PostService _postService = PostService();

  static const _tabs = ['Pending', 'In-Progress', 'Resolved'];

  // Statuses stored in Firestore that each tab maps to (case-insensitive match)
  static const _statusMap = {
    0: ['open', 'pending'],
    1: ['in progress'],
    2: ['resolved', 'completed'],
  };

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

  Widget _buildStatusBadge(String status) {
    final Color color;
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'completed':
        color = const Color(0xFF4CAF50);
        break;
      case 'in progress':
        color = Colors.amber[700]!;
        break;
      default:
        color = AppTheme.primaryBlue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _urgencyColor(Map<String, dynamic>? priority) {
    switch (priority?['level'] as String? ?? 'none') {
      case 'critical':
        return AppTheme.errorColor;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber[700]!;
      default:
        return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    // userId available if we ever need per-user filtering
    context.watch<AuthProvider>().userId;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'All Issues',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

          // Status tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final selected = _selectedTabIndex == i;
                return Padding(
                  padding: EdgeInsets.only(right: i < _tabs.length - 1 ? 12 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? Colors.blue[50] : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          color: selected
                              ? AppTheme.primaryBlue
                              : AppTheme.textMeta,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Issue list
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: _postService.getPostsStream(type: 'issue'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading issues: ${snapshot.error}'));
                }

                final allIssues = snapshot.data ?? [];
                final validStatuses = _statusMap[_selectedTabIndex] ?? [];
                final filtered = allIssues
                    .where((issue) => validStatuses
                        .contains(issue.status.toLowerCase()))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 64, color: AppTheme.textMeta),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_tabs[_selectedTabIndex].toLowerCase()} issues.',
                            style: const TextStyle(
                                color: AppTheme.textMeta, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final issue = filtered[index];
                    final issueId = issue.id ?? '';
                    return GestureDetector(
                      onTap: () => context.push('/issue-detail/$issueId'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    issue.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStatusBadge(issue.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              issue.description,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  '${_urgencyLabel(issue.priority)} · ${_timeAgo(issue.createdAt)}',
                                  style: TextStyle(
                                    color: _urgencyColor(issue.priority),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (issue.location != null) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.location_on_outlined,
                                      size: 12, color: AppTheme.textMeta),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      issue.location!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMeta),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
