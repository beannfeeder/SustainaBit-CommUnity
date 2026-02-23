import 'package:flutter/material.dart';

/// A circular avatar that shows a network photo (from our own Firebase Storage)
/// with a graceful fallback. Uses [Image.network] instead of
/// [CircleAvatar.backgroundImage] so CORS/network errors are caught
/// via [errorBuilder] rather than crashing the widget tree.
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final bool isManagement;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.radius = 20,
    this.isManagement = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                // Graceful fallback on any network / CORS error
                errorBuilder: (_, __, ___) => _placeholder(size),
              )
            : _placeholder(size),
      ),
    );
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      color: isManagement ? const Color(0xFF4A90E2) : Colors.grey[400],
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
  }
}
