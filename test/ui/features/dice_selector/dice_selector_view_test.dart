import 'dart:math';

import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/domain/use_cases/delete_dice.dart';
import 'package:dice_roll/domain/use_cases/get_dice_list.dart';
import 'package:dice_roll/domain/use_cases/get_selected_dice_ids.dart';
import 'package:dice_roll/domain/use_cases/roll_dice.dart';
import 'package:dice_roll/domain/use_cases/save_dice.dart';
import 'package:dice_roll/domain/use_cases/set_selected_dice_ids.dart';
import 'package:dice_roll/ui/core/theme/app_theme.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_icon_button.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_outlined_button.dart';
import 'package:dice_roll/ui/features/dice_selector/widgets/dice_selector_view.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

DiceEntity _colourDice(String id) => DiceEntity(
      id: id,
      title: id,
      faces: const [
        DiceFaceEntity(id: 'f1', order: 0, backgroundColor: 0xFFFF0000),
        DiceFaceEntity(id: 'f2', order: 1, backgroundColor: 0xFF00FF00),
      ],
    );

class _StubGetDiceList implements GetDiceList {
  final List<DiceEntity> result;
  _StubGetDiceList(this.result);
  @override
  Future<List<DiceEntity>> call() async => result;
}

class _NoopSaveDice implements SaveDice {
  @override
  Future<void> call(DiceEntity dice) async {}
}

class _NoopDeleteDice implements DeleteDice {
  @override
  Future<void> call(String id) async {}
}

class _FakeGetIds implements GetSelectedDiceIds {
  final List<String> ids;
  _FakeGetIds(this.ids);
  @override
  Future<List<String>> call() async => ids;
}

class _FakeSetIds implements SetSelectedDiceIds {
  @override
  Future<void> call(List<String> ids) async {}
}

Future<({DiceManagementProvider management, DiceGameProvider game})> _setup({
  required List<DiceEntity> dice,
  List<String> saved = const [],
  Size area = const Size(1000, 1000), // maxDice = 100
}) async {
  final management = DiceManagementProvider(
    getDiceList: _StubGetDiceList(dice),
    saveDice: _NoopSaveDice(),
    deleteDice: _NoopDeleteDice(),
  );
  await management.load();
  final game = DiceGameProvider(
    management: management,
    getSelectedDiceIds: _FakeGetIds(saved),
    setSelectedDiceIds: _FakeSetIds(),
    rollDice: RollDice(random: Random(0)),
    random: Random(0),
  );
  await game.loadInitial();
  game.setAvailableArea(area);
  return (management: management, game: game);
}

Future<void> _pump(
  WidgetTester tester,
  DiceManagementProvider management,
  DiceGameProvider game,
) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DiceManagementProvider>.value(value: management),
        ChangeNotifierProvider<DiceGameProvider>.value(value: game),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: DiceSelectorView()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('stepper increments and decrements a quantity', (tester) async {
    final s = await _setup(
      dice: [_colourDice('d1'), _colourDice('d2')],
      saved: ['d1'],
    );
    await _pump(tester, s.management, s.game);
    expect(s.game.quantityOf('d1'), 1);

    await tester.tap(find.byIcon(Icons.add).first); // d1's [+]
    await tester.pumpAndSettle();
    expect(s.game.quantityOf('d1'), 2);

    await tester.tap(find.byIcon(Icons.remove).first); // d1's [-]
    await tester.pumpAndSettle();
    expect(s.game.quantityOf('d1'), 1);
  });

  testWidgets('[+] is disabled once the tray is full', (tester) async {
    // 250x150 -> floor(2.5) * floor(1.5) = 2 dice fit.
    final s = await _setup(
      dice: [_colourDice('d1'), _colourDice('d2')],
      saved: ['d1'],
      area: const Size(250, 150),
    );
    await _pump(tester, s.management, s.game);
    expect(s.game.maxDice, 2);
    expect(find.text('1 / 2 dice'), findsOneWidget);

    // Fill the tray by adding d2.
    await tester.tap(find.byIcon(Icons.add).at(1));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2 dice'), findsOneWidget);

    // Every [+] is now disabled...
    final addButtons = tester.widgetList<AppIconButton>(
      find.ancestor(
        of: find.byIcon(Icons.add),
        matching: find.byType(AppIconButton),
      ),
    );
    expect(addButtons, isNotEmpty);
    expect(addButtons.every((b) => b.onPressed == null), isTrue);

    // ...and tapping one is a no-op.
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(s.game.selectedCount, 2);
  });

  testWidgets('reset clears the tray back to a single default die',
      (tester) async {
    final s = await _setup(
      dice: [_colourDice('d1'), _colourDice('d2')],
      saved: ['d1', 'd2'],
    );
    await _pump(tester, s.management, s.game);
    expect(find.text('2 / 100 dice'), findsOneWidget);

    await tester.tap(find.byType(AppOutlinedButton));
    await tester.pumpAndSettle();

    expect(s.game.selectedCount, 1);
    expect(s.game.quantityOf('d1'), 0);
    expect(s.game.quantityOf('d2'), 0);
    expect(find.text('1 / 100 dice'), findsOneWidget);
  });
}
