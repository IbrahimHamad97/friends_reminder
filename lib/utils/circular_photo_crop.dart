import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../screens/circular_crop_screen.dart';

/// Opens a full-screen **circular** 1:1 crop editor ([CircularCropScreen] / [crop_your_image]).
class CircularPhotoCrop {
  CircularPhotoCrop._();

  /// Pushes [CircularCropScreen] and returns a temp file path to the cropped image, or `null` if cancelled.
  static Future<String?> pushCropEditor(
    BuildContext context, {
    required Uint8List imageBytes,
    String title = 'Crop photo',
  }) {
    return Navigator.of(context).push<String?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => CircularCropScreen(
          imageBytes: imageBytes,
          title: title,
        ),
      ),
    );
  }
}
