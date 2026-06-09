import 'package:dice_roll/data/services/preferences_service.dart';
import 'package:dice_roll/domain/use_cases/get_selected_dice_id.dart';
import 'package:dice_roll/domain/use_cases/set_selected_dice_id.dart';

/// Backs the selected-dice-id use cases via [PreferencesService].
class SelectedDiceRepository {
  final PreferencesService _prefs;

  SelectedDiceRepository(this._prefs);

  Future<String?> get() async => _prefs.getSelectedDiceId();
  Future<void> set(String id) => _prefs.setSelectedDiceId(id);
}

class GetSelectedDiceIdImpl implements GetSelectedDiceId {
  final SelectedDiceRepository _repository;
  GetSelectedDiceIdImpl(this._repository);

  @override
  Future<String?> call() => _repository.get();
}

class SetSelectedDiceIdImpl implements SetSelectedDiceId {
  final SelectedDiceRepository _repository;
  SetSelectedDiceIdImpl(this._repository);

  @override
  Future<void> call(String id) => _repository.set(id);
}
