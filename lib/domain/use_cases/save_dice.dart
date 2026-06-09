import 'package:dice_roll/domain/models/dice_entity.dart';

/// Inserts or updates a custom dice. Throws [DiceValidationException] if the
/// dice violates the rules (built-in, empty/duplicate title, face count out
/// of bounds).
abstract class SaveDice {
  Future<void> call(DiceEntity dice);
}
