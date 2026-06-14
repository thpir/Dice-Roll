import 'package:dice_roll/data/services/preferences_service.dart';
import 'package:dice_roll/domain/use_cases/get_selected_dice_ids.dart';
import 'package:dice_roll/domain/use_cases/set_selected_dice_ids.dart';

/// Backs the selected-dice-ids use cases via [PreferencesService].
class SelectedDiceRepository {
  final PreferencesService _prefs;

  SelectedDiceRepository(this._prefs);

  /// The persisted tray as an ordered id list.
  ///
  /// Transparently migrates pre-multi-dice installs: if the new list key is
  /// absent but the legacy single-id key exists, the list is seeded from that
  /// id and written forward so the legacy key is never consulted again.
  /// Returns an empty list when nothing has ever been stored.
  Future<List<String>> getIds() async {
    final ids = _prefs.getSelectedDiceIds();
    if (ids != null) {
      return ids;
    }
    final legacyId = _prefs.getSelectedDiceId();
    if (legacyId != null) {
      final migrated = [legacyId];
      await _prefs.setSelectedDiceIds(migrated);
      return migrated;
    }
    return const [];
  }

  Future<void> setIds(List<String> ids) => _prefs.setSelectedDiceIds(ids);
}

class GetSelectedDiceIdsImpl implements GetSelectedDiceIds {
  final SelectedDiceRepository _repository;
  GetSelectedDiceIdsImpl(this._repository);

  @override
  Future<List<String>> call() => _repository.getIds();
}

class SetSelectedDiceIdsImpl implements SetSelectedDiceIds {
  final SelectedDiceRepository _repository;
  SetSelectedDiceIdsImpl(this._repository);

  @override
  Future<void> call(List<String> ids) => _repository.setIds(ids);
}
