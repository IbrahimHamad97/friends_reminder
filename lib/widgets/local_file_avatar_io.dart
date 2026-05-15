import 'dart:io';

import 'package:flutter/material.dart';

bool _looksLikeHttpUrl(String path) {
  final t = path.trim().toLowerCase();
  return t.startsWith('http://') || t.startsWith('https://');
}

/// IO: [Image.network] / [Image.file] with [errorBuilder] so [fallback] shows on failure.
Widget buildLocalFileAvatar({
  required String? absolutePath,
  required double radius,
  required Widget fallback,
}) {
  final path = absolutePath;
  if (path == null || path.isEmpty) {
    return fallback;
  }
  final d = radius * 2;
  if (_looksLikeHttpUrl(path)) {
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
  final file = File(path);
  if (!file.existsSync()) {
    return fallback;
  }
  return ClipOval(
    child: Image.file(
      file,
      width: d,
      height: d,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    ),
  );
}
