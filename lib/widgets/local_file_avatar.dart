import 'package:flutter/material.dart';

import 'local_file_avatar_stub.dart'
    if (dart.library.io) 'local_file_avatar_io.dart' as impl;

/// Shows a circular image from [absolutePath] when the file exists on IO builds.
///
/// Parameters:
/// - [absolutePath]: optional filesystem path; ignored on web or when missing.
/// - [radius]: avatar radius.
/// - [fallback]: widget when no usable local file (or on web).
///
/// Returns: a circular clipped avatar.
Widget buildLocalFileAvatar({
  required String? absolutePath,
  required double radius,
  required Widget fallback,
}) {
  return impl.buildLocalFileAvatar(
    absolutePath: absolutePath,
    radius: radius,
    fallback: fallback,
  );
}
