import 'dart:math';

import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/domain/use_cases/delete_dice.dart';
import 'package:dice_roll/domain/use_cases/get_dice_list.dart';
import 'package:dice_roll/domain/use_cases/get_selected_dice_id.dart';
import 'package:dice_roll/domain/use_cases/roll_dice.dart';
import 'package:dice_roll/domain/use_cases/save_dice.dart';
import 'package:dice_roll/domain/use_cases/set_selected_dice_id.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:flutter_test/flutter_test.dart';

DiceEntity _custom(String id, String title) => DiceEntity(
      id: id,
      title: title,
      faces: const [
        DiceFaceEntity(id: 'a', order: 0, backgroundColor: 0xFF000000),
        DiceFaceEntity(id: 'b', order: 1, backgroundColor: 0xFFFFFFFF),
        DiceFaceEntity(id: 'c', order: 2, backgroundColor: 0xFF112233),
      ],
    );

class _StubGetDiceList implements GetDiceList {
  List<DiceEntity> result;
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

class _FakeGetSelectedDiceId implements GetSelectedDiceId {
  String? id;
  _FakeGetSelectedDiceId(this.id);
  @override
  Future<String?> call() async => id;
}

class _FakeSetSelectedDiceId implements SetSelectedDiceId {
  String? lastSet;
  @override
  Future<void> call(String id) async => lastSet = id;
}

Future<DiceManagementProvider> _loadedManagement(List<DiceEntity> dice) async {
  final management = DiceManagementProvider(
    getDiceList: _StubGetDiceList(dice),
    saveDice: _NoopSaveDice(),
    deleteDice: _NoopDeleteDice(),
  );
  await management.load();
  return management;
}

void main() {
  group('DiceGameProvider — rolling (ported from RollViewModel)', () {
    late _FakeSetSelectedDiceId setSelected;

    DiceGameProvider build() {
      setSelected = _FakeSetSelectedDiceId();
      return DiceGameProvider(
        management: DiceManagementProvider(
          getDiceList: _StubGetDiceList(const []),
          saveDice: _NoopSaveDice(),
          deleteDice: _NoopDeleteDice(),
        ),
        getSelectedDiceId: _FakeGetSelectedDiceId(null),
        setSelectedDiceId: setSelected,
        rollDice: RollDice(random: Random(0)),
        random: Random(0),
      );
    }

    test('initial state matches legacy provider defaults', () {
      final vm = build();
      expect(vm.activeDice.isBuiltIn, isTrue);
      expect(vm.isRolling, isFalse);
      expect(vm.rollsDone, 0);
      expect(vm.totalRolls, 0);
    });

    test('startRolling flips isRolling and seeds totalRolls in [8, 12]', () {
      for (var i = 0; i < 50; i++) {
        final vm = build()..startRolling();
        expect(vm.isRolling, isTrue);
        expect(vm.totalRolls, inInclusiveRange(8, 12));
      }
    });

    test('onAnimationComplete cycles faces and never repeats consecutively',
        () {
      final vm = build()..startRolling();
      for (var i = 0; i < 20; i++) {
        final previousNew = vm.currentFace;
        vm.onAnimationComplete();
        if (vm.isRolling) {
          expect(vm.oldFace.id, previousNew.id);
          expect(vm.currentFace.id, isNot(vm.oldFace.id));
        }
      }
    });

    test('completes after totalRolls and resets state', () {
      final vm = build()..startRolling();
      final total = vm.totalRolls;
      for (var i = 0; i < total; i++) {
        vm.onAnimationComplete();
      }
      expect(vm.isRolling, isFalse);
      expect(vm.rollsDone, 0);
    });

    test('notifies listeners on startRolling', () {
      final vm = build();
      var notifications = 0;
      vm.addListener(() => notifications++);
      vm.startRolling();
      expect(notifications, greaterThanOrEqualTo(1));
    });
  });

  group('DiceGameProvider — selection & startup', () {
    test('loadInitial resolves the saved id against the management list',
        () async {
      final custom = _custom('c1', 'D20');
      final management =
          await _loadedManagement([const DiceEntity.builtIn(), custom]);
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceId: _FakeGetSelectedDiceId('c1'),
        setSelectedDiceId: _FakeSetSelectedDiceId(),
        rollDice: RollDice(random: Random(0)),
      );

      await vm.loadInitial();

      expect(vm.isReady, isTrue);
      expect(vm.activeDice.id, 'c1');
      expect(vm.currentFace.id, custom.faces.first.id);
    });

    test('loadInitial falls back to built-in when the id is null', () async {
      final management =
          await _loadedManagement([const DiceEntity.builtIn(), _custom('c1', 'D20')]);
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceId: _FakeGetSelectedDiceId(null),
        setSelectedDiceId: _FakeSetSelectedDiceId(),
        rollDice: RollDice(random: Random(0)),
      );

      await vm.loadInitial();

      expect(vm.activeDice.isBuiltIn, isTrue);
    });

    test('loadInitial falls back to built-in when the saved dice is gone',
        () async {
      final management =
          await _loadedManagement([const DiceEntity.builtIn()]);
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceId: _FakeGetSelectedDiceId('deleted'),
        setSelectedDiceId: _FakeSetSelectedDiceId(),
        rollDice: RollDice(random: Random(0)),
      );

      await vm.loadInitial();

      expect(vm.activeDice.isBuiltIn, isTrue);
    });

    test('select persists the id and resets roll state', () async {
      final custom = _custom('c1', 'D20');
      final management =
          await _loadedManagement([const DiceEntity.builtIn(), custom]);
      final setSelected = _FakeSetSelectedDiceId();
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceId: _FakeGetSelectedDiceId(null),
        setSelectedDiceId: setSelected,
        rollDice: RollDice(random: Random(0)),
        random: Random(0),
      )..startRolling();

      await vm.select(custom);

      expect(setSelected.lastSet, 'c1');
      expect(vm.activeDice.id, 'c1');
      expect(vm.isRolling, isFalse);
      expect(vm.rollsDone, 0);
      expect(vm.currentFace.id, custom.faces.first.id);
    });

    test('refresh falls back to built-in when the active dice was deleted',
        () async {
      final custom = _custom('c1', 'D20');
      final stub = _StubGetDiceList([const DiceEntity.builtIn(), custom]);
      final management = DiceManagementProvider(
        getDiceList: stub,
        saveDice: _NoopSaveDice(),
        deleteDice: _NoopDeleteDice(),
      );
      await management.load();
      final setSelected = _FakeSetSelectedDiceId();
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceId: _FakeGetSelectedDiceId('c1'),
        setSelectedDiceId: setSelected,
        rollDice: RollDice(random: Random(0)),
      );
      await vm.loadInitial();
      expect(vm.activeDice.id, 'c1');

      // The dice is removed from the source and the management list reloaded.
      stub.result = [const DiceEntity.builtIn()];
      await management.load();
      await vm.refresh();

      expect(vm.activeDice.isBuiltIn, isTrue);
      expect(setSelected.lastSet, DiceEntity.builtInId);
    });
  });
}
