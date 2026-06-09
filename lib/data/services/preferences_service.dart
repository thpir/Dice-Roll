import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight wrapper around [SharedPreferences] for the few simple values
/// the app needs to persist outside of Hive.
class PreferencesService {
  static const _selectedDiceIdKey = 'selected_dice_id';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _required {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('PreferencesService.init() must be awaited before use.');
    }
    return prefs;
  }

  String? getSelectedDiceId() => _required.getString(_selectedDiceIdKey);

  Future<void> setSelectedDiceId(String id) async {
    await _required.setString(_selectedDiceIdKey, id);
  }
}
