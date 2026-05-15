import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// What kind of photo the user picked (drives max pixel edge and JPEG quality).
enum PickedPhotoKind {
  /// Friend avatar / profile photo in lists.
  friendAvatar,

  /// Group header cover image (slightly larger long edge).
  groupCover,
}

/// App-side resize + JPEG re-encode so stored files stay small and EXIF-heavy originals are not kept as-is.
///
/// Order of attempts:
/// 1. [FlutterImageCompress] on Android / iOS / macOS (handles HEIC and fast native encode).
/// 2. [image] decode → scale long edge → [encodeJpg] (JPEG has no GPS block from our pixels; works on more platforms).
/// 3. Copy original to a temp `.jpg` path (last resort; rare formats).
class PickedPhotoReducer {
  PickedPhotoReducer._();

  static int _maxLongEdge(PickedPhotoKind kind) {
    switch (kind) {
      case PickedPhotoKind.friendAvatar:
        return 1024;
      case PickedPhotoKind.groupCover:
        return 1600;
    }
  }

  static int _jpegQuality(PickedPhotoKind kind) {
    switch (kind) {
      case PickedPhotoKind.friendAvatar:
        return 80;
      case PickedPhotoKind.groupCover:
        return 82;
    }
  }

  /// Writes a reduced JPEG to a new temp file and returns it.
  ///
  /// On web, returns [source] unchanged (callers should avoid persisting photos on web).
  static Future<File> reduceToTemp(File source, PickedPhotoKind kind) async {
    if (kIsWeb) {
      return source;
    }

    final tmpDir = await getTemporaryDirectory();
    final out = File(
      '${tmpDir.path}/reduced_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    if (await out.exists()) {
      await out.delete();
    }

    final maxEdge = _maxLongEdge(kind);
    final quality = _jpegQuality(kind);

    if (await _tryFlutterImageCompress(source, out, maxEdge, quality)) {
      return out;
    }
    if (await out.exists()) {
      await out.delete();
    }

    if (await _tryImagePackage(source, out, maxEdge, quality)) {
      return out;
    }
    if (await out.exists()) {
      await out.delete();
    }

    await source.copy(out.path);
    return out;
  }

  /// Reads [source] through the same resize/JPEG pipeline as [reduceToTemp], returns bytes, deletes temp output.
  ///
  /// On web, reads [source] bytes as-is (callers should avoid persisting photos on web).
  static Future<List<int>> readReducedJpegBytes(File source, PickedPhotoKind kind) async {
    if (kIsWeb) {
      return source.readAsBytes();
    }
    final tmp = await reduceToTemp(source, kind);
    try {
      return await tmp.readAsBytes();
    } finally {
      if (tmp.path != source.path) {
        try {
          if (await tmp.exists()) {
            await tmp.delete();
          }
        } catch (_) {}
      }
    }
  }

  /// Uses native compressor; [minWidth]/[minHeight] bound the larger output dimensions (see plugin docs).
  static Future<bool> _tryFlutterImageCompress(
    File source,
    File out,
    int maxEdge,
    int quality,
  ) async {
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
      return false;
    }
    try {
      final xfile = await FlutterImageCompress.compressAndGetFile(
        source.absolute.path,
        out.absolute.path,
        minWidth: maxEdge,
        minHeight: maxEdge,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      return xfile != null && await out.exists() && await out.length() > 0;
    } catch (_) {
      return false;
    }
  }

  /// Pure Dart resize + JPEG encode (strips original container metadata).
  static Future<bool> _tryImagePackage(
    File source,
    File out,
    int maxLongEdge,
    int jpgQuality,
  ) async {
    try {
      final raw = await source.readAsBytes();
      final decoded = img.decodeImage(raw);
      if (decoded == null) {
        return false;
      }
      final w = decoded.width;
      final h = decoded.height;
      if (w <= 0 || h <= 0) {
        return false;
      }
      final long = w > h ? w : h;
      img.Image resized = decoded;
      if (long > maxLongEdge) {
        final scale = maxLongEdge / long;
        final nw = (w * scale).round().clamp(1, 16384);
        final nh = (h * scale).round().clamp(1, 16384);
        resized = img.copyResize(
          decoded,
          width: nw,
          height: nh,
          interpolation: img.Interpolation.average,
        );
      }
      final bytes = img.encodeJpg(resized, quality: jpgQuality);
      await out.writeAsBytes(bytes, flush: true);
      return await out.length() > 0;
    } catch (_) {
      return false;
    }
  }
}
