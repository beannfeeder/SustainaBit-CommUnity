import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String? id;
  final String authorId;
  final String authorRole;
  final String content;
  final DateTime createdAt;

  Comment({
    this.id,
    required this.authorId,
    required this.authorRole,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorRole': authorRole,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorRole: data['authorRole'] ?? 'user',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
