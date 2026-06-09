import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiceEntity.builtIn', () {
    test('has the six legacy faces in order', () {
      const dice = DiceEntity.builtIn();
      expect(dice.id, DiceEntity.builtInId);
      expect(dice.isBuiltIn, isTrue);
      expect(dice.faces, hasLength(6));
      for (var i = 0; i < 6; i++) {
        expect(dice.faces[i].order, i);
        expect(dice.faces[i].imagePath, 'assets/images/${i + 1}.png');
      }
    });

    test('matches the legacy ARGB palette', () {
      const expected = <int>[
        0xFFF44336, // red
        0xFF2196F3, // blue
        0xFF4CAF50, // green
        0xFFFFEB3B, // yellow
        0xFFFF9800, // orange
        0xFF9C27B0, // purple
      ];
      const dice = DiceEntity.builtIn();
      expect(
        dice.faces.map((f) => f.backgroundColor).toList(),
        expected,
      );
    });
  });
}
