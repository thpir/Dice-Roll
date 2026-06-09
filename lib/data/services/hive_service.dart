import 'package:dice_roll/data/models/dice_db_model.dart';
import 'package:dice_roll/data/models/dice_face_db_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Owns the lifecycle of the Hive backing store. Call [init] once from
/// `main()` before constructing repositories.
class HiveService {
  static const dicesBoxName = 'dices';

  Box<DiceDbModel>? _dicesBox;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DiceDbModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DiceFaceDbModelAdapter());
    }
    _dicesBox = await Hive.openBox<DiceDbModel>(dicesBoxName);
  }

  Box<DiceDbModel> get dicesBox {
    final box = _dicesBox;
    if (box == null) {
      throw StateError('HiveService.init() must be awaited before use.');
    }
    return box;
  }

  Future<void> close() async {
    await _dicesBox?.close();
    _dicesBox = null;
  }
}
