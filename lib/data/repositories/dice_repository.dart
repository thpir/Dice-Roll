import 'package:dice_roll/data/models/dice_db_model.dart';
import 'package:dice_roll/data/services/hive_service.dart';
import 'package:dice_roll/data/services/image_storage_service.dart';
import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/use_cases/delete_dice.dart';
import 'package:dice_roll/domain/use_cases/dice_validation.dart';
import 'package:dice_roll/domain/use_cases/get_dice_list.dart';
import 'package:dice_roll/domain/use_cases/save_dice.dart';

/// Shared backing store for all dice-related use cases. The built-in dice is
/// hardcoded and never touches Hive; custom dice are persisted to the
/// `dices` box keyed by id.
class DiceRepository {
  final HiveService _hive;
  final ImageStorageService _images;

  DiceRepository({
    required HiveService hive,
    required ImageStorageService images,
  })  : _hive = hive,
        _images = images;

  static const _builtIn = DiceEntity.builtIn();

  Future<List<DiceEntity>> getAll() async {
    final stored = _hive.dicesBox.values.map((m) => m.toDomain()).toList()
      ..sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    return [_builtIn, ...stored];
  }

  Future<void> save(DiceEntity dice) async {
    if (dice.isBuiltIn || dice.id == DiceEntity.builtInId) {
      throw const DiceValidationException(
        'The built-in dice cannot be modified.',
      );
    }
    final trimmedTitle = dice.title.trim();
    if (trimmedTitle.isEmpty) {
      throw const DiceValidationException('Title cannot be empty.');
    }
    if (dice.faces.length < DiceValidation.minFaces) {
      throw const DiceValidationException(
        'A dice must have at least ${DiceValidation.minFaces} faces.',
      );
    }
    if (dice.faces.length > DiceValidation.maxFaces) {
      throw const DiceValidationException(
        'A dice can have at most ${DiceValidation.maxFaces} faces.',
      );
    }

    final lowerTitle = trimmedTitle.toLowerCase();
    final duplicate = _hive.dicesBox.values.any(
      (existing) =>
          existing.id != dice.id &&
          existing.title.toLowerCase() == lowerTitle,
    );
    if (duplicate) {
      throw DiceValidationException(
        'A dice named "$trimmedTitle" already exists.',
      );
    }

    final normalised = dice.copyWith(title: trimmedTitle);
    await _hive.dicesBox.put(dice.id, DiceDbModel.fromDomain(normalised));
  }

  Future<void> delete(String id) async {
    if (id == DiceEntity.builtInId) {
      throw const DiceValidationException(
        'The built-in dice cannot be deleted.',
      );
    }
    final existing = _hive.dicesBox.get(id);
    if (existing == null) {
      return;
    }
    final domain = existing.toDomain();
    await _hive.dicesBox.delete(id);
    for (final face in domain.faces) {
      await _maybeDeleteImage(face.imagePath);
      await _maybeDeleteImage(face.backgroundImagePath);
    }
  }

  Future<void> _maybeDeleteImage(String? path) async {
    if (path == null || path.startsWith('assets/')) {
      return;
    }
    await _images.deleteImage(path);
  }
}

class GetDiceListImpl implements GetDiceList {
  final DiceRepository _repository;
  GetDiceListImpl(this._repository);

  @override
  Future<List<DiceEntity>> call() => _repository.getAll();
}

class SaveDiceImpl implements SaveDice {
  final DiceRepository _repository;
  SaveDiceImpl(this._repository);

  @override
  Future<void> call(DiceEntity dice) => _repository.save(dice);
}

class DeleteDiceImpl implements DeleteDice {
  final DiceRepository _repository;
  DeleteDiceImpl(this._repository);

  @override
  Future<void> call(String id) => _repository.delete(id);
}
