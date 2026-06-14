import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight wrapper around [SharedPreferences] for the few simple values
/// the app needs to persist outside of Hive.
class PreferencesService {
  /// Legacy single-selection key. Still read so the tray can be seeded from a
  /// pre-multi-dice install on first launch after the upgrade; never written.
  static const _selectedDiceIdKey = 'selected_dice_id';

  /// Current key: the ordered list of dice ids in the tray (quantities encoded
  /// by repetition).
  static const _selectedDiceIdsKey = 'selected_dice_ids';

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

  /// Legacy single-id read, kept for one release to migrate existing installs.
  String? getSelectedDiceId() => _required.getString(_selectedDiceIdKey);

  /// The persisted tray, or `null` when nothing has been stored yet.
  List<String>? getSelectedDiceIds() =>
      _required.getStringList(_selectedDiceIdsKey);

  Future<void> setSelectedDiceIds(List<String> ids) async {
    await _required.setStringList(_selectedDiceIdsKey, ids);
  }
}
