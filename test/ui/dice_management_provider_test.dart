import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:dice_roll/domain/use_cases/delete_dice.dart';
import 'package:dice_roll/domain/use_cases/dice_validation.dart';
import 'package:dice_roll/domain/use_cases/get_dice_list.dart';
import 'package:dice_roll/domain/use_cases/save_dice.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:flutter_test/flutter_test.dart';

DiceEntity _custom(String id, String title) => DiceEntity(
      id: id,
      title: title,
      faces: const [
        DiceFaceEntity(id: 'a', order: 0, backgroundColor: 0xFF000000),
        DiceFaceEntity(id: 'b', order: 1, backgroundColor: 0xFFFFFFFF),
      ],
    );

class _FakeGetDiceList implements GetDiceList {
  List<DiceEntity> result;
  var callCount = 0;

  _FakeGetDiceList(this.result);

  @override
  Future<List<DiceEntity>> call() async {
    callCount++;
    return result;
  }
}

class _FakeSaveDice implements SaveDice {
  DiceEntity? saved;
  DiceValidationException? throwOnCall;

  @override
  Future<void> call(DiceEntity dice) async {
    if (throwOnCall != null) {
      throw throwOnCall!;
    }
    saved = dice;
  }
}

class _FakeDeleteDice implements DeleteDice {
  String? deletedId;

  @override
  Future<void> call(String id) async {
    deletedId = id;
  }
}

void main() {
  group('DiceManagementProvider', () {
    late _FakeGetDiceList getDiceList;
    late _FakeSaveDice saveDice;
    late _FakeDeleteDice deleteDice;

    DiceManagementProvider build() => DiceManagementProvider(
          getDiceList: getDiceList,
          saveDice: saveDice,
          deleteDice: deleteDice,
        );

    setUp(() {
      getDiceList = _FakeGetDiceList([
        const DiceEntity.builtIn(),
        _custom('c1', 'Coin'),
      ]);
      saveDice = _FakeSaveDice();
      deleteDice = _FakeDeleteDice();
    });

    test('starts loading and not populated', () {
      final vm = build();
      expect(vm.isLoading, isTrue);
      expect(vm.dice, isEmpty);
    });

    test('load populates the in-memory list and clears loading', () async {
      final vm = build();
      await vm.load();
      expect(vm.isLoading, isFalse);
      expect(vm.dice.map((d) => d.id), ['built-in', 'c1']);
    });

    test('diceById resolves from the loaded list, null when unknown', () async {
      final vm = build();
      await vm.load();
      expect(vm.diceById('c1')?.title, 'Coin');
      expect(vm.diceById('built-in')?.isBuiltIn, isTrue);
      expect(vm.diceById('missing'), isNull);
    });

    test('save delegates to SaveDice then reloads the list', () async {
      final vm = build();
      await vm.load();
      final before = getDiceList.callCount;

      await vm.save(_custom('c2', 'D20'));

      expect(saveDice.saved?.id, 'c2');
      expect(getDiceList.callCount, before + 1);
    });

    test('save propagates DiceValidationException without reloading', () async {
      final vm = build();
      await vm.load();
      final before = getDiceList.callCount;
      saveDice.throwOnCall = const DiceValidationException('bad');

      await expectLater(
        vm.save(_custom('c2', '')),
        throwsA(isA<DiceValidationException>()),
      );
      expect(getDiceList.callCount, before);
    });

    test('delete delegates to DeleteDice then reloads the list', () async {
      final vm = build();
      await vm.load();
      final before = getDiceList.callCount;

      await vm.delete('c1');

      expect(deleteDice.deletedId, 'c1');
      expect(getDiceList.callCount, before + 1);
    });
  });
}
