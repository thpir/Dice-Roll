import 'dart:io';

import 'package:dice_roll/data/services/image_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Renders any image path the app stores — an asset path (`assets/…`) or a
/// relative file path inside the app's image storage directory. Resolves
/// the relative path to an absolute path lazily via [ImageStorageService].
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
      );
    }
    final images = context.read<ImageStorageService>();
    return FutureBuilder<String?>(
      future: images.absolutePathFor(path),
      builder: (context, snapshot) {
        final absolute = snapshot.data;
        if (absolute == null) {
          return placeholder ?? SizedBox(width: width, height: height);
        }
        return Image.file(
          File(absolute),
          width: width,
          height: height,
          fit: fit,
          cacheWidth: cacheWidth,
        );
      },
    );
  }
}
