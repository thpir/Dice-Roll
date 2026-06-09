import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/ui/core/widgets/stored_image.dart';
import 'package:flutter/material.dart';

/// Renders the foreground graphic of a [DiceFaceEntity]. Falls back to an
/// empty [SizedBox] when the face has no foreground image.
class DiceFaceImage extends StatelessWidget {
  final DiceFaceEntity face;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? cacheWidth;

  const DiceFaceImage({
    super.key,
    required this.face,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.cacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    final path = face.imagePath;
    if (path == null) {
      return SizedBox(width: width, height: height);
    }
    return StoredImage(
      path: path,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
    );
  }
}
