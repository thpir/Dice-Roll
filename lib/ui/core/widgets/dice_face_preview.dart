import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/ui/core/widgets/dice_face_image.dart';
import 'package:dice_roll/ui/core/widgets/stored_image.dart';
import 'package:flutter/material.dart';

/// Renders the full visual of a [DiceFaceEntity]: background colour, then
/// the optional background image (cover), then the optional foreground
/// image (contained). Sizes itself to the available space.
class DiceFacePreview extends StatelessWidget {
  final DiceFaceEntity face;
  final BorderRadius? borderRadius;
  final int? backgroundCacheWidth;
  final int? foregroundCacheWidth;

  /// Optional constraints applied around the foreground image (e.g. cap at
  /// 300×300 in the roller).
  final BoxConstraints? foregroundConstraints;

  /// Optional explicit size for the foreground image. Useful for animating
  /// the foreground while the background fills the parent.
  final double? foregroundWidth;
  final double? foregroundHeight;
  final BoxFit foregroundFit;

  const DiceFacePreview({
    super.key,
    required this.face,
    this.borderRadius,
    this.backgroundCacheWidth,
    this.foregroundCacheWidth,
    this.foregroundConstraints,
    this.foregroundWidth,
    this.foregroundHeight,
    this.foregroundFit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final bgPath = face.backgroundImagePath;
    final fgPath = face.imagePath;

    Widget foreground = DiceFaceImage(
      face: face,
      width: foregroundWidth,
      height: foregroundHeight,
      fit: foregroundFit,
      cacheWidth: foregroundCacheWidth,
    );
    if (foregroundConstraints != null) {
      foreground = ConstrainedBox(
        constraints: foregroundConstraints!,
        child: foreground,
      );
    }

    Widget content = Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Color(face.backgroundColor)),
        if (bgPath != null)
          StoredImage(
            path: bgPath,
            fit: BoxFit.cover,
            cacheWidth: backgroundCacheWidth,
          ),
        if (fgPath != null) Center(child: foreground),
      ],
    );

    if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }
    return content;
  }
}
