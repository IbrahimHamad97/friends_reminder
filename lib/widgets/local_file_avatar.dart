import 'package:flutter/material.dart';

import 'local_file_avatar_stub.dart'
    if (dart.library.io) 'local_file_avatar_io.dart' as impl;

/// Circular avatar from [absolutePath]: **HTTPS URL** or **local file** on IO builds.
///
/// On load/decode failure, returns [fallback] (e.g. initial letter from [FriendAvatar]).
///
/// Parameters:
/// - [absolutePath]: optional `https://…` URL or disk path; on web, only URLs show a photo.
/// - [radius]: avatar radius.
/// - [fallback]: widget when the path is missing, not a URL on web, or load fails.
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
