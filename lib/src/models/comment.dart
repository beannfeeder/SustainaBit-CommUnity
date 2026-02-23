import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String? id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String authorPhotoUrl;
  final String content;
  final DateTime createdAt;

  Comment({
    this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorPhotoUrl = '',
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorRole: data['authorRole'] ?? 'user',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
