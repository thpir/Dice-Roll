import 'dart:math';
import 'dart:ui';

import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/use_cases/get_selected_dice_ids.dart';
import 'package:dice_roll/domain/use_cases/roll_dice.dart';
import 'package:dice_roll/domain/use_cases/set_selected_dice_ids.dart';
import 'package:dice_roll/ui/providers/die_slot.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:dice_roll/utils/dice_fit.dart';
import 'package:flutter/foundation.dart';

/// Owns the tray of dice shown on the roll screen: which dice are in it (and
/// how many of each), how many fit, and the per-die rolling/locking state.
///
/// Each [DieSlot] runs the same roll loop the single-die provider used to —
/// a random number of face swaps that slow down towards the end — but
/// independently, so tapping rolls every unlocked die at once. The tray's id
/// list is persisted via [SetSelectedDiceIds]; locks are in-memory only and
/// reset on restart or any selection change.
class DiceGameProvider extends ChangeNotifier {
  final DiceManagementProvider _management;
  final GetSelectedDiceIds _getSelectedDiceIds;
  final SetSelectedDiceIds _setSelectedDiceIds;
  final RollDice _rollDice;
  final Random _random;

  List<DieSlot> _slots = [];
  var _maxDice = 1;
  var _isReady = false;
  var _slotSeq = 0;

  DiceGameProvider({
    required DiceManagementProvider management,
    required GetSelectedDiceIds getSelectedDiceIds,
    required SetSelectedDiceIds setSelectedDiceIds,
    required RollDice rollDice,
    Random? random,
  })  : _management = management,
        _getSelectedDiceIds = getSelectedDiceIds,
        _setSelectedDiceIds = setSelectedDiceIds,
        _rollDice = rollDice,
        _random = random ?? Random() {
    // Seed a sensible default before [loadInitial] resolves the saved tray so
    // the roll screen always has at least one die to show.
    _slots = [_makeSlot(const DiceEntity.builtIn())];
  }

  /// The tray, in order. Read-only view; mutate via the methods below.
  List<DieSlot> get slots => List.unmodifiable(_slots);

  /// How many dice fit on the roll screen given its last measured area
  /// (default 1 until [setAvailableArea] runs). The selector caps the tray at
  /// this value.
  int get maxDice => _maxDice;

  bool get isReady => _isReady;

  /// Total number of dice in the tray.
  int get selectedCount => _slots.length;

  /// How many slots in the tray are of the dice type [diceId].
  int quantityOf(String diceId) =>
      _slots.where((s) => s.dice.id == diceId).length;

  /// True while any slot is mid-roll; the roll screen uses this to ignore
  /// re-taps until every die has settled.
  bool get isRolling => _slots.any((s) => s.isRolling);

  /// Whether a roll would do anything — false for an empty tray or one whose
  /// dice are all locked.
  bool get canRoll => _slots.any((s) => !s.locked);

  /// Resolves the persisted id list against the management provider's in-memory
  /// list, dropping unknown/deleted ids. Falls back to a single built-in die
  /// when nothing resolves. All slots start unlocked.
  Future<void> loadInitial() async {
    final ids = await _getSelectedDiceIds();
    final resolved = _resolveDice(ids);
    _slots = resolved.isEmpty
        ? [_makeSlot(const DiceEntity.builtIn())]
        : [for (final dice in resolved) _makeSlot(dice)];
    _isReady = true;
    notifyListeners();
  }

  /// Called by the roll screen's `LayoutBuilder` with the measured roll [area]
  /// and the full [screenSize]. Sets [maxDice] to the count that fits in *both*
  /// orientations (see [orientationStableMaxDice]) so rotating the device never
  /// forces the tray to shrink. When [screenSize] is omitted the roll area is
  /// assumed to fill the screen (no chrome).
  ///
  /// Still trims slots from the end as a safety net if the cap ever drops below
  /// the tray size, persisting the change. Only notifies when something actually
  /// changed, so it's safe to call every layout.
  void setAvailableArea(Size area, {Size? screenSize}) {
    final newMax = orientationStableMaxDice(area, screenSize ?? area);
    var changed = false;
    if (newMax != _maxDice) {
      _maxDice = newMax;
      changed = true;
    }
    if (_slots.length > _maxDice) {
      _slots = _slots.sublist(0, _maxDice);
      _persist();
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Adds one slot of [dice] to the tray, unless it's already full.
  void increment(DiceEntity dice) {
    if (selectedCount >= _maxDice) {
      return;
    }
    _slots.add(_makeSlot(dice));
    _persist();
    notifyListeners();
  }

  /// Removes the last slot of [dice]'s type, if any. The tray may become empty.
  void decrement(DiceEntity dice) {
    final index = _slots.lastIndexWhere((s) => s.dice.id == dice.id);
    if (index < 0) {
      return;
    }
    _slots.removeAt(index);
    _persist();
    notifyListeners();
  }

  /// Clears the tray back to a single built-in die, dropping all locks.
  void resetToDefault() {
    _slots = [_makeSlot(const DiceEntity.builtIn())];
    _persist();
    notifyListeners();
  }

  /// Starts a roll on every unlocked, not-already-rolling slot.
  void rollAll() {
    var started = false;
    for (final slot in _slots) {
      if (slot.locked || slot.isRolling) {
        continue;
      }
      slot.isRolling = true;
      slot.rollsDone = 0;
      slot.totalRolls = _random.nextInt(5) + 8;
      _advanceSlot(slot);
      started = true;
    }
    if (started) {
      notifyListeners();
    }
  }

  /// Called by a slot's [RollView] when its swap animation finishes. Advances
  /// that slot to the next face, or stops it once its [DieSlot.totalRolls] is
  /// reached.
  void onSlotAnimationComplete(String slotId) {
    final slot = _slotById(slotId);
    if (slot == null || !slot.isRolling) {
      return;
    }
    slot.rollsDone++;
    if (slot.rollsDone < slot.totalRolls) {
      _advanceSlot(slot);
    } else {
      slot.isRolling = false;
      slot.rollsDone = 0;
      slot.totalRolls = 0;
    }
    notifyListeners();
  }

  /// Toggles the lock on the slot with [slotId]. Locked slots are skipped on a
  /// roll.
  void toggleLock(String slotId) {
    final slot = _slotById(slotId);
    if (slot == null) {
      return;
    }
    slot.locked = !slot.locked;
    notifyListeners();
  }

  /// Called after dice CRUD: re-resolves each slot's type, dropping slots whose
  /// dice was deleted while keeping quantities and locks for surviving types.
  /// Falls back to a single built-in die if the tray empties out.
  Future<void> refresh() async {
    final kept = <DieSlot>[];
    for (final slot in _slots) {
      final dice = _management.diceById(slot.dice.id);
      if (dice != null) {
        // Reseat onto the (possibly edited) dice, preserving the lock but
        // resetting the roll state since the faces may have changed.
        kept.add(DieSlot(slotId: slot.slotId, dice: dice, locked: slot.locked));
      }
    }
    _slots = kept.isEmpty ? [_makeSlot(const DiceEntity.builtIn())] : kept;
    await _persist();
    notifyListeners();
  }

  void _advanceSlot(DieSlot slot) {
    slot.oldFace = slot.currentFace;
    slot.currentFace = _rollDice(slot.dice, previous: slot.oldFace);
  }

  Future<void> _persist() =>
      _setSelectedDiceIds([for (final s in _slots) s.dice.id]);

  DieSlot _makeSlot(DiceEntity dice) =>
      DieSlot(slotId: '${dice.id}#${_slotSeq++}', dice: dice);

  DieSlot? _slotById(String slotId) {
    for (final slot in _slots) {
      if (slot.slotId == slotId) {
        return slot;
      }
    }
    return null;
  }

  List<DiceEntity> _resolveDice(List<String> ids) {
    final resolved = <DiceEntity>[];
    for (final id in ids) {
      final dice = _management.diceById(id);
      if (dice != null) {
        resolved.add(dice);
      }
    }
    return resolved;
  }
}
