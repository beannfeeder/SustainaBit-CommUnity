import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';
import '../models/comment.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String _collectionName = 'posts';

  // ── Read ────────────────────────────────────────────────────────────────────

  /// Real-time stream of all posts, newest first.
  Stream<List<Post>> getPostsStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Post.fromFirestore).toList());
  }

  /// Fetch a single post by document ID.
  Future<Post?> getPostById(String postId) async {
    final doc = await _firestore.collection(_collectionName).doc(postId).get();
    if (!doc.exists) return null;
    return Post.fromFirestore(doc);
  }

  /// Real-time stream of comments for a post, oldest first.
  Stream<List<Comment>> getCommentsStream(String postId) {
    return _firestore
        .collection(_collectionName)
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map(Comment.fromFirestore).toList());
  }

  // ── Write ───────────────────────────────────────────────────────────────────

  /// Create a post document in Firestore.
  Future<String> createPost(Post post) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(post.toMap())
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception(
                "Firestore took too long to respond. Are your security rules configured?"),
          );
      return docRef.id;
    } catch (e) {
      debugPrint("Error creating post: $e");
      rethrow;
    }
  }

  /// Add a comment to a post's `comments` sub-collection and increment count.
  Future<void> addComment(String postId, Comment comment) async {
    final batch = _firestore.batch();
    final commentRef = _firestore
        .collection(_collectionName)
        .doc(postId)
        .collection('comments')
        .doc();
    batch.set(commentRef, comment.toMap());
    batch.update(
      _firestore.collection(_collectionName).doc(postId),
      {'commentCount': FieldValue.increment(1)},
    );
    await batch.commit();
  }

  // ── Votes ───────────────────────────────────────────────────────────────────

  /// Atomically upvote a post. Removes a prior downvote if present.
  /// Stores which users voted in a `votes/{userId}` sub-document.
  Future<void> upvotePost(String postId, String userId) async {
    final voteRef = _firestore
        .collection(_collectionName)
        .doc(postId)
        .collection('votes')
        .doc(userId);
    final postRef = _firestore.collection(_collectionName).doc(postId);

    await _firestore.runTransaction((tx) async {
      final voteSnap = await tx.get(voteRef);
      final String? currentVote =
          voteSnap.exists ? voteSnap['type'] as String? : null;

      if (currentVote == 'up') {
        // Already upvoted → undo
        tx.delete(voteRef);
        tx.update(postRef, {'upvotes': FieldValue.increment(-1)});
      } else if (currentVote == 'down') {
        // Switch from downvote to upvote
        tx.set(voteRef, {'type': 'up'});
        tx.update(postRef, {
          'upvotes': FieldValue.increment(1),
          'downvotes': FieldValue.increment(-1),
        });
      } else {
        // Fresh upvote
        tx.set(voteRef, {'type': 'up'});
        tx.update(postRef, {'upvotes': FieldValue.increment(1)});
      }
    });
  }

  /// Atomically downvote a post. Removes a prior upvote if present.
  Future<void> downvotePost(String postId, String userId) async {
    final voteRef = _firestore
        .collection(_collectionName)
        .doc(postId)
        .collection('votes')
        .doc(userId);
    final postRef = _firestore.collection(_collectionName).doc(postId);

    await _firestore.runTransaction((tx) async {
      final voteSnap = await tx.get(voteRef);
      final String? currentVote =
          voteSnap.exists ? voteSnap['type'] as String? : null;

      if (currentVote == 'down') {
        // Already downvoted → undo
        tx.delete(voteRef);
        tx.update(postRef, {'downvotes': FieldValue.increment(-1)});
      } else if (currentVote == 'up') {
        // Switch from upvote to downvote
        tx.set(voteRef, {'type': 'down'});
        tx.update(postRef, {
          'downvotes': FieldValue.increment(1),
          'upvotes': FieldValue.increment(-1),
        });
      } else {
        // Fresh downvote
        tx.set(voteRef, {'type': 'down'});
        tx.update(postRef, {'downvotes': FieldValue.increment(1)});
      }
    });
  }

  /// Get the current user's vote for a post ('up', 'down', or null).
  Future<String?> getUserVote(String postId, String userId) async {
    final doc = await _firestore
        .collection(_collectionName)
        .doc(postId)
        .collection('votes')
        .doc(userId)
        .get();
    return doc.exists ? doc['type'] as String? : null;
  }

  /// Increment view count once per screen visit.
  Future<void> incrementViews(String postId) async {
    await _firestore.collection(_collectionName).doc(postId).update({
      'views': FieldValue.increment(1),
    });
  }

  // ── Images ──────────────────────────────────────────────────────────────────

  Future<List<String>> uploadImages(List<XFile> images) async {
    List<String> downloadUrls = [];
    for (var image in images) {
      try {
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        Reference ref = _storage.ref().child('post_images/$fileName');
        final Uint8List data = await image.readAsBytes();
        final metadata =
            SettableMetadata(contentType: image.mimeType ?? 'image/jpeg');
        UploadTask uploadTask = ref.putData(data, metadata);
        TaskSnapshot snapshot = await uploadTask.timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception("Image upload timed out."),
        );
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        debugPrint("Error uploading image: $e");
        rethrow;
      }
    }
    return downloadUrls;
  }
}
