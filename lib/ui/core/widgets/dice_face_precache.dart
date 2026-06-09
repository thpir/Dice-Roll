import 'dart:io';

import 'package:dice_roll/data/services/image_storage_service.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Target decode width (in raw pixels) for dice face images in the roller.
/// Faces render at a few hundred logical pixels, so decoding at this width
/// keeps them crisp while avoiding full-resolution decodes of heavy source
/// images. Used both when precaching ([precacheDiceFaces]) and when rendering
/// ([StoredImage.cacheWidth]) — the two MUST match or precaching is a no-op.
const kDiceFaceDecodeWidth = 800;

/// Warms Flutter's [ImageCache] with the background and foreground images of
/// [faces] so they paint on the first frame of the roll animation instead of
/// popping in after an on-the-fly decode.
///
/// The providers built here mirror exactly what [StoredImage] renders with
/// (same [ResizeImage] target width), so the cache keys match. Best-effort:
/// unresolved paths are skipped.
Future<void> precacheDiceFaces(
  BuildContext context,
  Iterable<DiceFaceEntity> faces, {
  int? cacheWidth = kDiceFaceDecodeWidth,
}) async {
  final images = context.read<ImageStorageService>();
  final paths = <String>{
    for (final face in faces) ...[
      if (face.backgroundImagePath != null) face.backgroundImagePath!,
      if (face.imagePath != null) face.imagePath!,
    ],
  };

  for (final path in paths) {
    final provider = await _providerFor(images, path, cacheWidth);
    if (provider == null || !context.mounted) {
      continue;
    }
    await precacheImage(provider, context);
  }
}

/// Builds the same [ImageProvider] that [StoredImage] uses for [path],
/// including the [ResizeImage] wrapper when [cacheWidth] is set. Returns
/// `null` when a file path cannot be resolved.
Future<ImageProvider?> _providerFor(
  ImageStorageService images,
  String path,
  int? cacheWidth,
) async {
  if (path.startsWith('assets/')) {
    return ResizeImage.resizeIfNeeded(cacheWidth, null, AssetImage(path));
  }
  final absolute =
      images.absolutePathForSync(path) ?? await images.absolutePathFor(path);
  if (absolute == null) {
    return null;
  }
  return ResizeImage.resizeIfNeeded(cacheWidth, null, FileImage(File(absolute)));
}
