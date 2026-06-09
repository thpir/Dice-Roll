import 'dart:math';

import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';

/// Picks a face from [dice] uniformly at random, excluding [previous] when
/// the dice has more than one face. With exactly two faces the result
/// strictly alternates — accepted per the product decision.
class RollDice {
  final Random _random;

  RollDice({Random? random}) : _random = random ?? Random();

  DiceFaceEntity call(DiceEntity dice, {DiceFaceEntity? previous}) {
    if (dice.faces.isEmpty) {
      throw StateError('Cannot roll a dice with no faces.');
    }
    if (previous == null || dice.faces.length == 1) {
      return dice.faces[_random.nextInt(dice.faces.length)];
    }
    final candidates = dice.faces.where((f) => f.id != previous.id).toList();
    if (candidates.isEmpty) {
      return dice.faces[_random.nextInt(dice.faces.length)];
    }
    return candidates[_random.nextInt(candidates.length)];
  }
}
