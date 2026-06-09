import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/use_cases/delete_dice.dart';
import 'package:dice_roll/domain/use_cases/get_dice_list.dart';
import 'package:dice_roll/domain/use_cases/save_dice.dart';
import 'package:flutter/foundation.dart';

/// Owns every dice CRUD operation against the database and keeps the full
/// list of available dice in memory. Spun up first at startup so the
/// [DiceGameProvider] can resolve the previously-selected dice from the
/// loaded list.
class DiceManagementProvider extends ChangeNotifier {
  final GetDiceList _getDiceList;
  final SaveDice _saveDice;
  final DeleteDice _deleteDice;

  List<DiceEntity> _dice = const [];
  var _isLoading = true;

  DiceManagementProvider({
    required GetDiceList getDiceList,
    required SaveDice saveDice,
    required DeleteDice deleteDice,
  })  : _getDiceList = getDiceList,
        _saveDice = saveDice,
        _deleteDice = deleteDice;

  List<DiceEntity> get dice => _dice;
  bool get isLoading => _isLoading;

  /// Loads every available dice into memory. Called once at startup and again
  /// after any CRUD operation to keep the in-memory list authoritative.
  Future<void> load() async {
    _dice = await _getDiceList();
    _isLoading = false;
    notifyListeners();
  }

  /// Synchronous lookup against the in-memory list. The built-in dice is
  /// always present, so this returns `null` only for unknown/deleted ids.
  DiceEntity? diceById(String id) {
    for (final dice in _dice) {
      if (dice.id == id) {
        return dice;
      }
    }
    return null;
  }

  /// Persists [dice] (insert or update) and reloads the in-memory list.
  /// Propagates [DiceValidationException] from the repository on invalid input.
  Future<void> save(DiceEntity dice) async {
    await _saveDice(dice);
    await load();
  }

  /// Deletes the dice with [id] (along with its face images, handled in the
  /// repository) and reloads the in-memory list.
  Future<void> delete(String id) async {
    await _deleteDice(id);
    await load();
  }
}
