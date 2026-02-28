import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_card.dart';

/// A widget that fetches and displays category tags from Firestore based on category IDs.
class CategoryTags extends StatelessWidget {
  final List<String> categoryIds;

  const CategoryTags({
    super.key,
    required this.categoryIds,
  });

  Future<List<PostTag>> _fetchCategoryTags() async {
    if (categoryIds.isEmpty) return [];

    try {
      final tags = <PostTag>[];
      
      for (final categoryId in categoryIds) {
        final doc = await FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final name = data['name'] ?? '';
          final colorHex = (data['colour'] ?? '#4CAF50').toString();
          
          // Parse color from hex string
          final color = Color(
            int.parse(
              colorHex.replaceAll('#', 'FF'),
              radix: 16,
            ),
          );

          tags.add(PostTag(label: name, color: color));
        }
      }

      return tags;
    } catch (e) {
      debugPrint('Error fetching category tags: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostTag>>(
      future: _fetchCategoryTags(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final tags = snapshot.data!;

        return Wrap(
          spacing: 6,
          runSpacing: 4,
          children: tags
              .map((tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: tag.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
