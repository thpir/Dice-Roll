import 'package:dice_roll/domain/models/dice_face_entity.dart';

/// A dice. The built-in 1–6 dice has [isBuiltIn] `true` and a fixed [id]
/// of [DiceEntity.builtInId]; it is never persisted to the database.
class DiceEntity {
  static const builtInId = 'built-in';

  final String id;
  final String title;
  final List<DiceFaceEntity> faces;
  final bool isBuiltIn;

  const DiceEntity({
    required this.id,
    required this.title,
    required this.faces,
    this.isBuiltIn = false,
  });

  /// The default 6-face dice. Mirrors the legacy hardcoded images and colours.
  const DiceEntity.builtIn()
      : id = builtInId,
        title = 'Default',
        faces = _builtInFaces,
        isBuiltIn = true;

  DiceEntity copyWith({
    String? id,
    String? title,
    List<DiceFaceEntity>? faces,
    bool? isBuiltIn,
  }) {
    return DiceEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      faces: faces ?? this.faces,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }
}

const _builtInFaces = <DiceFaceEntity>[
  DiceFaceEntity(
    id: 'built-in-face-1',
    order: 0,
    backgroundColor: 0xFFF44336,
    imagePath: 'assets/images/1.png',
  ),
  DiceFaceEntity(
    id: 'built-in-face-2',
    order: 1,
    backgroundColor: 0xFF2196F3,
    imagePath: 'assets/images/2.png',
  ),
  DiceFaceEntity(
    id: 'built-in-face-3',
    order: 2,
    backgroundColor: 0xFF4CAF50,
    imagePath: 'assets/images/3.png',
  ),
  DiceFaceEntity(
    id: 'built-in-face-4',
    order: 3,
    backgroundColor: 0xFFFFEB3B,
    imagePath: 'assets/images/4.png',
  ),
  DiceFaceEntity(
    id: 'built-in-face-5',
    order: 4,
    backgroundColor: 0xFFFF9800,
    imagePath: 'assets/images/5.png',
  ),
  DiceFaceEntity(
    id: 'built-in-face-6',
    order: 5,
    backgroundColor: 0xFF9C27B0,
    imagePath: 'assets/images/6.png',
  ),
];
