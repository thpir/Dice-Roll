import 'package:dice_roll/domain/models/dice_face_entity.dart';
import 'package:hive/hive.dart';

part 'dice_face_db_model.g.dart';

@HiveType(typeId: 1)
class DiceFaceDbModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int order;

  @HiveField(2)
  final int backgroundColor;

  @HiveField(3)
  final String? imagePath;

  @HiveField(4)
  final String? backgroundImagePath;

  DiceFaceDbModel({
    required this.id,
    required this.order,
    required this.backgroundColor,
    this.imagePath,
    this.backgroundImagePath,
  });

  factory DiceFaceDbModel.fromDomain(DiceFaceEntity face) {
    return DiceFaceDbModel(
      id: face.id,
      order: face.order,
      backgroundColor: face.backgroundColor,
      imagePath: face.imagePath,
      backgroundImagePath: face.backgroundImagePath,
    );
  }

  DiceFaceEntity toDomain() {
    return DiceFaceEntity(
      id: id,
      order: order,
      backgroundColor: backgroundColor,
      imagePath: imagePath,
      backgroundImagePath: backgroundImagePath,
    );
  }
}
