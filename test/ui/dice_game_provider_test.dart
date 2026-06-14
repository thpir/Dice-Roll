import 'dart:math';
import 'dart:ui';

import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/domain/use_cases/delete_dice.dart';
import 'package:dice_roll/domain/use_cases/get_dice_list.dart';
import 'package:dice_roll/domain/use_cases/get_selected_dice_ids.dart';
import 'package:dice_roll/domain/use_cases/roll_dice.dart';
import 'package:dice_roll/domain/use_cases/save_dice.dart';
import 'package:dice_roll/domain/use_cases/set_selected_dice_ids.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:flutter_test/flutter_test.dart';

const _bigArea = Size(1000, 1000); // maxDice = 100

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

class _FakeGetSelectedDiceIds implements GetSelectedDiceIds {
  List<String> ids;
  _FakeGetSelectedDiceIds(this.ids);
  @override
  Future<List<String>> call() async => ids;
}

class _FakeSetSelectedDiceIds implements SetSelectedDiceIds {
  List<String>? lastSet;
  @override
  Future<void> call(List<String> ids) async => lastSet = ids;
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
  group('DiceGameProvider — rolling (per slot)', () {
    late _FakeSetSelectedDiceIds setIds;

    DiceGameProvider build() {
      setIds = _FakeSetSelectedDiceIds();
      return DiceGameProvider(
        management: DiceManagementProvider(
          getDiceList: _StubGetDiceList(const []),
          saveDice: _NoopSaveDice(),
          deleteDice: _NoopDeleteDice(),
        ),
        getSelectedDiceIds: _FakeGetSelectedDiceIds(const []),
        setSelectedDiceIds: setIds,
        rollDice: RollDice(random: Random(0)),
        random: Random(0),
      );
    }

    test('starts with a single unlocked built-in slot', () {
      final vm = build();
      expect(vm.selectedCount, 1);
      final slot = vm.slots.single;
      expect(slot.dice.isBuiltIn, isTrue);
      expect(slot.locked, isFalse);
      expect(slot.isRolling, isFalse);
      expect(slot.rollsDone, 0);
      expect(slot.totalRolls, 0);
      expect(vm.isRolling, isFalse);
    });

    test('rollAll marks the slot rolling and seeds totalRolls in [8, 12]', () {
      for (var i = 0; i < 50; i++) {
        final vm = build()..rollAll();
        final slot = vm.slots.single;
        expect(slot.isRolling, isTrue);
        expect(slot.totalRolls, inInclusiveRange(8, 12));
        expect(vm.isRolling, isTrue);
      }
    });

    test('onSlotAnimationComplete cycles faces and never repeats consecutively',
        () {
      final vm = build()..rollAll();
      final slot = vm.slots.single;
      for (var i = 0; i < 20; i++) {
        final previousFace = slot.currentFace;
        vm.onSlotAnimationComplete(slot.slotId);
        if (slot.isRolling) {
          expect(slot.oldFace.id, previousFace.id);
          expect(slot.currentFace.id, isNot(slot.oldFace.id));
        }
      }
    });

    test('completes after totalRolls swaps and resets the slot', () {
      final vm = build()..rollAll();
      final slot = vm.slots.single;
      final total = slot.totalRolls;
      for (var i = 0; i < total; i++) {
        vm.onSlotAnimationComplete(slot.slotId);
      }
      expect(vm.isRolling, isFalse);
      expect(slot.isRolling, isFalse);
      expect(slot.rollsDone, 0);
    });

    test('notifies listeners on rollAll', () {
      final vm = build();
      var notifications = 0;
      vm.addListener(() => notifications++);
      vm.rollAll();
      expect(notifications, greaterThanOrEqualTo(1));
    });
  });

  group('DiceGameProvider — startup', () {
    test('loadInitial builds slots from the saved id list (order + repeats)',
        () async {
      final management = await _loadedManagement(
        [const DiceEntity.builtIn(), _custom('c1', 'D20'), _custom('c2', 'Coin')],
      );
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceIds: _FakeGetSelectedDiceIds(['c1', 'c1', 'c2']),
        setSelectedDiceIds: _FakeSetSelectedDiceIds(),
        rollDice: RollDice(random: Random(0)),
      );

      await vm.loadInitial();

      expect(vm.isReady, isTrue);
      expect(vm.selectedCount, 3);
      expect(vm.quantityOf('c1'), 2);
      expect(vm.quantityOf('c2'), 1);
      expect(vm.slots.map((s) => s.dice.id), ['c1', 'c1', 'c2']);
    });

    test('loadInitial drops unknown/deleted ids', () async {
      final management =
          await _loadedManagement([const DiceEntity.builtIn(), _custom('c1', 'D20')]);
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceIds: _FakeGetSelectedDiceIds(['c1', 'ghost']),
        setSelectedDiceIds: _FakeSetSelectedDiceIds(),
        rollDice: RollDice(random: Random(0)),
      );

      await vm.loadInitial();

      expect(vm.selectedCount, 1);
      expect(vm.slots.single.dice.id, 'c1');
    });

    test('loadInitial falls back to one built-in die when nothing resolves',
        () async {
      final management = await _loadedManagement([const DiceEntity.builtIn()]);
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceIds: _FakeGetSelectedDiceIds(const []),
        setSelectedDiceIds: _FakeSetSelectedDiceIds(),
        rollDice: RollDice(random: Random(0)),
      );

      await vm.loadInitial();

      expect(vm.selectedCount, 1);
      expect(vm.slots.single.dice.isBuiltIn, isTrue);
    });
  });

  group('DiceGameProvider — selection editing', () {
    late _FakeSetSelectedDiceIds setIds;
    late DiceGameProvider vm;

    Future<void> setUpGame({
      List<String> saved = const [],
      Size area = _bigArea,
    }) async {
      final management = await _loadedManagement([
        const DiceEntity.builtIn(),
        _custom('c1', 'D20'),
        _custom('c2', 'Coin'),
      ]);
      setIds = _FakeSetSelectedDiceIds();
      vm = DiceGameProvider(
        management: management,
        getSelectedDiceIds: _FakeGetSelectedDiceIds(saved),
        setSelectedDiceIds: setIds,
        rollDice: RollDice(random: Random(0)),
        random: Random(0),
      );
      await vm.loadInitial();
      vm.setAvailableArea(area);
    }

    test('increment adds a slot of that type and persists the id list',
        () async {
      await setUpGame();
      vm.increment(_custom('c1', 'D20'));
      expect(vm.quantityOf('c1'), 1);
      expect(vm.selectedCount, 2); // built-in + c1
      expect(setIds.lastSet, ['built-in', 'c1']);
    });

    test('increment is capped at maxDice', () async {
      // 250x150 -> floor(2.5) * floor(1.5) = 2 * 1 = 2 dice fit.
      await setUpGame(area: const Size(250, 150));
      expect(vm.maxDice, 2);
      expect(vm.selectedCount, 1); // built-in
      vm.increment(_custom('c1', 'D20'));
      expect(vm.selectedCount, 2);
      vm.increment(_custom('c2', 'Coin')); // would exceed the cap
      expect(vm.selectedCount, 2);
      expect(vm.quantityOf('c2'), 0);
    });

    test('decrement removes the last slot of that type and persists', () async {
      await setUpGame(saved: ['c1', 'c2', 'c1']);
      vm.decrement(_custom('c1', 'D20'));
      expect(vm.quantityOf('c1'), 1);
      expect(vm.slots.map((s) => s.dice.id), ['c1', 'c2']);
      expect(setIds.lastSet, ['c1', 'c2']);
    });

    test('decrement can empty the tray', () async {
      await setUpGame(); // single built-in
      vm.decrement(const DiceEntity.builtIn());
      expect(vm.selectedCount, 0);
      expect(vm.canRoll, isFalse);
      expect(setIds.lastSet, isEmpty);
    });

    test('decrement is a no-op for a type not in the tray', () async {
      await setUpGame(); // single built-in
      vm.decrement(_custom('c1', 'D20'));
      expect(vm.selectedCount, 1);
    });

    test('resetToDefault clears to a single unlocked built-in die', () async {
      await setUpGame(saved: ['c1', 'c2']);
      vm.toggleLock(vm.slots.first.slotId);
      vm.resetToDefault();
      expect(vm.selectedCount, 1);
      expect(vm.slots.single.dice.isBuiltIn, isTrue);
      expect(vm.slots.single.locked, isFalse);
      expect(setIds.lastSet, ['built-in']);
    });
  });

  group('DiceGameProvider — locking', () {
    late DiceGameProvider vm;

    Future<void> setUpTray(List<String> saved) async {
      final management = await _loadedManagement([
        const DiceEntity.builtIn(),
        _custom('c1', 'D20'),
        _custom('c2', 'Coin'),
      ]);
      vm = DiceGameProvider(
        management: management,
        getSelectedDiceIds: _FakeGetSelectedDiceIds(saved),
        setSelectedDiceIds: _FakeSetSelectedDiceIds(),
        rollDice: RollDice(random: Random(0)),
        random: Random(0),
      );
      await vm.loadInitial();
      vm.setAvailableArea(_bigArea);
    }

    test('rollAll rolls only unlocked slots', () async {
      await setUpTray(['c1', 'c2']);
      final locked = vm.slots[0];
      final free = vm.slots[1];
      vm.toggleLock(locked.slotId);

      vm.rollAll();

      expect(locked.isRolling, isFalse);
      expect(free.isRolling, isTrue);
      expect(vm.isRolling, isTrue);
    });

    test('rollAll is a no-op when every slot is locked', () async {
      await setUpTray(['c1', 'c2']);
      for (final slot in vm.slots) {
        vm.toggleLock(slot.slotId);
      }
      expect(vm.canRoll, isFalse);

      vm.rollAll();

      expect(vm.isRolling, isFalse);
    });

    test('toggleLock flips the flag and notifies', () async {
      await setUpTray(['c1']);
      var notifications = 0;
      vm.addListener(() => notifications++);
      final id = vm.slots.single.slotId;

      vm.toggleLock(id);
      expect(vm.slots.single.locked, isTrue);
      vm.toggleLock(id);
      expect(vm.slots.single.locked, isFalse);
      expect(notifications, 2);
    });
  });

  group('DiceGameProvider — setAvailableArea', () {
    test('recomputes maxDice and notifies only when it changes', () async {
      final management = await _loadedManagement([const DiceEntity.builtIn()]);
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceIds: _FakeGetSelectedDiceIds(const []),
        setSelectedDiceIds: _FakeSetSelectedDiceIds(),
        rollDice: RollDice(random: Random(0)),
      );
      await vm.loadInitial();
      var notifications = 0;
      vm.addListener(() => notifications++);

      vm.setAvailableArea(_bigArea);
      expect(vm.maxDice, 100);
      expect(notifications, 1);

      // Same effective maxDice -> no extra notification.
      vm.setAvailableArea(_bigArea);
      expect(notifications, 1);
    });

    test('trims overflow from the end and persists when maxDice shrinks',
        () async {
      final management = await _loadedManagement([
        const DiceEntity.builtIn(),
        _custom('c1', 'D20'),
        _custom('c2', 'Coin'),
      ]);
      final setIds = _FakeSetSelectedDiceIds();
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceIds: _FakeGetSelectedDiceIds(['c1', 'c2', 'c1']),
        setSelectedDiceIds: setIds,
        rollDice: RollDice(random: Random(0)),
      );
      await vm.loadInitial();
      vm.setAvailableArea(_bigArea);
      expect(vm.selectedCount, 3);

      // 150x150 -> 1 die fits.
      vm.setAvailableArea(const Size(150, 150));
      expect(vm.maxDice, 1);
      expect(vm.selectedCount, 1);
      expect(vm.slots.single.dice.id, 'c1'); // kept from the front
      expect(setIds.lastSet, ['c1']);
    });

    test('caps at the orientation-stable max so rotation never trims',
        () async {
      final dice = [
        const DiceEntity.builtIn(),
        for (var i = 0; i < 8; i++) _custom('c$i', 'C$i'),
      ];
      final management = await _loadedManagement(dice);
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceIds: _FakeGetSelectedDiceIds(
          ['c0', 'c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7'], // 8 dice
        ),
        setSelectedDiceIds: _FakeSetSelectedDiceIds(),
        rollDice: RollDice(random: Random(0)),
      );
      await vm.loadInitial();
      expect(vm.selectedCount, 8);

      // Portrait: roll area 400x592 of a 400x800 screen fits 20 here, but only
      // 8 in landscape, so the stable cap is 8 — and 8 dice survive.
      vm.setAvailableArea(const Size(400, 592),
          screenSize: const Size(400, 800));
      expect(vm.maxDice, 8);
      expect(vm.selectedCount, 8);

      // Rotate to landscape (roll area 800x192 of an 800x400 screen): same cap,
      // nothing trimmed.
      vm.setAvailableArea(const Size(800, 192),
          screenSize: const Size(800, 400));
      expect(vm.maxDice, 8);
      expect(vm.selectedCount, 8);
    });
  });

  group('DiceGameProvider — refresh', () {
    test('drops slots whose dice was deleted, keeping survivors and locks',
        () async {
      final stub = _StubGetDiceList([
        const DiceEntity.builtIn(),
        _custom('c1', 'D20'),
        _custom('c2', 'Coin'),
      ]);
      final management = DiceManagementProvider(
        getDiceList: stub,
        saveDice: _NoopSaveDice(),
        deleteDice: _NoopDeleteDice(),
      );
      await management.load();
      final setIds = _FakeSetSelectedDiceIds();
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceIds: _FakeGetSelectedDiceIds(['c1', 'c2']),
        setSelectedDiceIds: setIds,
        rollDice: RollDice(random: Random(0)),
      );
      await vm.loadInitial();
      vm.setAvailableArea(_bigArea);
      vm.toggleLock(vm.slots.first.slotId); // lock the c1 slot

      // c2 is deleted from the source and the management list reloaded.
      stub.result = [const DiceEntity.builtIn(), _custom('c1', 'D20')];
      await management.load();
      await vm.refresh();

      expect(vm.selectedCount, 1);
      expect(vm.quantityOf('c2'), 0);
      expect(vm.slots.single.dice.id, 'c1');
      expect(vm.slots.single.locked, isTrue); // lock survived
      expect(setIds.lastSet, ['c1']);
    });

    test('falls back to a built-in die when every type was deleted', () async {
      final stub = _StubGetDiceList(
        [const DiceEntity.builtIn(), _custom('c1', 'D20')],
      );
      final management = DiceManagementProvider(
        getDiceList: stub,
        saveDice: _NoopSaveDice(),
        deleteDice: _NoopDeleteDice(),
      );
      await management.load();
      final setIds = _FakeSetSelectedDiceIds();
      final vm = DiceGameProvider(
        management: management,
        getSelectedDiceIds: _FakeGetSelectedDiceIds(['c1']),
        setSelectedDiceIds: setIds,
        rollDice: RollDice(random: Random(0)),
      );
      await vm.loadInitial();

      stub.result = [const DiceEntity.builtIn()];
      await management.load();
      await vm.refresh();

      expect(vm.selectedCount, 1);
      expect(vm.slots.single.dice.isBuiltIn, isTrue);
      expect(setIds.lastSet, ['built-in']);
    });
  });
}
