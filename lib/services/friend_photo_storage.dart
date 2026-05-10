import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies picked images into app-private storage and deletes unused files.
class FriendPhotoStorage {
  FriendPhotoStorage._();

  /// Ensures the friend photo directory exists and returns it.
  ///
  /// Returns: `friend_photos` under the app documents directory.
  static Future<Directory> friendPhotosDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'friend_photos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copies a file at [sourcePath] into permanent storage for [friendId].
  ///
  /// Parameters:
  /// - [friendId]: owning friend row id used in the filename.
  /// - [sourcePath]: absolute path from the image picker.
  ///
  /// Returns: absolute path to the copied image (jpg/png preserved by extension).
  static Future<String> saveForFriendFromPath(int friendId, String sourcePath) async {
    return saveForFriend(friendId, File(sourcePath));
  }

  /// Copies [source] into permanent storage for [friendId].
  ///
  /// Parameters:
  /// - [friendId]: owning friend row id used in the filename.
  /// - [source]: temporary file from the image picker.
  ///
  /// Returns: absolute path to the copied image (jpg/png preserved by extension).
  static Future<String> saveForFriend(int friendId, File source) async {
    final ext = p.extension(source.path);
    final safeExt = ext.isEmpty ? '.jpg' : ext;
    final dir = await friendPhotosDirectory();
    final dest = File(p.join(dir.path, 'friend_$friendId$safeExt'));
    if (await dest.exists()) {
      await dest.delete();
    }
    await source.copy(dest.path);
    return dest.path;
  }

  /// Deletes a stored image if [path] is non-null and the file exists.
  ///
  /// Parameters:
  /// - [path]: absolute path previously returned by [saveForFriend].
  ///
  /// Returns: future that completes when deletion is attempted.
  static Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
