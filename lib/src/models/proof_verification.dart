import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing AI verification results for proof of work
class ProofVerification {
  final String? id;
  final String postId;
  final String submittedBy; // User ID who submitted proof
  final String submitterName;
  final String submitterRole;
  final String proofDescription; // TODO: Replace with image URLs when implemented
  final String contextSummary; // AI-generated summary from comments
  final DateTime submittedAt;
  final VerificationRating rating;

  ProofVerification({
    this.id,
    required this.postId,
    required this.submittedBy,
    required this.submitterName,
    required this.submitterRole,
    required this.proofDescription,
    required this.contextSummary,
    required this.submittedAt,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'submittedBy': submittedBy,
      'submitterName': submitterName,
      'submitterRole': submitterRole,
      'proofDescription': proofDescription,
      'contextSummary': contextSummary,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'rating': rating.toMap(),
    };
  }

  factory ProofVerification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProofVerification(
      id: doc.id,
      postId: data['postId'] ?? '',
      submittedBy: data['submittedBy'] ?? '',
      submitterName: data['submitterName'] ?? '',
      submitterRole: data['submitterRole'] ?? 'user',
      proofDescription: data['proofDescription'] ?? '',
      contextSummary: data['contextSummary'] ?? '',
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      rating: VerificationRating.fromMap(data['rating'] ?? {}),
    );
  }
}

/// AI-generated rating for proof of work
class VerificationRating {
  final int completenessScore; // 0-100
  final int qualityScore; // 0-100
  final int overallScore; // 0-100
  final String status; // "verified" | "partial" | "insufficient" | "rejected"
  final String feedback; // AI explanation
  final double confidence; // 0.0-1.0

  VerificationRating({
    required this.completenessScore,
    required this.qualityScore,
    required this.overallScore,
    required this.status,
    required this.feedback,
    required this.confidence,
  });

  Map<String, dynamic> toMap() {
    return {
      'completenessScore': completenessScore,
      'qualityScore': qualityScore,
      'overallScore': overallScore,
      'status': status,
      'feedback': feedback,
      'confidence': confidence,
    };
  }

  factory VerificationRating.fromMap(Map<String, dynamic> map) {
    return VerificationRating(
      completenessScore: map['completenessScore'] ?? 0,
      qualityScore: map['qualityScore'] ?? 0,
      overallScore: map['overallScore'] ?? 0,
      status: map['status'] ?? 'insufficient',
      feedback: map['feedback'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
    );
  }
}
