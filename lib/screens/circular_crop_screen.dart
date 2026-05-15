import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Full-screen editor: **circular** crop mask, 1:1 aspect, pinch/zoom ([crop_your_image]).
class CircularCropScreen extends StatefulWidget {
  /// Creates the crop page.
  const CircularCropScreen({
    super.key,
    required this.imageBytes,
    required this.title,
  });

  /// Raw image bytes from the picker.
  final Uint8List imageBytes;

  /// App bar title.
  final String title;

  @override
  State<CircularCropScreen> createState() => _CircularCropScreenState();
}

class _CircularCropScreenState extends State<CircularCropScreen> {
  final CropController _controller = CropController();

  void _onCropped(CropResult result) {
    if (!mounted) {
      return;
    }
    if (result is CropFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not crop: ${result.cause}')),
      );
      return;
    }
    if (result is CropSuccess) {
      _saveAndPop(result.croppedImage);
    }
  }

  Future<void> _saveAndPop(Uint8List cropped) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/circle_crop_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(cropped, flush: true);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop<String>(file.path);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save crop: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cancel',
          onPressed: () => Navigator.of(context).pop<String?>(null),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Crop(
                  image: widget.imageBytes,
                  controller: _controller,
                  withCircleUi: true,
                  aspectRatio: 1,
                  interactive: true,
                  initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                    size: 0.88,
                    aspectRatio: 1,
                  ),
                  baseColor: scheme.surface,
                  maskColor: Colors.black.withValues(alpha: 0.52),
                  onCropped: _onCropped,
                  progressIndicator: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _controller.cropCircle(),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Use this crop'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
