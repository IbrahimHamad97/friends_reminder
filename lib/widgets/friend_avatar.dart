import 'package:flutter/material.dart';

import 'local_file_avatar.dart';

/// Circular avatar: optional local photo file, otherwise first letter of [name].
class FriendAvatar extends StatelessWidget {
  /// Creates an avatar for [name] with optional [photoPath] (Cloudinary URL or legacy disk path).
  ///
  /// Parameters:
  /// - [name]: source string; first character is shown when no usable photo.
  /// - [photoPath]: optional `https://…` from [FriendPhotoStorage] or older local path.
  /// - [radius]: circle radius; defaults to 24 logical pixels.
  /// - [background]: optional override for letter fallback.
  /// - [foreground]: optional override for letter fallback.
  const FriendAvatar({
    super.key,
    required this.name,
    this.photoPath,
    this.radius = 24,
    this.background,
    this.foreground,
  });

  /// Friend display name driving the initial letter fallback.
  final String name;

  /// Optional photo: HTTPS URL (Cloudinary) or legacy local file path.
  final String? photoPath;

  /// Radius of the circular avatar.
  final double radius;

  /// Optional custom background color for letter fallback.
  final Color? background;

  /// Optional custom foreground color for letter fallback.
  final Color? foreground;

  /// Builds either a photo avatar or initial letter.
  ///
  /// Parameters:
  /// - [context]: used to read [ColorScheme] when colors are omitted.
  ///
  /// Returns: a circular avatar widget.
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final letter =
        name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: background ?? scheme.primaryContainer,
      foregroundColor: foreground ?? scheme.onPrimaryContainer,
      child: Text(
        letter,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.85,
        ),
      ),
    );
    final path = photoPath;
    if (path != null && path.isNotEmpty) {
      return buildLocalFileAvatar(
        absolutePath: path,
        radius: radius,
        fallback: fallback,
      );
    }
    return fallback;
  }
}
