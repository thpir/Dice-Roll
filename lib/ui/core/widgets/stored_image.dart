import 'dart:io';

import 'package:dice_roll/data/services/image_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Renders any image path the app stores — an asset path (`assets/…`) or a
/// relative file path inside the app's image storage directory.
///
/// File paths resolve synchronously via [ImageStorageService.absolutePathForSync]
/// when the service has been warmed up (the common case once the app has
/// started), so no `FutureBuilder` rebuild occurs on hot paths such as the
/// roll animation. It only falls back to the async [ImageStorageService.absolutePathFor]
/// when the documents directory has not been cached yet.
class StoredImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? cacheWidth;
  final Widget? placeholder;

  const StoredImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.cacheWidth,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        gaplessPlayback: true,
      );
    }
    final images = context.read<ImageStorageService>();

    // Fast path: resolve synchronously when the service is warmed up, so no
    // FutureBuilder is created (and re-run on every animation frame).
    final syncPath = images.absolutePathForSync(path);
    if (syncPath != null) {
      return _fileImage(syncPath);
    }

    // Fallback: documents directory not cached yet — resolve asynchronously.
    return FutureBuilder<String?>(
      future: images.absolutePathFor(path),
      builder: (context, snapshot) {
        final absolute = snapshot.data;
        if (absolute == null) {
          return placeholder ?? SizedBox(width: width, height: height);
        }
        return _fileImage(absolute);
      },
    );
  }

  Widget _fileImage(String absolute) {
    return Image.file(
      File(absolute),
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
    );
  }
}
