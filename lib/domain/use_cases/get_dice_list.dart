import 'package:dice_roll/domain/models/dice_entity.dart';

/// Returns every dice known to the app, with the built-in dice first.
abstract class GetDiceList {
  Future<List<DiceEntity>> call();
}
