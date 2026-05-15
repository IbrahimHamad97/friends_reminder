import 'dart:io';

import 'package:flutter/foundation.dart';

import '../utils/picked_photo_reduce.dart';
import 'cloudinary_upload_service.dart';

/// Client-side compress then Cloudinary upload for group cover images.
class GroupPhotoStorage {
  GroupPhotoStorage._();

  /// Uploads a picked file for [groupId] after app-side resize/compress.
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
    return CloudinaryUploadService.uploadImage(
      bytes: bytes,
      filename: 'group_$groupId.jpg',
      subfolder: 'groups',
    );
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

  static bool _looksLikeHttpUrl(String path) {
    final t = path.trim().toLowerCase();
    return t.startsWith('http://') || t.startsWith('https://');
  }
}
