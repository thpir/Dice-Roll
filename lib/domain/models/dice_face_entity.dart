/// A single face of a dice.
///
/// - [backgroundColor] always renders; it shows when no background image is
///   set or when the image fails to load.
/// - [backgroundImagePath] is optional; when present it is drawn over the
///   colour with `BoxFit.cover`.
/// - [imagePath] is the foreground graphic; rendered centred over the
///   background.
///
/// Image paths may be asset paths (e.g. `assets/images/1.png`) for the
/// built-in dice or relative paths inside the app's image storage directory
/// for custom dice.
class DiceFaceEntity {
  final String id;
  final int order;
  final int backgroundColor;
  final String? backgroundImagePath;
  final String? imagePath;

  const DiceFaceEntity({
    required this.id,
    required this.order,
    required this.backgroundColor,
    this.backgroundImagePath,
    this.imagePath,
  });

  DiceFaceEntity copyWith({
    String? id,
    int? order,
    int? backgroundColor,
    String? backgroundImagePath,
    bool clearBackgroundImagePath = false,
    String? imagePath,
    bool clearImagePath = false,
  }) {
    return DiceFaceEntity(
      id: id ?? this.id,
      order: order ?? this.order,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImagePath: clearBackgroundImagePath
          ? null
          : (backgroundImagePath ?? this.backgroundImagePath),
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DiceFaceEntity &&
        other.id == id &&
        other.order == order &&
        other.backgroundColor == backgroundColor &&
        other.backgroundImagePath == backgroundImagePath &&
        other.imagePath == imagePath;
  }

  @override
  int get hashCode => Object.hash(
        id,
        order,
        backgroundColor,
        backgroundImagePath,
        imagePath,
      );
}
