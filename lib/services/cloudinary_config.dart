import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads Cloudinary credentials from `--dart-define=...` (overrides) or [dotenv].
///
/// [dotenv] is populated in [main] from `assets/config/cloudinary.env`.
class CloudinaryConfig {
  CloudinaryConfig._();

  static String get cloudName {
    const fromDefine = String.fromEnvironment('CLOUDINARY_CLOUD_NAME', defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['CLOUDINARY_CLOUD_NAME']?.trim() ?? '';
  }

  static String get uploadPreset {
    const fromDefine = String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET', defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['CLOUDINARY_UPLOAD_PRESET']?.trim() ?? '';
  }

  /// Optional prefix for uploads (`folder` in the upload API).
  static String get folder {
    const fromDefine = String.fromEnvironment('CLOUDINARY_FOLDER', defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    final fromEnv = dotenv.env['CLOUDINARY_FOLDER']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return 'friends_reminder';
  }

  static bool get isConfigured => cloudName.isNotEmpty && uploadPreset.isNotEmpty;
}
