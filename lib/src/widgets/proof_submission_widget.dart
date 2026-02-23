import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../models/proof_verification.dart';
import '../services/proof_verification_service.dart';
import '../providers/auth_provider.dart';

/// Example widget showing how to use AI Proof of Work Verification
/// 
/// TODO: When image upload is implemented, replace proofDescription 
/// with actual image URLs and use Gemini Vision API
class ProofSubmissionWidget extends StatefulWidget {
  final Post post;

  const ProofSubmissionWidget({super.key, required this.post});

  @override
  State<ProofSubmissionWidget> createState() => _ProofSubmissionWidgetState();
}

class _ProofSubmissionWidgetState extends State<ProofSubmissionWidget> {
  final TextEditingController _proofController = TextEditingController();
  final ProofVerificationService _verificationService =
      ProofVerificationService();

  bool _isVerifying = false;
  ProofVerification? _verificationResult;

  @override
  void dispose() {
    _proofController.dispose();
    super.dispose();
  }

  Future<void> _submitProof() async {
    if (_proofController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the proof of work'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    if (auth.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationResult = null;
    });

    try {
      // AI verification workflow
      final verification = await _verificationService.verifyProofOfWork(
        postId: widget.post.id!,
        postTitle: widget.post.title,
        postDescription: widget.post.description,
        proofDescription: _proofController.text.trim(),
        submittedBy: auth.userId!,
        submitterName: auth.displayNameOrFallback,
        submitterRole: auth.userRole,
      );

      if (mounted) {
        setState(() {
          _verificationResult = verification;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification Complete: ${verification.rating.status.toUpperCase()}',
            ),
            backgroundColor: _getStatusColor(verification.rating.status),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'insufficient':
        return Colors.red.shade300;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Proof of Work',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Describe what was done to resolve this issue. AI will verify based on comments and context.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // TODO: Replace this TextField with image picker when implemented
            TextField(
              controller: _proofController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Example: "Repaired broken streetlight on Main St. Replaced bulb and tested circuit. Light is now functioning."',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 12),

            // TODO: Add image upload button here
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'TODO: Image upload will be added here. AI will analyze photos.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _submitProof,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isVerifying
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
                          Text('AI is verifying...'),
                        ],
                      )
                    : const Text('Submit & Verify with AI'),
              ),
            ),

            // Verification results
            if (_verificationResult != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildVerificationResults(_verificationResult!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationResults(ProofVerification verification) {
    final rating = verification.rating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'AI Verification Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(rating.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rating.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Scores
        _buildScoreRow('Completeness', rating.completenessScore),
        const SizedBox(height: 8),
        _buildScoreRow('Quality', rating.qualityScore),
        const SizedBox(height: 8),
        _buildScoreRow('Overall', rating.overallScore, isOverall: true),
        const SizedBox(height: 16),

        // AI Feedback
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Feedback:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                rating.feedback,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Context Summary
        ExpansionTile(
          title: const Text(
            'Context from Comments',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                verification.contextSummary,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),

        // Confidence
        Row(
          children: [
            const Text(
              'AI Confidence: ',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '${(rating.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreRow(String label, int score, {bool isOverall = false}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isOverall ? 14 : 13,
              fontWeight: isOverall ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              score >= 80
                  ? Colors.green
                  : score >= 50
                      ? Colors.orange
                      : Colors.red,
            ),
            minHeight: isOverall ? 12 : 8,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '$score',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: isOverall ? FontWeight.bold : FontWeight.normal,
              fontSize: isOverall ? 14 : 13,
            ),
          ),
        ),
      ],
    );
  }
}
