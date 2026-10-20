import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/picked_photo_reduce.dart';

/// Client-side compress then on-device save for group cover images.
class GroupPhotoStorage {
  GroupPhotoStorage._();

  /// Saves a picked file for [groupId] after app-side resize/compress.
  static Future<String> saveForGroupFromPath(int groupId, String sourcePath) {
    return saveForGroup(groupId, File(sourcePath));
  }

  /// Same as [saveForGroupFromPath] with an open [File].
  static Future<String> saveForGroup(int groupId, File source) async {
    if (kIsWeb) {
      throw UnsupportedError('Group photos are not saved on web');
    }
    final bytes = await PickedPhotoReducer.readReducedJpegBytes(
      source,
      PickedPhotoKind.groupCover,
    );
    final dir = await _groupsPhotosDir();
    final dest = File('${dir.path}/group_$groupId.jpg');
    if (await dest.exists()) {
      await dest.delete();
    }
    await dest.writeAsBytes(bytes, flush: true);
    return dest.path;
  }

  /// Deletes a local file when [path] is on disk; no-op for remote URLs.
  static Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty || _looksLikeHttpUrl(path)) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<Directory> _groupsPhotosDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/photos/groups');
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
