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
  final DateTime createdAt;
  final int upvotes;
  final int downvotes;
  final int views;
  final int commentCount;
  final String status;

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
    required this.createdAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.views = 0,
    this.commentCount = 0,
    this.status = 'Open',
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
      'createdAt': Timestamp.fromDate(createdAt),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'views': views,
      'commentCount': commentCount,
      'status': status,
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      upvotes: data['upvotes'] ?? data['likes'] ?? 0, // backwards compat
      downvotes: data['downvotes'] ?? 0,
      views: data['views'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      status: data['status'] ?? 'Open',
    );
  }
}
