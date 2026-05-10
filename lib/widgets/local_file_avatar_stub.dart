import 'package:flutter/material.dart';

/// Web / non-IO: always shows [fallback].
Widget buildLocalFileAvatar({
  required String? absolutePath,
  required double radius,
  required Widget fallback,
}) {
  return fallback;
}
