import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';

/// One die rendered on the roll screen. A presentation-layer model (not a
/// domain entity): it wraps a [DiceEntity] type together with the per-die
/// roll/lock state the [DiceGameProvider] mutates during play.
///
/// The roll bookkeeping mirrors the legacy single-die fields — a random
/// [totalRolls] count, a [rollsDone] counter, and a slowing animation speed —
/// applied independently to each slot so N dice animate side by side.
class DieSlot {
  /// Stable, unique-within-the-tray identifier (e.g. `'<diceId>#<seq>'`). Used
  /// as the basis for the [RollView] widget key and for lock toggling.
  final String slotId;

  /// The dice type this slot rolls.
  final DiceEntity dice;

  DiceFaceEntity currentFace;
  DiceFaceEntity oldFace;

  /// Locked slots are skipped by [DiceGameProvider.rollAll].
  bool locked;

  bool isRolling;
  int totalRolls;
  int rollsDone;

  DieSlot({
    required this.slotId,
    required this.dice,
    DiceFaceEntity? currentFace,
    DiceFaceEntity? oldFace,
    this.locked = false,
    this.isRolling = false,
    this.totalRolls = 0,
    this.rollsDone = 0,
  })  : currentFace = currentFace ?? dice.faces.first,
        oldFace = oldFace ?? dice.faces.first;

  /// Per-swap animation duration in milliseconds; each successive swap within a
  /// roll is slower than the last, matching the legacy curve.
  int currentAnimationSpeed() => (rollsDone + 1) * 50;
}
