import 'package:dice_roll/data/models/dice_face_db_model.dart';
import 'package:dice_roll/domain/models/dice_entity.dart';
import 'package:hive/hive.dart';

part 'dice_db_model.g.dart';

@HiveType(typeId: 0)
class DiceDbModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<DiceFaceDbModel> faces;

  DiceDbModel({
    required this.id,
    required this.title,
    required this.faces,
  });

  factory DiceDbModel.fromDomain(DiceEntity dice) {
    return DiceDbModel(
      id: dice.id,
      title: dice.title,
      faces: dice.faces.map(DiceFaceDbModel.fromDomain).toList(),
    );
  }

  DiceEntity toDomain() {
    final sortedFaces = [...faces]..sort((a, b) => a.order.compareTo(b.order));
    return DiceEntity(
      id: id,
      title: title,
      faces: sortedFaces.map((f) => f.toDomain()).toList(),
    );
  }
}
