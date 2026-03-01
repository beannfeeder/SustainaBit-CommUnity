import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../services/post_service.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';

class MgmtPostCreationScreen extends StatefulWidget {
  const MgmtPostCreationScreen({super.key});

  @override
  State<MgmtPostCreationScreen> createState() => _MgmtPostCreationScreenState();
}

class _MgmtPostCreationScreenState extends State<MgmtPostCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Location selected for this post
  String? _selectedLocation;

  // 你的 Google API Key
  final String _googleApiKey = "AIzaSyANJht0xA4ES_dETC14bC3L9yJuYjiHkuE";

  final List<XFile> _uploadedFiles = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchDefaultLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? fromUrl;
      try {
        fromUrl =
            GoRouterState.of(context).uri.queryParameters['user_location'];
      } catch (_) {}
      if (fromUrl == null || fromUrl.isEmpty) {
        try {
          final fragment = Uri.base.fragment;
          if (fragment.contains('user_location=')) {
            final uri = Uri.parse('http://x$fragment');
            fromUrl = uri.queryParameters['user_location'];
          }
        } catch (_) {}
      }
      if (fromUrl != null && fromUrl.isNotEmpty && mounted) {
        setState(() {
          _selectedLocation ??=
              Uri.decodeComponent(fromUrl!).replaceAll('+', ' ');
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
          if (defaultLoc != null && defaultLoc.toString().isNotEmpty) {
            if (mounted) {
              setState(() {
                _selectedLocation ??= defaultLoc.toString();
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("获取默认地址失败: $e");
    }
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
          'New Announcement',
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      hintText: 'Describe your announcement...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Colors.grey, width: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        const Text(
                          'AI ENHANCE DESCRIPTION',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

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
                onPressed: _isLoading ? null : _sharePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Share',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
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
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black87))),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // 🌟 核心修改点：调用我们独立出去的弹窗 Widget
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

    // 当弹窗关闭并返回值时，更新主页面的地址
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

  Future<void> _sharePost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a title for your post'),
          backgroundColor: Colors.red));
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a description for your post'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      if (auth.userId == null) {
        throw Exception("You must be logged in to post.");
      }

      final postService = PostService();

      List<String> imageUrls = [];
      if (_uploadedFiles.isNotEmpty) {
        imageUrls = await postService.uploadImages(_uploadedFiles);
      }

      final post = Post(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        authorId: auth.userId!,
        authorName: auth.displayNameOrFallback,
        authorRole: auth.userRole,
        authorPhotoUrl: auth.photoUrl ?? '',
        location: _selectedLocation, // 👈 真实定位数据会在这里一起存入数据库
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        type: 'announcement',
      );

      await postService.createPost(post);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Post shared successfully!'),
          backgroundColor: Colors.green));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to post: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// ============================================================================
// 🌟 独立出来的专用弹窗组件，完美解决状态刷新问题
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
        body: jsonEncode({
          "input": input,
          "includedRegionCodes": ["MY"]
        }),
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
            onChanged: _searchPlacesInModal, // 触发搜索
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

          // 下拉建议列表
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
                      // 用户点击智能提示后，带着选中的文本返回主页面
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
                    // 点击 Clear 时返回空字符串，告诉主页面清空位置
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
                    // 点击 Confirm 时返回自己手动输入的文字
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
