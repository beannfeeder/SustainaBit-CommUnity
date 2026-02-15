import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../gemeni_service.dart';
import '../widgets/post_card.dart';

class PostCreationScreen extends StatefulWidget {
  const PostCreationScreen({super.key});

  @override
  State<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // 负责记住你的地点
  String? _communityLocation;
  String? _selectedLocation;
  
  final List<String> _uploadedFiles = [];
  bool _isEnhancing = false;
  bool _isCategorizing = false;
  List<PostTag> _generatedTags = [];

  @override
  void initState() {
    super.initState();
    
    // 页面加载后强行解析浏览器真实的 URL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? finalLocation;
      
      try {
        finalLocation = GoRouterState.of(context).uri.queryParameters['user_location'];
      } catch (e) {
        debugPrint("GoRouter 解析 URL 失败...");
      }

      // 如果拿不到，暴力读取浏览器的 /#/ 网址
      if (finalLocation == null || finalLocation.isEmpty) {
        final fragment = Uri.base.fragment; 
        if (fragment.contains('user_location=')) {
          final dummyUri = Uri.parse('http://dummy.com$fragment');
          finalLocation = dummyUri.queryParameters['user_location'];
        }
      }

      // 只要拿到数据，就塞进页面里
      if (finalLocation != null && finalLocation.isNotEmpty) {
        setState(() {
          // 注意这里的 finalLocation! (加了感叹号) 解决了报错
          _communityLocation = Uri.decodeComponent(finalLocation ?? '').replaceAll('+', ' ');
          _selectedLocation = _communityLocation;; 
        });
        debugPrint("成功提取地点: $_communityLocation");
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

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
                              : Icon(
                                  Icons.auto_awesome,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                          const SizedBox(width: 6),
                          Text(
                            _isEnhancing ? 'ENHANCING...' : 'AI ENHANCE DESCRIPTION',
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
                  onTap: () {
                    _showLocationPicker(context);
                  },
                ),
            const SizedBox(height: 16),

            // Upload Option
            _buildOptionRow(
              icon: Icons.attach_file,
              title: 'Upload',
              onTap: () {
                _showUploadOptions(context);
              },
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
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87))),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

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
- Making it more clear and engaging
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

  /// TODO: Replace with actual database call to fetch available categories
  /// Example: await CategoryService.getAvailableCategories()
  Future<List<Map<String, dynamic>>> _getAvailableCategories() async {
    // Simulating database fetch - replace this entire method with your database call
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
  /// Example: await CategoryService.addCategory(categoryName, color)
  Future<void> _saveNewCategoryToDatabase(String categoryName, String colorHex) async {
    // Simulating database save - replace with your actual database call
    debugPrint('TODO: Save to database - Category: $categoryName, Color: $colorHex');
    // Example implementation:
    // await CategoryService.addCategory(categoryName, colorHex);
  }

  Future<List<PostTag>> _categorizePost(String title, String description) async {
    try {
      // Fetch available categories from database (or use hardcoded list for now)
      final availableCategories = await _getAvailableCategories();
      
      // Build the category list dynamically for the AI prompt
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
      
      // Extract JSON from the response
      String jsonString = response.trim();
      // Remove markdown code blocks if present
      jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final List<dynamic> categories = jsonDecode(jsonString);
      
      // Process categories and save new ones to database
      final List<PostTag> tags = [];
      for (var cat in categories) {
        final colorHex = cat['color'].toString().replaceAll('#', '');
        final isNew = cat['isNew'] ?? false;
        
        tags.add(PostTag(
          label: cat['label'],
          color: Color(int.parse('FF$colorHex', radix: 16)),
        ));
        
        // Save new category to database
        if (isNew) {
          await _saveNewCategoryToDatabase(cat['label'], colorHex);
        }
      }
      
      return tags;
    } catch (e) {
      debugPrint('Error categorizing post: $e');
      // Return default category on error
      return [
        const PostTag(
          label: 'Community',
          color: Color(0xFF4CAF50),
        ),
      ];
    }
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_communityLocation != null)
              Text(
                'Your post will be visible to members in $_communityLocation',
                style: TextStyle(color: Colors.blue[700], fontSize: 13),
              ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.home_work_outlined),
              title: Text('My Community (${_communityLocation ?? "Not Set"})'),
              onTap: () {
                setState(() => _selectedLocation = _communityLocation);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Change Location'),
              onTap: () {
                Navigator.pop(context); 
                context.push('/welcome-registration'); 
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Upload Files', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take Photo'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose from Gallery'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.attach_file), title: const Text('Attach File'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title for your post'), backgroundColor: Colors.red));
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a description for your post'), backgroundColor: Colors.red));
      return;
    }

    // AI Categorization
    setState(() {
      _isCategorizing = true;
    });

    try {
      final tags = await _categorizePost(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _generatedTags = tags;
          _isCategorizing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCategorizing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categorization failed: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }



    // Use values to suppress unused warning
    debugPrint('Location: $_selectedLocation');
    debugPrint('Files: $_uploadedFiles');
    debugPrint('Generated Tags: ${_generatedTags.map((t) => t.label).join(", ")}');

    // TODO: Implement actual post sharing logic with tags
    // The _generatedTags should be sent to your backend/database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Post shared with categories: ${_generatedTags.map((t) => t.label).join(", ")}',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate back to home after successful post
    context.pop();
  }
}