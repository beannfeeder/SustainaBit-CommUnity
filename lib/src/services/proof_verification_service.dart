import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../gemeni_service.dart';
import '../models/proof_verification.dart';
import '../models/comment.dart';

/// Service for AI-powered proof of work verification
class ProofVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Step 1: Generate AI context summary from post comments
  Future<String> _generateContextSummary(String postId) async {
    try {
      // Fetch all comments for the post
      final commentsSnapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt')
          .get();

      if (commentsSnapshot.docs.isEmpty) {
        return 'No comments available for this issue.';
      }

      final comments = commentsSnapshot.docs
          .map((doc) => Comment.fromFirestore(doc))
          .toList();

      // Build comment thread for AI
      final commentThread = comments.map((c) {
        return '${c.authorName} (${c.authorRole}): ${c.content}';
      }).join('\n');

      final prompt = '''
You are analyzing a community issue report to understand the context and progress.

Below are the comments from the issue discussion thread in chronological order:

$commentThread

Generate a concise context summary (2-3 sentences) that captures:
- What the main issue is
- What actions were discussed or taken
- Current status or expectations

Return ONLY the summary text, no formatting or extra commentary.
''';

      final summary = await GeminiService.generate(prompt);
      return summary.trim();
    } catch (e) {
      debugPrint('Error generating context summary: $e');
      return 'Unable to generate context summary.';
    }
  }

  /// Step 2: AI analyzes proof of work and returns rating
  Future<VerificationRating> _analyzeProof({
    required String postTitle,
    required String postDescription,
    required String contextSummary,
    required String proofDescription,
  }) async {
    try {
      final prompt = '''
You are an AI system that verifies proof of work for community issue resolutions.

ISSUE CONTEXT:
Title: $postTitle
Description: $postDescription

DISCUSSION SUMMARY:
$contextSummary

SUBMITTED PROOF OF WORK:
$proofDescription

Your task is to analyze whether the proof adequately demonstrates that the issue has been resolved.

Return ONLY valid JSON in this exact format:
{
  "completenessScore": integer 0-100 (does proof address all aspects mentioned?),
  "qualityScore": integer 0-100 (is proof clear, detailed, credible?),
  "overallScore": integer 0-100 (weighted average),
  "status": "verified | partial | insufficient | rejected",
  "feedback": "Short explanation for the rating (max 2 sentences)",
  "confidence": number 0.0-1.0 (how confident is this assessment)
}

Rating Guidelines:
- "verified" = Proof clearly demonstrates complete resolution (>80 overall)
- "partial" = Proof shows progress but incomplete (50-80 overall)
- "insufficient" = Proof lacks detail or doesn't address issue (20-50 overall)
- "rejected" = Proof is irrelevant or fabricated (<20 overall)

Do NOT include markdown formatting.
Do NOT include explanations outside JSON.
''';

      final response = await GeminiService.generate(prompt);

      String jsonString = response.trim();
      jsonString = jsonString
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> ratingData = jsonDecode(jsonString);

      // Validate required fields
      if (!ratingData.containsKey('completenessScore') ||
          !ratingData.containsKey('qualityScore') ||
          !ratingData.containsKey('overallScore') ||
          !ratingData.containsKey('status') ||
          !ratingData.containsKey('feedback') ||
          !ratingData.containsKey('confidence')) {
        throw Exception('Invalid rating response structure');
      }

      return VerificationRating.fromMap(ratingData);
    } catch (e) {
      debugPrint('Error analyzing proof: $e');

      // Fallback rating
      return VerificationRating(
        completenessScore: 0,
        qualityScore: 0,
        overallScore: 0,
        status: 'insufficient',
        feedback: 'Unable to verify proof due to analysis error.',
        confidence: 0.0,
      );
    }
  }

  /// Complete verification workflow
  Future<ProofVerification> verifyProofOfWork({
    required String postId,
    required String postTitle,
    required String postDescription,
    required String proofDescription,
    required String submittedBy,
    required String submitterName,
    required String submitterRole,
  }) async {
    try {
      // Step 1: Generate context from comments
      final contextSummary = await _generateContextSummary(postId);

      // Step 2: AI analyzes proof
      final rating = await _analyzeProof(
        postTitle: postTitle,
        postDescription: postDescription,
        contextSummary: contextSummary,
        proofDescription: proofDescription,
      );

      // Step 3: Create verification record
      final verification = ProofVerification(
        postId: postId,
        submittedBy: submittedBy,
        submitterName: submitterName,
        submitterRole: submitterRole,
        proofDescription: proofDescription,
        contextSummary: contextSummary,
        submittedAt: DateTime.now(),
        rating: rating,
      );

      // Step 4: Save to Firestore
      final docRef = await _firestore
          .collection('proof_verifications')
          .add(verification.toMap());

      // Step 5: Update post with verification status
      await _firestore.collection('posts').doc(postId).update({
        'verificationStatus': rating.status,
        'verificationId': docRef.id,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      return ProofVerification(
        id: docRef.id,
        postId: verification.postId,
        submittedBy: verification.submittedBy,
        submitterName: verification.submitterName,
        submitterRole: verification.submitterRole,
        proofDescription: verification.proofDescription,
        contextSummary: verification.contextSummary,
        submittedAt: verification.submittedAt,
        rating: verification.rating,
      );
    } catch (e) {
      debugPrint('Error in proof verification workflow: $e');
      rethrow;
    }
  }

  /// Get verification for a specific post
  Future<ProofVerification?> getVerification(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('proof_verifications')
          .where('postId', isEqualTo: postId)
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return ProofVerification.fromFirestore(snapshot.docs.first);
    } catch (e) {
      debugPrint('Error fetching verification: $e');
      return null;
    }
  }

  /// Stream of verifications (for management dashboard)
  Stream<List<ProofVerification>> getVerificationsStream() {
    return _firestore
        .collection('proof_verifications')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(ProofVerification.fromFirestore).toList());
  }
}
