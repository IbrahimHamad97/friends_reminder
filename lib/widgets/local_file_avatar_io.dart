import 'dart:io';

import 'package:flutter/material.dart';

/// IO: shows [FileImage] when [absolutePath] exists.
Widget buildLocalFileAvatar({
  required String? absolutePath,
  required double radius,
  required Widget fallback,
}) {
  final path = absolutePath;
  if (path == null || path.isEmpty) {
    return fallback;
  }
  final file = File(path);
  if (!file.existsSync()) {
    return fallback;
  }
  return CircleAvatar(
    radius: radius,
    backgroundImage: FileImage(file),
  );
}
