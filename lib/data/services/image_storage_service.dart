import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Owns the on-disk lifecycle of dice face images. Images live in
/// `<appDocs>/dice_faces/`; only the relative file name is stored in the
/// database.
class ImageStorageService {
  static const _dirName = 'dice_faces';

  final Uuid _uuid;

  ImageStorageService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  Future<Directory> _imagesDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$_dirName');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copies [source] into the app's image directory under a generated name
  /// and returns the **relative** path (e.g. `dice_faces/<uuid>.png`).
  Future<String> saveImage(File source) async {
    final dir = await _imagesDir();
    final extension = _extensionOf(source.path);
    final fileName = '${_uuid.v4()}$extension';
    final destination = File('${dir.path}/$fileName');
    await source.copy(destination.path);
    return '$_dirName/$fileName';
  }

  Future<void> deleteImage(String relativePath) async {
    final absolute = await absolutePathFor(relativePath);
    if (absolute == null) {
      return;
    }
    final file = File(absolute);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Resolves a stored relative path to an absolute path on disk. Returns
  /// `null` for asset paths (e.g. `assets/images/1.png`) which the UI must
  /// load via [Image.asset] instead.
  Future<String?> absolutePathFor(String relativePath) async {
    if (relativePath.startsWith('assets/')) {
      return null;
    }
    final docs = await getApplicationDocumentsDirectory();
    return '${docs.path}/$relativePath';
  }

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) {
      return '';
    }
    return path.substring(dot);
  }
}
