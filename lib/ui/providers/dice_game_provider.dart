import 'dart:math';

import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/domain/use_cases/get_selected_dice_id.dart';
import 'package:dice_roll/domain/use_cases/roll_dice.dart';
import 'package:dice_roll/domain/use_cases/set_selected_dice_id.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:flutter/foundation.dart';

/// Tracks which dice is currently active across the app, drives the rolling
/// animation, and keeps the persisted "last selected" id in sync.
///
/// Resolves the active dice from the [DiceManagementProvider]'s in-memory
/// list, falling back to the built-in dice when no selection exists or the
/// referenced dice has been deleted.
class DiceGameProvider extends ChangeNotifier {
  final DiceManagementProvider _management;
  final GetSelectedDiceId _getSelectedDiceId;
  final SetSelectedDiceId _setSelectedDiceId;
  final RollDice _rollDice;
  final Random _random;

  var _activeDice = const DiceEntity.builtIn();
  var _isReady = false;

  late DiceFaceEntity _currentFace = _activeDice.faces.first;
  late DiceFaceEntity _oldFace = _activeDice.faces.first;
  var _isRolling = false;
  var _totalRolls = 0;
  var _rollsDone = 0;

  DiceGameProvider({
    required DiceManagementProvider management,
    required GetSelectedDiceId getSelectedDiceId,
    required SetSelectedDiceId setSelectedDiceId,
    required RollDice rollDice,
    Random? random,
  })  : _management = management,
        _getSelectedDiceId = getSelectedDiceId,
        _setSelectedDiceId = setSelectedDiceId,
        _rollDice = rollDice,
        _random = random ?? Random();

  DiceEntity get activeDice => _activeDice;
  bool get isReady => _isReady;
  DiceFaceEntity get currentFace => _currentFace;
  DiceFaceEntity get oldFace => _oldFace;
  bool get isRolling => _isRolling;
  int get rollsDone => _rollsDone;
  int get totalRolls => _totalRolls;

  /// Resolves the last-selected dice id against the management provider's
  /// in-memory list (falling back to the built-in dice if there is no
  /// selection or the referenced dice has been deleted).
  Future<void> loadInitial() async {
    final id = await _getSelectedDiceId();
    if (id != null) {
      final dice = _management.diceById(id);
      if (dice != null) {
        _activeDice = dice;
        _resetRollState();
      }
    }
    _isReady = true;
    notifyListeners();
  }

  Future<void> select(DiceEntity dice) async {
    _activeDice = dice;
    _resetRollState();
    await _setSelectedDiceId(dice.id);
    notifyListeners();
  }

  /// Called after CRUD operations that might have mutated the active dice
  /// (e.g. the user renamed it). Re-resolves from the in-memory list or falls
  /// back to the built-in dice if it was deleted.
  Future<void> refresh() async {
    final dice = _management.diceById(_activeDice.id);
    if (dice == null) {
      _activeDice = const DiceEntity.builtIn();
      await _setSelectedDiceId(DiceEntity.builtInId);
    } else {
      _activeDice = dice;
    }
    _resetRollState();
    notifyListeners();
  }

  void startRolling() {
    if (_isRolling) {
      return;
    }
    _isRolling = true;
    _totalRolls = _random.nextInt(5) + 8;
    _advance();
  }

  /// Called by the view when the swap animation has finished.
  void onAnimationComplete() {
    if (!_isRolling) {
      return;
    }
    _rollsDone++;
    if (_rollsDone < _totalRolls) {
      _advance();
    } else {
      _stop();
    }
  }

  /// Per-roll animation duration in milliseconds; matches the legacy curve
  /// where each successive roll is slower than the previous one.
  int currentAnimationSpeed() => (_rollsDone + 1) * 50;

  void _advance() {
    _oldFace = _currentFace;
    _currentFace = _rollDice(_activeDice, previous: _oldFace);
    notifyListeners();
  }

  void _stop() {
    _isRolling = false;
    _rollsDone = 0;
    _totalRolls = 0;
    notifyListeners();
  }

  void _resetRollState() {
    _currentFace = _activeDice.faces.first;
    _oldFace = _activeDice.faces.first;
    _isRolling = false;
    _rollsDone = 0;
    _totalRolls = 0;
  }
}
