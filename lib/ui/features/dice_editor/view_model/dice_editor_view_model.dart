import 'dart:io';

import 'package:dice_roll/data/services/image_storage_service.dart';
import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/domain/use_cases/dice_validation.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Mutable working copy of a dice face used by the editor.
class EditableFace {
  String id;
  int backgroundColor;
  String? backgroundImagePath;
  File? pendingBackgroundImageFile;
  String? imagePath;
  File? pendingImageFile;

  EditableFace({
    required this.id,
    required this.backgroundColor,
    this.backgroundImagePath,
    this.pendingBackgroundImageFile,
    this.imagePath,
    this.pendingImageFile,
  });
}

class DiceEditorViewModel extends ChangeNotifier {
  static const _defaultFaceColors = <int>[
    0xFFEF5350,
    0xFF42A5F5,
    0xFF66BB6A,
    0xFFFFEE58,
    0xFFFFA726,
    0xFFAB47BC,
    0xFF26C6DA,
    0xFF8D6E63,
  ];

  final DiceManagementProvider _management;
  final ImageStorageService _images;
  final Uuid _uuid;

  String? _editingId;
  var _title = '';
  final List<EditableFace> _faces = [];
  final List<String> _imagesToDeleteOnSave = [];

  var _isLoading = true;
  var _isSaving = false;
  String? _errorMessage;

  DiceEditorViewModel({
    required DiceManagementProvider management,
    required ImageStorageService imageStorageService,
    Uuid? uuid,
  })  : _management = management,
        _images = imageStorageService,
        _uuid = uuid ?? const Uuid();

  String? get editingId => _editingId;
  String get title => _title;
  List<EditableFace> get faces => List.unmodifiable(_faces);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get canAddFace => _faces.length < DiceValidation.maxFaces;
  bool get canRemoveFace => _faces.length > DiceValidation.minFaces;

  Future<void> load(String? diceId) async {
    _isLoading = true;
    notifyListeners();
    _editingId = diceId;
    if (diceId == null) {
      _seedNewDice();
    } else {
      final existing = _management.diceById(diceId);
      if (existing == null || existing.isBuiltIn) {
        _seedNewDice();
      } else {
        _title = existing.title;
        _faces
          ..clear()
          ..addAll(existing.faces.map(_toEditable));
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  void setTitle(String value) {
    _title = value;
    _errorMessage = null;
    notifyListeners();
  }

  void addFace() {
    if (!canAddFace) {
      return;
    }
    _faces.add(_newBlankFace(_faces.length));
    notifyListeners();
  }

  void removeFaceAt(int index) {
    if (!canRemoveFace) {
      return;
    }
    final removed = _faces.removeAt(index);
    _queueExistingForDeletion(removed.imagePath);
    _queueExistingForDeletion(removed.backgroundImagePath);
    notifyListeners();
  }

  void setFaceColor(int index, int color) {
    _faces[index].backgroundColor = color;
    notifyListeners();
  }

  void setPendingImage(int index, File file) {
    final face = _faces[index];
    _queueExistingForDeletion(face.imagePath);
    face
      ..pendingImageFile = file
      ..imagePath = null;
    notifyListeners();
  }

  void clearFaceImage(int index) {
    final face = _faces[index];
    _queueExistingForDeletion(face.imagePath);
    face
      ..imagePath = null
      ..pendingImageFile = null;
    notifyListeners();
  }

  void setPendingBackgroundImage(int index, File file) {
    final face = _faces[index];
    _queueExistingForDeletion(face.backgroundImagePath);
    face
      ..pendingBackgroundImageFile = file
      ..backgroundImagePath = null;
    notifyListeners();
  }

  void clearBackgroundImage(int index) {
    final face = _faces[index];
    _queueExistingForDeletion(face.backgroundImagePath);
    face
      ..backgroundImagePath = null
      ..pendingBackgroundImageFile = null;
    notifyListeners();
  }

  void reorderFaces(int oldIndex, int newIndex) {
    var target = newIndex;
    if (target > oldIndex) {
      target -= 1;
    }
    final moved = _faces.removeAt(oldIndex);
    _faces.insert(target, moved);
    notifyListeners();
  }

  /// Persists the dice. Returns the saved id on success, or `null` if
  /// validation failed (check [errorMessage]).
  Future<String?> save() async {
    if (_isSaving) {
      return null;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newFgPaths = <int, String>{};
      final newBgPaths = <int, String>{};
      for (var i = 0; i < _faces.length; i++) {
        final pendingFg = _faces[i].pendingImageFile;
        if (pendingFg != null) {
          newFgPaths[i] = await _images.saveImage(pendingFg);
        }
        final pendingBg = _faces[i].pendingBackgroundImageFile;
        if (pendingBg != null) {
          newBgPaths[i] = await _images.saveImage(pendingBg);
        }
      }

      final domainFaces = <DiceFaceEntity>[];
      for (var i = 0; i < _faces.length; i++) {
        final face = _faces[i];
        domainFaces.add(
          DiceFaceEntity(
            id: face.id,
            order: i,
            backgroundColor: face.backgroundColor,
            imagePath: newFgPaths[i] ?? face.imagePath,
            backgroundImagePath: newBgPaths[i] ?? face.backgroundImagePath,
          ),
        );
      }

      final id = _editingId ?? _uuid.v4();
      final entity = DiceEntity(
        id: id,
        title: _title.trim(),
        faces: domainFaces,
      );
      await _management.save(entity);

      for (final path in _imagesToDeleteOnSave) {
        await _images.deleteImage(path);
      }
      _imagesToDeleteOnSave.clear();

      for (var i = 0; i < _faces.length; i++) {
        final newFg = newFgPaths[i];
        if (newFg != null) {
          _faces[i]
            ..imagePath = newFg
            ..pendingImageFile = null;
        }
        final newBg = newBgPaths[i];
        if (newBg != null) {
          _faces[i]
            ..backgroundImagePath = newBg
            ..pendingBackgroundImageFile = null;
        }
      }
      _editingId = id;
      return id;
    } on DiceValidationException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _queueExistingForDeletion(String? path) {
    if (path == null || path.startsWith('assets/')) {
      return;
    }
    _imagesToDeleteOnSave.add(path);
  }

  EditableFace _toEditable(DiceFaceEntity face) => EditableFace(
        id: face.id,
        backgroundColor: face.backgroundColor,
        imagePath: face.imagePath,
        backgroundImagePath: face.backgroundImagePath,
      );

  void _seedNewDice() {
    _title = '';
    _faces
      ..clear()
      ..add(_newBlankFace(0))
      ..add(_newBlankFace(1));
  }

  EditableFace _newBlankFace(int order) => EditableFace(
        id: _uuid.v4(),
        backgroundColor: _defaultFaceColors[order % _defaultFaceColors.length],
      );
}
