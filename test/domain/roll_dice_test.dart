import 'dart:math';

import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/domain/use_cases/roll_dice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RollDice', () {
    const dice = DiceEntity.builtIn();
    final rollDice = RollDice(random: Random(0));

    test('returned face belongs to the dice', () {
      for (var i = 0; i < 100; i++) {
        final face = rollDice(dice);
        expect(dice.faces, contains(face));
      }
    });

    test('never returns the previous face when the dice has > 1 face', () {
      var previous = dice.faces.first;
      for (var i = 0; i < 200; i++) {
        final next = rollDice(dice, previous: previous);
        expect(next.id, isNot(previous.id));
        previous = next;
      }
    });

    test('with exactly 2 faces, output strictly alternates', () {
      const twoFace = DiceEntity(
        id: 'two',
        title: 'Coin',
        faces: [
          DiceFaceEntity(id: 'a', order: 0, backgroundColor: 0xFF000000),
          DiceFaceEntity(id: 'b', order: 1, backgroundColor: 0xFFFFFFFF),
        ],
      );
      var previous = twoFace.faces.first;
      for (var i = 0; i < 50; i++) {
        final next = rollDice(twoFace, previous: previous);
        expect(next.id, isNot(previous.id));
        previous = next;
      }
    });

    test('rolls successfully with no previous face', () {
      final face = rollDice(dice);
      expect(dice.faces, contains(face));
    });
  });
}
