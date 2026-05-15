import 'package:flutter/material.dart';

bool _looksLikeHttpUrl(String path) {
  final t = path.trim().toLowerCase();
  return t.startsWith('http://') || t.startsWith('https://');
}

/// Web: [Image.network] for URLs; otherwise [fallback] (no local file access).
Widget buildLocalFileAvatar({
  required String? absolutePath,
  required double radius,
  required Widget fallback,
}) {
  final path = absolutePath;
  if (path == null || path.isEmpty) {
    return fallback;
  }
  if (_looksLikeHttpUrl(path)) {
    final d = radius * 2;
    return ClipOval(
      child: Image.network(
        path,
        width: d,
        height: d,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return SizedBox(
            width: d,
            height: d,
            child: Center(
              child: SizedBox(
                width: radius * 0.6,
                height: radius * 0.6,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }
  return fallback;
}
