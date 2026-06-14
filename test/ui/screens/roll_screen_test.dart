import 'dart:math';

import 'package:dice_roll/data/services/image_storage_service.dart';
import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/domain/use_cases/delete_dice.dart';
import 'package:dice_roll/domain/use_cases/get_dice_list.dart';
import 'package:dice_roll/domain/use_cases/get_selected_dice_ids.dart';
import 'package:dice_roll/domain/use_cases/roll_dice.dart';
import 'package:dice_roll/domain/use_cases/save_dice.dart';
import 'package:dice_roll/domain/use_cases/set_selected_dice_ids.dart';
import 'package:dice_roll/ui/core/theme/app_theme.dart';
import 'package:dice_roll/ui/features/roll/roll_view.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:dice_roll/ui/screens/roll_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Colour-only dice keep the roll screen out of asset/image loading, so the
/// precache step (which reads [ImageStorageService]) is a true no-op.
DiceEntity _colourDice(String id) => DiceEntity(
      id: id,
      title: id,
      faces: const [
        DiceFaceEntity(id: 'f1', order: 0, backgroundColor: 0xFFFF0000),
        DiceFaceEntity(id: 'f2', order: 1, backgroundColor: 0xFF00FF00),
        DiceFaceEntity(id: 'f3', order: 2, backgroundColor: 0xFF0000FF),
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

Future<DiceGameProvider> _game(List<String> saved, List<DiceEntity> dice) async {
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
  return game;
}

Future<void> _pump(WidgetTester tester, DiceGameProvider game) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ImageStorageService>.value(value: ImageStorageService()),
        ChangeNotifierProvider<DiceGameProvider>.value(value: game),
      ],
      child: MaterialApp(theme: AppTheme.dark, home: const RollScreen()),
    ),
  );
  await tester.pump(); // run the post-frame area/precache callbacks
}

void main() {
  testWidgets('renders one RollView per slot', (tester) async {
    final game = await _game(['d1', 'd1'], [_colourDice('d1')]);
    await _pump(tester, game);

    expect(find.byType(RollView), findsNWidgets(2));

    await tester.pumpAndSettle();
  });

  testWidgets('long-press locks a die and shows the lock affordance',
      (tester) async {
    final game = await _game(['d1'], [_colourDice('d1')]);
    await _pump(tester, game);
    expect(find.byIcon(Icons.lock), findsNothing);

    await tester.longPress(find.byType(RollView).first);
    await tester.pump();

    expect(game.slots.single.locked, isTrue);
    expect(find.byIcon(Icons.lock), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('tap rolls only the unlocked dice', (tester) async {
    final game = await _game(['d1', 'd1'], [_colourDice('d1')]);
    await _pump(tester, game);
    game.toggleLock(game.slots.first.slotId);
    await tester.pump();

    await tester.tap(find.byType(RollView).last);
    await tester.pump();

    expect(game.slots.first.isRolling, isFalse); // locked, skipped
    expect(game.slots.last.isRolling, isTrue); // unlocked, rolled

    await tester.pumpAndSettle();
  });
}
