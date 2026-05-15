import 'dart:io';

import 'package:flutter/foundation.dart';

import '../utils/picked_photo_reduce.dart';
import 'cloudinary_upload_service.dart';

/// Compresses picked images client-side, uploads to Cloudinary, returns HTTPS URLs.
class FriendPhotoStorage {
  FriendPhotoStorage._();

  /// Uploads a file at [sourcePath] for [friendId] after resize/JPEG re-encode.
  ///
  /// Parameters:
  /// - [friendId]: owning friend row id (used in the upload filename hint).
  /// - [sourcePath]: absolute path from the image picker / crop temp file.
  ///
  /// Returns: `https://…` secure URL from Cloudinary.
  static Future<String> saveForFriendFromPath(int friendId, String sourcePath) async {
    return saveForFriend(friendId, File(sourcePath));
  }

  /// Same as [saveForFriendFromPath] with an open [File].
  static Future<String> saveForFriend(int friendId, File source) async {
    if (kIsWeb) {
      throw UnsupportedError('Friend photos are not saved on web');
    }
    final bytes = await PickedPhotoReducer.readReducedJpegBytes(
      source,
      PickedPhotoKind.friendAvatar,
    );
    return CloudinaryUploadService.uploadImage(
      bytes: bytes,
      filename: 'friend_$friendId.jpg',
      subfolder: 'friends',
    );
  }

  /// Deletes a local file when [path] is a filesystem path; no-op for remote URLs.
  static Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty || _looksLikeHttpUrl(path)) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static bool _looksLikeHttpUrl(String path) {
    final t = path.trim().toLowerCase();
    return t.startsWith('http://') || t.startsWith('https://');
  }
}
