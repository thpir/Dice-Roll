import 'package:dice_roll/data/repositories/selected_dice_repository.dart';
import 'package:dice_roll/data/services/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds a repository backed by a [PreferencesService] over the mock store
/// seeded with [initial].
Future<SelectedDiceRepository> _repo(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = PreferencesService();
  await prefs.init();
  return SelectedDiceRepository(prefs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SelectedDiceRepository', () {
    test('returns an empty list when nothing has been stored', () async {
      final repo = await _repo({});
      expect(await repo.getIds(), isEmpty);
    });

    test('round-trips the stored id list, preserving order and repeats',
        () async {
      final repo = await _repo({});
      await repo.setIds(['a', 'a', 'b']);
      expect(await repo.getIds(), ['a', 'a', 'b']);
    });

    test('migrates a legacy single id into the new list and writes it forward',
        () async {
      SharedPreferences.setMockInitialValues({'selected_dice_id': 'c1'});
      final prefs = PreferencesService();
      await prefs.init();
      final repo = SelectedDiceRepository(prefs);

      // First read seeds the list from the legacy key.
      expect(await repo.getIds(), ['c1']);

      // The new key is now populated, so the migration is not repeated even if
      // the legacy value were to change.
      expect(prefs.getSelectedDiceIds(), ['c1']);
    });

    test('prefers the new list over the legacy id when both exist', () async {
      final repo = await _repo({
        'selected_dice_id': 'legacy',
        'selected_dice_ids': ['x', 'y'],
      });
      expect(await repo.getIds(), ['x', 'y']);
    });
  });
}
