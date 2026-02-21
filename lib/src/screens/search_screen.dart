import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/post_card.dart';
import '../config/api_key.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  final PostService _postService = PostService();
  final Map<String, String?> _userVotes = {};

  List<Post> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

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
  void initState() {
    super.initState();
    // Auto-focus search field when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = await _postService.searchPostsWithAI(query, geminiApiKey);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });

        // Preload votes if user is logged in
        final userId = context.read<AuthProvider>().userId;
        if (userId != null) {
          for (final post in results) {
            if (post.id != null) _loadVoteFor(post.id!, userId);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "AI Search failed: ${e.toString().replaceAll('Exception: ', '')}"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().userId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search for issues, announcements...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                setState(() {});

                if (value.isNotEmpty) {
                  _debounce = Timer(const Duration(milliseconds: 1000), () {
                    _performSearch(value);
                  });
                } else {
                  setState(() {
                    _searchResults = [];
                    _hasSearched = false;
                  });
                }
              },
              onSubmitted: _performSearch,
            ),
          ),

          // Search Results
          Expanded(
            child: _isSearching
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome,
                                color: Colors.amber.shade600, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "AI Semantic Search is thinking...",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                : _hasSearched && _searchResults.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try different keywords or check your spelling',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Start typing to search',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Search for issues, announcements, and more',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _searchResults.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final post = _searchResults[index];
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
                                tags: const [],
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
                          ),
          ),
        ],
      ),
    );
  }
}
