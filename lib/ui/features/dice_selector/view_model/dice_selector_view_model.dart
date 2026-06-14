import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';

/// Thin feature-scoped coordinator for the dice selector.
///
/// The tray is app-wide state owned by [DiceGameProvider], so this view model
/// holds no state of its own — it just exposes the quantity-editing operations
/// and the derived flags the selector needs, keeping that logic out of the
/// widget. Because there is no local state, the view listens to
/// [DiceGameProvider] directly for rebuilds and reads this coordinator only for
/// actions (so it is provided with a plain `Provider`, not a
/// `ChangeNotifierProvider`).
class DiceSelectorViewModel {
  final DiceGameProvider _game;

  DiceSelectorViewModel(this._game);

  int get selectedCount => _game.selectedCount;
  int get maxDice => _game.maxDice;

  /// True once the tray holds as many dice as fit on the roll screen.
  bool get isFull => _game.selectedCount >= _game.maxDice;

  int quantityOf(DiceEntity dice) => _game.quantityOf(dice.id);

  bool canIncrement(DiceEntity dice) => !isFull;
  bool canDecrement(DiceEntity dice) => quantityOf(dice) > 0;

  void increment(DiceEntity dice) => _game.increment(dice);
  void decrement(DiceEntity dice) => _game.decrement(dice);
  void resetToDefault() => _game.resetToDefault();
}
