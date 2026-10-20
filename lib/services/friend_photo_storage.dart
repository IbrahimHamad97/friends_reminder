import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/picked_photo_reduce.dart';

/// Compresses picked images client-side and stores them under app documents.
class FriendPhotoStorage {
  FriendPhotoStorage._();

  /// Saves a file at [sourcePath] for [friendId] after resize/JPEG re-encode.
  ///
  /// Parameters:
  /// - [friendId]: owning friend row id (used in the on-disk filename).
  /// - [sourcePath]: absolute path from the image picker / crop temp file.
  ///
  /// Returns: absolute path to the JPEG in app storage.
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
    final dir = await _friendsPhotosDir();
    final dest = File('${dir.path}/friend_$friendId.jpg');
    if (await dest.exists()) {
      await dest.delete();
    }
    await dest.writeAsBytes(bytes, flush: true);
    return dest.path;
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

  static Future<Directory> _friendsPhotosDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/photos/friends');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static bool _looksLikeHttpUrl(String path) {
    final t = path.trim().toLowerCase();
    return t.startsWith('http://') || t.startsWith('https://');
  }
}
