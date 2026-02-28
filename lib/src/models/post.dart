import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? id;
  final String title;
  final String description;
  final String authorId;
  final String authorName; // denormalized for display
  final String authorRole;
  final String authorPhotoUrl; // Google profile photo
  final String? location;
  final List<String> imageUrls;
  final List<String> categoryIds; // IDs of categories from categories collection
  final Map<String, dynamic>? sentiment;
  final Map<String, dynamic>? priority;
  final DateTime createdAt;
  final int upvotes;
  final int downvotes;
  final int views;
  final int commentCount;
  final String status;
  final String type; // 'post' or 'announcement'
  final String? verificationStatus; // 'verified' | 'partial' | 'insufficient' | 'rejected'
  final String? verificationId; // Reference to proof_verifications collection
  final DateTime? verifiedAt;
  final List<String> proofImageUrls; // Uploaded proof-of-work images
  
  // 👇 --- 新增的排重功能字段 --- 👇
  final bool isDuplicate;
  final String? originalPostId;
  // 👆 --------------------------- 👆

  final DateTime? inProgressAt;
  final DateTime? resolvedAt;

  Post({
    this.id,
    required this.title,
    required this.description,
    required this.authorId,
    this.authorName = '',
    required this.authorRole,
    this.authorPhotoUrl = '',
    this.location,
    this.imageUrls = const [],
    this.categoryIds = const [],
    this.sentiment,
    this.priority,
    required this.createdAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.views = 0,
    this.commentCount = 0,
    this.status = 'Open',
    this.type = 'post',
    this.verificationStatus,
    this.verificationId,
    this.verifiedAt,
    this.proofImageUrls = const [],

    // 👇 新增字段的默认值
    this.isDuplicate = false,
    this.originalPostId,
    this.inProgressAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorPhotoUrl': authorPhotoUrl,
      'location': location,
      'imageUrls': imageUrls,
      'categoryIds': categoryIds,
      'sentiment': sentiment,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'views': views,
      'commentCount': commentCount,
      'status': status,
      'type': type,
      'verificationStatus': verificationStatus,
      'verificationId': verificationId,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'proofImageUrls': proofImageUrls,
      
      // 👇 将新字段写入 Firebase
      'isDuplicate': isDuplicate,
      'originalPostId': originalPostId,
      'inProgressAt': inProgressAt != null ? Timestamp.fromDate(inProgressAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorRole: data['authorRole'] ?? 'user',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      location: data['location'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      sentiment: data['sentiment'] as Map<String, dynamic>?,
      priority: data['priority'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      upvotes: data['upvotes'] ?? data['likes'] ?? 0, // backwards compat
      downvotes: data['downvotes'] ?? 0,
      views: data['views'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      status: data['status'] ?? 'Open',
      type: data['type'] ?? 'post',
      verificationStatus: data['verificationStatus'],
      verificationId: data['verificationId'],
      verifiedAt: data['verifiedAt'] != null
          ? (data['verifiedAt'] as Timestamp).toDate()
          : null,
      proofImageUrls: List<String>.from(data['proofImageUrls'] ?? []),
      
      // 👇 从 Firebase 读取新字段，如果旧数据没有这个字段就给默认值
      isDuplicate: data['isDuplicate'] ?? false,
      originalPostId: data['originalPostId'],
      inProgressAt: data['inProgressAt'] != null
          ? (data['inProgressAt'] as Timestamp).toDate()
          : null,
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }
}