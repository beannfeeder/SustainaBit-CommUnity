import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../gemeni_service.dart';
import '../widgets/category_tags.dart';
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

  List<String> _categoryIds = []; // Store category IDs
  Map<String, String> _categoryNames = {}; // categoryId -> categoryName for display

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
    final currentDescription = _descriptionController.text.trim();
    
    if (currentDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isEnhancing = true;
    });

    try {
      final prompt = '''
You are helping to enhance a community post description.

Original description: $currentDescription

Please enhance this description by:
- Making it more clear
- Keeping the original meaning and intent
- Maintaining a friendly, community-focused tone
- Keeping it concise (similar length to the original)
- Not adding fake information

Return only the enhanced description text, nothing else.''';

      final enhancedText = await GeminiService.generate(prompt);

      if (mounted) {
        _descriptionController.text = enhancedText.trim();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Description enhanced successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enhance description: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEnhancing = false;
        });
      }
    }
  }

  // =============================
  // AI CATEGORIZE
  // =============================

  // =============================
  // FIRESTORE CATEGORY INTEGRATION
  // =============================

  Future<List<Map<String, dynamic>>> _getAvailableCategories() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'name': data['name'] ?? '',
        'description': data['description'] ?? '',
      };
    }).toList();
  } catch (e) {
    debugPrint('Error fetching categories: $e');
    return [];
  }
}

Future<void> _saveNewCategoryToDatabase(
  String categoryName,
  String colorHex,
  String description,
) async {
  try {
    // 🔥 Sanitize document ID
    final docId = categoryName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');

    final docRef =
        FirebaseFirestore.instance.collection('categories').doc(docId);

    final existingDoc = await docRef.get();

    // Prevent duplicate creation
    if (!existingDoc.exists) {
      await docRef.set({
        'name': categoryName,
        'description': description,
        'colour': '#$colorHex',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('New category saved: $categoryName');
    } else {
      debugPrint('Category already exists: $categoryName');
    }
  } catch (e) {
    debugPrint('Error saving category: $e');
  }
}

Future<Map<String, dynamic>> _categorizePost(
    String title, String description) async {
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

Return ONLY a JSON array in this exact format:
[
  {
    "label": "Category Name",
    "description": "Short description explaining what this category represents",
    "color": "#RRGGBB",
    "isNew": false
  }
]

IMPORTANT:
- Set "isNew": true ONLY if category is NOT in provided list.
- Keep description short (1 sentence).
- Do NOT return anything except JSON.

CATEGORY CREATION RULES (when creating new categories):
- Create BROAD, GENERAL categories that can fit many scenarios.
- AVOID overly specific or narrow categories.
- Examples:
  * For dating/singles events → use "Social Event" (not "Dating" or "Singles")
  * For specific sports → use "Sports & Recreation" (not "Basketball" or "Tennis")
  * For specific issues → use broader terms (e.g., "Infrastructure" instead of "Broken Sidewalk")
- Think about reusability: Will this category apply to many other posts?
- Prefer umbrella terms over specific niches.
''';

    final response = await GeminiService.generate(prompt);

    String jsonString = response.trim();

    // Remove markdown formatting if present
    jsonString = jsonString
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final List<dynamic> categories = jsonDecode(jsonString);

    final List<String> categoryIds = [];
    final Map<String, String> categoryNames = {};

    for (var cat in categories) {
      final label = cat['label'] ?? 'Unknown';
      final descriptionText = cat['description'] ?? '';
      final colorHex =
          (cat['color'] ?? '#4CAF50').toString().replaceAll('#', '');
      final isNew = cat['isNew'] ?? false;

      // Generate category ID
      final categoryId = label
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');

      categoryIds.add(categoryId);
      categoryNames[categoryId] = label;

      // Save new categories
      if (isNew) {
        await _saveNewCategoryToDatabase(
          label,
          colorHex,
          descriptionText,
        );
      }
    }

    return {
      'categoryIds': categoryIds,
      'categoryNames': categoryNames,
    };
  } catch (e) {
    debugPrint('Error categorizing post: $e');

    return {
      'categoryIds': ['community'],
      'categoryNames': {'community': 'Community'},
    };
  }
}

  // =============================
  // AI SENTIMENT ANALYSIS
  // =============================

  Future<Map<String, dynamic>> _analyzeSentiment(
    String title,
    String description,
  ) async {
    try {
      final prompt = '''
You are performing sentiment analysis on a community post.

Return ONLY valid JSON in this exact format:

{
  "label": "positive | neutral | negative",
  "score": number between -1.0 and 1.0,
  "confidence": number between 0.0 and 1.0,
  "severity": "low | medium | high"
}

Rules:
- Do NOT include explanations.
- Do NOT include markdown formatting.
- Do NOT include extra text.
- Output JSON only.

Post Title: $title
Post Description: $description
''';

      final response = await GeminiService.generate(prompt);

      String jsonString = response.trim();

      // Remove markdown formatting if present
      jsonString = jsonString
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> sentiment = jsonDecode(jsonString);

      // Validate required fields
      if (!sentiment.containsKey('label') ||
          !sentiment.containsKey('score') ||
          !sentiment.containsKey('confidence') ||
          !sentiment.containsKey('severity')) {
        throw Exception('Invalid sentiment response structure');
      }

      return sentiment;
    } catch (e) {
      debugPrint('Error analyzing sentiment: $e');

      // Fallback to neutral sentiment
      return {
        'label': 'neutral',
        'score': 0.0,
        'confidence': 0.0,
        'severity': 'low',
      };
    }
  }

  // =============================
  // AI PRIORITY ANALYSIS
  // =============================

  Future<Map<String, dynamic>> _analyzePriority(
    String title,
    String description,
    List<String> categoryIds,
    String? location,
  ) async {
    try {
      final categoryList = categoryIds.join(', ');

      final prompt = '''
You are an AI system responsible for classifying the emergency priority of community reports.

Your job is to determine how urgently management should respond.

Return ONLY valid JSON in this format:

{
  "level": "none | low | medium | high | critical",
  "score": integer between 0 and 100,
  "reason": "Short explanation (max 1 sentence)",
  "confidence": number between 0.0 and 1.0
}

Guidelines:
- "critical" = Immediate danger to life, major property damage, safety hazards.
- "high" = Serious issue that requires urgent attention within 24 hours.
- "medium" = Important but not urgent.
- "low" = Minor inconvenience.
- "none" = Informational or positive post.

Do NOT include explanations outside JSON.
Do NOT include markdown formatting.

Post Title: $title
Post Description: $description
Post Category: $categoryList
Location: ${location ?? 'Not specified'}
''';

      final response = await GeminiService.generate(prompt);

      String jsonString = response.trim();

      // Remove markdown formatting if present
      jsonString = jsonString
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> priority = jsonDecode(jsonString);

      // Validate required fields
      if (!priority.containsKey('level') ||
          !priority.containsKey('score') ||
          !priority.containsKey('reason') ||
          !priority.containsKey('confidence')) {
        throw Exception('Invalid priority response structure');
      }

      return priority;
    } catch (e) {
      debugPrint('Error analyzing priority: $e');

      // Fallback to none priority
      return {
        'level': 'none',
        'score': 0,
        'reason': 'Unable to determine priority',
        'confidence': 0.0,
      };
    }
  }

  // =============================
  // AI TYPE CLASSIFICATION
  // =============================

  /// Returns 'issue' if the content describes a problem that needs management
  /// action, or 'post' for general community content.
  Future<String> _classifyPostType(String title, String description) async {
    try {
      final prompt = '''
You are classifying a community app submission.

Post Title: $title
Post Description: $description

Decide if this is:
- "issue": A problem report, complaint, damage, hazard, infrastructure failure, vandalism, broken facility, or anything requiring management action or repair.
- "post": General community content — announcements, sharing, events, discussions, tips, positive news, etc.

Return ONLY one word: "issue" or "post". No explanation, no punctuation.
''';

      final response = await GeminiService.generate(prompt);
      final result = response.trim().toLowerCase();
      return result == 'issue' ? 'issue' : 'post';
    } catch (e) {
      debugPrint('Error classifying post type: $e');
      return 'post'; // safe fallback
    }
  }

  // =============================
  // SHARE POST
  // =============================

  Future<void> _sharePost() async {
    debugPrint("SHARE BUTTON PRESSED");
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

    // Capture context-dependent objects before any await
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isCategorizing = true;
    });

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      // Run categorisation and type classification in parallel (both independent)
      final firstPass = await Future.wait([
        _categorizePost(title, description),
        _classifyPostType(title, description),
      ]);

      final categorizationResult = firstPass[0] as Map<String, dynamic>;
      final postType = firstPass[1] as String;

      final categoryIds = categorizationResult['categoryIds'] as List<String>;
      final categoryNames =
          categorizationResult['categoryNames'] as Map<String, String>;

      setState(() {
        _categoryIds = categoryIds;
        _categoryNames = categoryNames;
      });

      // AI Sentiment Analysis
      final sentimentResult = await _analyzeSentiment(title, description);

      // AI Priority Analysis
      final priorityResult =
          await _analyzePriority(title, description, categoryIds, _selectedLocation);

      // Upload images if any
      final postService = PostService();
      List<String> imageUrls = [];

      if (_uploadedFiles.isNotEmpty) {
        imageUrls = await postService.uploadImages(_uploadedFiles);
      }

      if (auth.userId == null) {
        throw Exception("You must be logged in to post.");
      }

      // Create post object
      final post = Post(
        title: title,
        description: description,
        authorId: auth.userId!,
        authorName: auth.displayNameOrFallback,
        authorRole: auth.userRole,
        authorPhotoUrl: auth.photoUrl ?? '',
        location: _selectedLocation,
        imageUrls: imageUrls,
        categoryIds: _categoryIds,
        sentiment: sentimentResult,
        priority: priorityResult,
        createdAt: DateTime.now(),
        type: postType,
      );

      // Save to Firebase
      await postService.createPost(post);

      final label = postType == 'issue' ? 'Issue' : 'Post';
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              '$label shared with categories: ${_categoryNames.values.join(", ")}'),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) context.pop();
    } catch (e) {
      debugPrint("Share error: $e");
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to post: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
            if (_categoryIds.isNotEmpty) ...[
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
              CategoryTags(categoryIds: _categoryIds),
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
