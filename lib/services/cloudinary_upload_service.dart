import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cloudinary_config.dart';

/// Uploads image bytes to Cloudinary using an **unsigned** upload preset.
class CloudinaryUploadService {
  CloudinaryUploadService._();

  /// POSTs JPEG (or other) [bytes] and returns [secure_url].
  ///
  /// Parameters:
  /// - [bytes]: body of the multipart `file` field.
  /// - [filename]: suggested filename (e.g. `friend_12.jpg`).
  /// - [subfolder]: segment under [CloudinaryConfig.folder] (`friends` / `groups`).
  static Future<String> uploadImage({
    required List<int> bytes,
    required String filename,
    required String subfolder,
  }) async {
    if (!CloudinaryConfig.isConfigured) {
      throw StateError(
        'Cloudinary is not configured. Set CLOUDINARY_CLOUD_NAME and '
        'CLOUDINARY_UPLOAD_PRESET in assets/config/cloudinary.env, or pass '
        'the same keys via --dart-define.',
      );
    }
    final cloud = CloudinaryConfig.cloudName;
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloud/image/upload');
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
    final root = CloudinaryConfig.folder.trim();
    if (root.isNotEmpty) {
      request.fields['folder'] = '$root/$subfolder';
    }
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = response.body;
    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed (${response.statusCode}): $body');
    }
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) {
      throw FormatException('Cloudinary response is not a JSON object: $body');
    }
    final err = json['error'];
    if (err is Map && err['message'] != null) {
      throw Exception('Cloudinary error: ${err['message']}');
    }
    final url = json['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw FormatException('Cloudinary response missing secure_url: $body');
    }
    return url;
  }
}
