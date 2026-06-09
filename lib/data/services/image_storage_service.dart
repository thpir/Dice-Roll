import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Owns the on-disk lifecycle of dice face images. Images live in
/// `<appDocs>/dice_faces/`; only the relative file name is stored in the
/// database.
class ImageStorageService {
  static const _dirName = 'dice_faces';

  final Uuid _uuid;

  /// Cached application documents directory. Constant for the app's lifetime,
  /// so once resolved the relative→absolute mapping can be done synchronously
  /// (see [absolutePathForSync]). Populated by [warmUp] or on first async use.
  Directory? _docsDir;

  ImageStorageService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Resolves and caches the documents directory ahead of time so that
  /// [absolutePathForSync] can serve callers without an await. Safe to call
  /// repeatedly; only the first call hits the platform channel.
  Future<void> warmUp() async {
    _docsDir ??= await getApplicationDocumentsDirectory();
  }

  Future<Directory> _docs() async =>
      _docsDir ??= await getApplicationDocumentsDirectory();

  Future<Directory> _imagesDir() async {
    final docs = await _docs();
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
    final docs = await _docs();
    return '${docs.path}/$relativePath';
  }

  /// Synchronous variant of [absolutePathFor]. Returns `null` for asset paths
  /// (load via [Image.asset]) and also `null` when the documents directory has
  /// not been cached yet (call [warmUp] first, or fall back to the async
  /// [absolutePathFor]). Lets hot paths such as the roll animation resolve
  /// without an await, avoiding per-frame `FutureBuilder` churn.
  String? absolutePathForSync(String relativePath) {
    if (relativePath.startsWith('assets/')) {
      return null;
    }
    final docs = _docsDir;
    if (docs == null) {
      return null;
    }
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
