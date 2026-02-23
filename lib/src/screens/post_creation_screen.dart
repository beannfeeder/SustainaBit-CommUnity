import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../gemeni_service.dart';
import '../widgets/post_card.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';

class PostCreationScreen extends StatefulWidget {
  const PostCreationScreen({super.key});

  @override
  State<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _communityLocation;
  String? _selectedLocation;

  final String _googleApiKey = "AIzaSyANJht0xA4ES_dETC14bC3L9yJuYjiHkuE";

  final List<XFile> _uploadedFiles = [];

  bool _isEnhancing = false;
  bool _isCategorizing = false;

  List<PostTag> _generatedTags = [];

  @override
  void initState() {
    super.initState();
    _fetchDefaultLocation();
    _extractLocationFromUrl();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // =============================
  // LOCATION LOGIC
  // =============================

  void _extractLocationFromUrl() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? finalLocation;

      try {
        finalLocation =
            GoRouterState.of(context).uri.queryParameters['user_location'];
      } catch (_) {}

      if (finalLocation == null || finalLocation.isEmpty) {
        final fragment = Uri.base.fragment;
        if (fragment.contains('user_location=')) {
          final dummyUri = Uri.parse('http://dummy.com$fragment');
          finalLocation = dummyUri.queryParameters['user_location'];
        }
      }

      if (finalLocation != null && finalLocation.isNotEmpty) {
        setState(() {
          _communityLocation =
              Uri.decodeComponent(finalLocation!).replaceAll('+', ' ');
          _selectedLocation = _communityLocation;
        });
      }
    });
  }

  Future<void> _fetchDefaultLocation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data()!.containsKey('defaultLocation')) {
          final defaultLoc = doc.data()!['defaultLocation'];
          if (defaultLoc != null) {
            setState(() {
              _selectedLocation ??= defaultLoc.toString();
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Default location error: $e");
    }
  }

  // =============================
  // AI ENHANCE
  // =============================

  Future<void> _enhanceDescription() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isEnhancing = true);

    try {
      final enhanced = await GeminiService.generate("""
Enhance this community post description while:
- Keeping original meaning
- Making it clearer
- Keeping similar length
- Not adding fake info

Description:
${_descriptionController.text}
""");

      _descriptionController.text = enhanced.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description enhanced'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Enhance error: $e");
    }

    if (mounted) {
      setState(() => _isEnhancing = false);
    }
  }

  // =============================
  // AI CATEGORIZE
  // =============================

  /// TODO: Replace with actual database call to fetch available categories
  Future<List<Map<String, dynamic>>> _getAvailableCategories() async {
    return [
      {'name': 'Events', 'description': 'for announcements, gatherings, community events'},
      {'name': 'Damaged Infrastructure', 'description': 'for broken facilities, maintenance issues'},
      {'name': 'Pollution', 'description': 'for environmental contamination, waste issues'},
      {'name': 'Wildlife', 'description': 'for animal-related posts'},
      {'name': 'Community Action', 'description': 'for volunteer activities, group initiatives'},
      {'name': 'Sustainability Tips', 'description': 'for advice, eco-friendly practices'},
      {'name': 'Recycling', 'description': 'for waste management, recycling programs'},
      {'name': 'Green Spaces', 'description': 'for parks, gardens, nature areas'},
      {'name': 'Climate', 'description': 'for weather, climate change topics'},
      {'name': 'Transportation', 'description': 'for mobility, public transit issues'},
    ];
  }

  /// TODO: Replace with actual database call to save new category
  Future<void> _saveNewCategoryToDatabase(String categoryName, String colorHex) async {
    debugPrint('TODO: Save to database - Category: $categoryName, Color: $colorHex');
  }

  Future<List<PostTag>> _categorizePost(String title, String description) async {
    try {
      final availableCategories = await _getAvailableCategories();
      
      final categoryList = availableCategories
          .map((cat) => '- ${cat['name']} (${cat['description']})')
          .join('\n');
      
      final prompt = '''
You are an AI that categorizes community posts.

Post Title: $title
Post Description: $description

Analyze this post and assign 1-3 relevant categories from the following list, OR create new ones if none fit:
$categoryList

Return ONLY a JSON array of categories with colors in this exact format:
[{"label": "Category Name", "color": "#RRGGBB", "isNew": false}, ...]

IMPORTANT: Set "isNew": true ONLY if you created a category that's NOT in the list above.

Choose appropriate colors:
- Green (#4CAF50) for environmental/positive topics
- Orange (#FF9800) for warnings/issues
- Blue (#2196F3) for events/info
- Red (#F44336) for urgent/damaged items
- Purple (#9C27B0) for community activities
- Teal (#009688) for sustainability

Example output:
[{"label": "Damaged Infrastructure", "color": "#F44336", "isNew": false}, {"label": "Beach Cleanup", "color": "#2196F3", "isNew": true}]
''';

      final response = await GeminiService.generate(prompt);
      
      String jsonString = response.trim();
      jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final List<dynamic> categories = jsonDecode(jsonString);
      
      final List<PostTag> tags = [];
      for (var cat in categories) {
        final colorHex = cat['color'].toString().replaceAll('#', '');
        final isNew = cat['isNew'] ?? false;
        
        tags.add(PostTag(
          label: cat['label'],
          color: Color(int.parse('FF$colorHex', radix: 16)),
        ));
        
        if (isNew) {
          await _saveNewCategoryToDatabase(cat['label'], colorHex);
        }
      }
      
      return tags;
    } catch (e) {
      debugPrint('Error categorizing post: $e');
      return [
        const PostTag(
          label: 'Community',
          color: Color(0xFF4CAF50),
        ),
      ];
    }
  }

  // =============================
  // SHARE POST
  // =============================

  Future<void> _sharePost() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and description required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCategorizing = true;
    });

    try {
      // AI Categorization first
      final tags = await _categorizePost(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );

      _generatedTags = tags;

      // Upload images if any
      final postService = PostService();
      List<String> imageUrls = [];

      if (_uploadedFiles.isNotEmpty) {
        imageUrls = await postService.uploadImages(_uploadedFiles);
      }

      // Get user auth info
      final auth = context.read<AuthProvider>();
      if (auth.userId == null) {
        throw Exception("You must be logged in to post.");
      }

      // Create post object
      final post = Post(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        authorId: auth.userId!,
        authorName: auth.displayNameOrFallback,
        authorRole: auth.userRole,
        authorPhotoUrl: auth.photoUrl ?? '',
        location: _selectedLocation,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
      );

      // Save to Firebase
      await postService.createPost(post);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Post shared with categories: ${_generatedTags.map((t) => t.label).join(", ")}'),
            backgroundColor: Colors.green,
          ),
        );

        context.pop();
      }
    } catch (e) {
      debugPrint("Share error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCategorizing = false;
        });
      }
    }
  }

  // =============================
  // UI BUILD
  // =============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            const Text(
              'TITLE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Title goes here...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Description Field
            const Text(
              'DESCRIPTION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Describe your post...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: _isEnhancing ? null : _enhanceDescription,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isEnhancing
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey[600]!,
                                    ),
                                  ),
                                )
                              : Icon(Icons.auto_awesome,
                                  size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            _isEnhancing
                                ? 'ENHANCING...'
                                : 'AI ENHANCE DESCRIPTION',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Generated Tags Display
            if (_generatedTags.isNotEmpty) ...[
              const Text(
                'AI GENERATED CATEGORIES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _generatedTags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: tag.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),

            // Add Location Option
            _buildOptionRow(
              icon: Icons.location_on_outlined,
              title: _selectedLocation ?? 'Add location',
              onTap: () => _showLocationPicker(context),
            ),
            const SizedBox(height: 16),

            // Upload Option
            _buildOptionRow(
              icon: Icons.attach_file,
              title: 'Upload',
              onTap: () => _showUploadOptions(context),
            ),
            const SizedBox(height: 40),

            // Share Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCategorizing ? null : _sharePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: _isCategorizing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Categorizing...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Share',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // =============================
  // LOCATION & UPLOAD DIALOGS
  // =============================

  void _showLocationPicker(BuildContext context) async {
    final selectedStr = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _LocationSearchModal(
        initialLocation: _selectedLocation,
        apiKey: _googleApiKey,
      ),
    );

    if (selectedStr != null) {
      setState(() {
        _selectedLocation = selectedStr.isEmpty ? null : selectedStr;
      });
    }
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Upload Files',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await _picker.pickImage(
                      source: ImageSource.camera, imageQuality: 70);
                  if (photo != null) {
                    setState(() => _uploadedFiles.add(photo));
                  }
                }),
            ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final List<XFile> images =
                      await _picker.pickMultiImage(imageQuality: 70);
                  if (images.isNotEmpty) {
                    setState(() {
                      _uploadedFiles.addAll(images);
                    });
                  }
                }),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// LOCATION SEARCH MODAL WIDGET
// ============================================================================

class _LocationSearchModal extends StatefulWidget {
  final String? initialLocation;
  final String apiKey;

  const _LocationSearchModal({
    this.initialLocation,
    required this.apiKey,
  });

  @override
  State<_LocationSearchModal> createState() => _LocationSearchModalState();
}

class _LocationSearchModalState extends State<_LocationSearchModal> {
  late TextEditingController _modalController;
  List<dynamic> _modalPlaceList = [];

  @override
  void initState() {
    super.initState();
    _modalController =
        TextEditingController(text: widget.initialLocation ?? '');
  }

  @override
  void dispose() {
    _modalController.dispose();
    super.dispose();
  }

  void _searchPlacesInModal(String input) async {
    if (input.isEmpty) {
      setState(() {
        _modalPlaceList = [];
      });
      return;
    }

    String url = "https://places.googleapis.com/v1/places:autocomplete";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': widget.apiKey,
        },
        body: jsonEncode({"input": input, "includedRegionCodes": ["MY"]}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['suggestions'] != null) {
          setState(() {
            _modalPlaceList = result['suggestions'];
          });
        } else {
          setState(() {
            _modalPlaceList = [];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching modal suggestions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Where is this post about?',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            controller: _modalController,
            autofocus: true,
            onChanged: _searchPlacesInModal,
            decoration: InputDecoration(
              hintText: 'e.g. Jalan Jati Perkasa',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF4A90E2), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          if (_modalPlaceList.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _modalPlaceList.length,
                itemBuilder: (context, index) {
                  final prediction = _modalPlaceList[index]['placePrediction'];
                  final description = prediction['text']['text'];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined,
                        color: Colors.blue),
                    title: Text(description,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      Navigator.pop(context, description);
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context, "");
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(context, _modalController.text.trim());
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
