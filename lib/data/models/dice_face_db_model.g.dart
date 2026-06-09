// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dice_face_db_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiceFaceDbModelAdapter extends TypeAdapter<DiceFaceDbModel> {
  @override
  final int typeId = 1;

  @override
  DiceFaceDbModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiceFaceDbModel(
      id: fields[0] as String,
      order: fields[1] as int,
      backgroundColor: fields[2] as int,
      imagePath: fields[3] as String?,
      backgroundImagePath: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DiceFaceDbModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.order)
      ..writeByte(2)
      ..write(obj.backgroundColor)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.backgroundImagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiceFaceDbModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
