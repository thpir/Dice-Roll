import 'dart:ui';

import 'package:dice_roll/utils/dice_fit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('maxDiceFor', () {
    test('never returns less than 1, even for a degenerate area', () {
      expect(maxDiceFor(Size.zero), 1);
      expect(maxDiceFor(const Size(50, 50)), 1);
      expect(maxDiceFor(const Size(99, 99)), 1);
    });

    test('counts whole 100px tiles in each axis', () {
      expect(maxDiceFor(const Size(100, 100)), 1);
      expect(maxDiceFor(const Size(200, 100)), 2);
      expect(maxDiceFor(const Size(200, 200)), 4);
      expect(maxDiceFor(const Size(1000, 1000)), 100);
    });

    test('floors fractional tiles (just under the next boundary fits fewer)',
        () {
      expect(maxDiceFor(const Size(299, 199)), 2); // 2 cols x 1 row
      expect(maxDiceFor(const Size(300, 200)), 6); // 3 cols x 2 rows
    });

    test('honours a custom minTile', () {
      expect(maxDiceFor(const Size(200, 200), minTile: 50), 16);
      expect(maxDiceFor(const Size(200, 200), minTile: 200), 1);
    });
  });

  group('orientationStableMaxDice', () {
    test('caps to the tighter orientation so a rotation never trims', () {
      // 400x800 phone, ~208px of chrome. Portrait fits 20, landscape only 8.
      expect(
        orientationStableMaxDice(const Size(400, 592), const Size(400, 800)),
        8,
      );
      // Measured from landscape instead: same device, same answer.
      expect(
        orientationStableMaxDice(const Size(800, 192), const Size(800, 400)),
        8,
      );
    });

    test('a plain transpose would overestimate the tight orientation', () {
      // Transposing the portrait roll area (592x400) predicts 20, which would
      // trim to landscape's true 8 on rotation. The chrome-aware result is 8.
      expect(maxDiceFor(const Size(592, 400)), 20);
      expect(
        orientationStableMaxDice(const Size(400, 592), const Size(400, 800)),
        lessThan(20),
      );
    });

    test('with no chrome it is the min of the area and its transpose', () {
      expect(
        orientationStableMaxDice(const Size(250, 150), const Size(250, 150)),
        2,
      );
      expect(
        orientationStableMaxDice(const Size(1000, 1000), const Size(1000, 1000)),
        100,
      );
    });

    test('never returns less than 1', () {
      expect(
        orientationStableMaxDice(const Size(50, 50), const Size(50, 50)),
        1,
      );
    });
  });

  group('gridColumnsFor', () {
    test('one or zero dice always use a single column', () {
      expect(gridColumnsFor(0, const Size(800, 600)), 1);
      expect(gridColumnsFor(1, const Size(800, 600)), 1);
    });

    test('spreads two dice across the wide axis', () {
      expect(gridColumnsFor(2, const Size(400, 100)), 2);
      expect(gridColumnsFor(2, const Size(100, 400)), 1);
    });

    test('packs four dice into a 2x2 square area', () {
      expect(gridColumnsFor(4, const Size(200, 200)), 2);
    });

    test('uses a full row when the area is short and wide', () {
      expect(gridColumnsFor(3, const Size(300, 100)), 3);
    });
  });
}
