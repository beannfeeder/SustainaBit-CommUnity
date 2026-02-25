import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';
import '../widgets/user_avatar.dart';

class IssueDetailPage extends StatefulWidget {
  final String issueId;
  const IssueDetailPage({super.key, required this.issueId});

  @override
  State<IssueDetailPage> createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends State<IssueDetailPage> {
  final PostService _postService = PostService();
  final ImagePicker _picker = ImagePicker();

  bool _isUpdatingStatus = false;
  bool _isSubmittingProof = false;
  final List<XFile> _proofImages = [];
  final List<Uint8List> _proofImageBytes = [];

  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;

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

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Upload Proof',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final photo = await _picker.pickImage(
                    source: ImageSource.camera, imageQuality: 70);
                if (photo != null) {
                  final bytes = await photo.readAsBytes();
                  setState(() {
                    _proofImages.add(photo);
                    _proofImageBytes.add(bytes);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final images = await _picker.pickMultiImage(imageQuality: 70);
                if (images.isNotEmpty) {
                  final bytesList = await Future.wait(
                      images.map((f) => f.readAsBytes()));
                  setState(() {
                    _proofImages.addAll(images);
                    _proofImageBytes.addAll(bytesList);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitProof() async {
    if (_proofImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one photo.')),
      );
      return;
    }
    setState(() => _isSubmittingProof = true);
    try {
      await _postService.submitProofOfWork(widget.issueId, _proofImages);
      if (mounted) {
        setState(() {
          _proofImages.clear();
          _proofImageBytes.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proof submitted — issue marked as Resolved.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingProof = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final auth = context.read<AuthProvider>();
    if (auth.userId == null) return;

    setState(() => _isSubmittingComment = true);
    try {
      await _postService.addComment(
        widget.issueId,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingComment = false);
    }
  }

  Future<void> _markAsInProgress() async {
    setState(() => _isUpdatingStatus = true);
    try {
      await _postService.updateIssueStatus(widget.issueId, 'In Progress');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<Post?>(
              stream: _postService.getPostStream(widget.issueId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return const Center(child: Text('Issue not found.'));
                }
                final issue = snapshot.data!;
                final status = issue.status.toLowerCase();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainInfoCard(issue),
                      const SizedBox(height: 24),

                      // ── Status-gated action section ──────────────────────
                      if (status == 'open' || status == 'pending') ...[
                        _buildMarkInProgressSection(),
                        const SizedBox(height: 24),
                      ] else if (status == 'in progress') ...[
                        _buildProofSection(),
                        const SizedBox(height: 24),
                      ] else if (status == 'resolved' ||
                          status == 'completed') ...[
                        if (issue.proofImageUrls.isNotEmpty) ...[
                          _buildProofDisplay(issue.proofImageUrls),
                          const SizedBox(height: 24),
                        ],
                      ],

                      _buildTimeline(issue),
                      const SizedBox(height: 24),
                      _buildCommentsSection(),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildCommentInputBar(),
        ],
      ),
    );
  }

  // ── Proof of Work display (resolved) ──────────────────────────────────────

  Widget _buildProofDisplay(List<String> proofUrls) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Proof of Work Submitted',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'This issue has been resolved. Photos submitted as evidence are shown below.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: proofUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  proofUrls[i],
                  width: 220,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 220,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mark as In Progress ────────────────────────────────────────────────────

  Widget _buildMarkInProgressSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined,
                  color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Ready to work on this issue?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Click the button below to mark this issue as in progress. You will then be able to upload proof of work.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUpdatingStatus ? null : _markAsInProgress,
              icon: _isUpdatingStatus
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(
                  _isUpdatingStatus ? 'Updating…' : 'Mark as In Progress'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Proof of Work ──────────────────────────────────────────────────────────

  Widget _buildProofSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.task_alt_outlined,
                  color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Upload Proof of Work',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Great work! Attach photos showing the completed fix. Once submitted, this issue will be marked as Resolved.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          _buildUploadArea(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmittingProof ? null : _submitProof,
              icon: _isSubmittingProof
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline),
              label:
                  Text(_isSubmittingProof ? 'Submitting…' : 'Submit Proof'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    if (_proofImages.isEmpty) {
      return GestureDetector(
        onTap: _showImageSourceSheet,
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, color: Colors.grey, size: 36),
              SizedBox(height: 8),
              Text('Tap to Select Photos',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _proofImages.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == _proofImages.length) {
                return GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: Colors.grey),
                        SizedBox(height: 4),
                        Text('Add More',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _proofImageBytes[index],
                      width: 130,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _proofImages.removeAt(index);
                        _proofImageBytes.removeAt(index);
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }


  // ── Comments ───────────────────────────────────────────────────────────────

  Widget _buildCommentsSection() {
    return StreamBuilder<List<Comment>>(
      stream: _postService.getCommentsStream(widget.issueId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final comments = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline,
                    size: 18, color: AppTheme.textPrimary),
                const SizedBox(width: 8),
                Text(
                  'Comments (${comments.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No comments yet. Be the first!',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ...comments.map((c) => _buildCommentTile(c)),
          ],
        );
      },
    );
  }

  Widget _buildCommentTile(Comment comment) {
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
                          color: AppTheme.textPrimary),
                    ),
                    if (comment.authorRole == 'management') ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
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
                    Text(
                      _timeAgo(comment.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMeta),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).viewInsets.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
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
              controller: _commentController,
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
                  borderSide: const BorderSide(
                      color: AppTheme.primaryBlue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isSubmittingComment
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  onPressed: _submitComment,
                  icon: const Icon(Icons.send_rounded),
                  color: AppTheme.primaryBlue,
                  tooltip: 'Post comment',
                ),
        ],
      ),
    );
  }

  // ── Main info card ─────────────────────────────────────────────────────────

  Widget _buildMainInfoCard(Post issue) {
    final urgency = _urgencyLabel(issue.priority);
    final highPriority = _isHighPriority(issue.priority);
    final badgeColor =
        highPriority ? AppTheme.errorColor : AppTheme.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
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
                    fontSize: 20,
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
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      child: Icon(Icons.broken_image,
                          color: Colors.grey[400]),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Reported ${_timeAgo(issue.createdAt)}',
            style:
                const TextStyle(color: AppTheme.textMeta, fontSize: 12),
          ),
        ],
      ),
    );
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
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(
        status,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Timeline ───────────────────────────────────────────────────────────────

  Widget _buildTimeline(Post issue) {
    final entries = <_TimelineEntry>[
      _TimelineEntry(
        color: Colors.greenAccent,
        title:
            'Issue raised by ${issue.authorName.isNotEmpty ? issue.authorName : "User"}',
        time: _timeAgo(issue.createdAt),
      ),
    ];

    final status = issue.status.toLowerCase();

    if (status == 'in progress') {
      entries.insert(
        0,
        const _TimelineEntry(
          color: Colors.amber,
          title: 'Issue assigned and being worked on',
          time: '',
        ),
      );
    } else if (status == 'resolved' || status == 'completed') {
      entries.insert(
        0,
        const _TimelineEntry(
          color: Colors.green,
          title: 'Issue resolved',
          time: '',
        ),
      );
      entries.insert(
        1,
        const _TimelineEntry(
          color: Colors.amber,
          title: 'Issue assigned and worked on',
          time: '',
        ),
      );
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
            if (!isLast)
              Container(width: 2, height: 30, color: Colors.grey[300]),
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
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
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
