// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PDFModelAdapter extends TypeAdapter<PDFModel> {
  @override
  final int typeId = 0;

  @override
  PDFModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PDFModel(
      pathFile: fields[0] as String?,
      timeOpen: fields[2] as DateTime?,
      currentIndex: fields[3] as int?,
      isOpen: fields[4] as bool?,
      isEdit: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, PDFModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.pathFile)
      ..writeByte(2)
      ..write(obj.timeOpen)
      ..writeByte(3)
      ..write(obj.currentIndex)
      ..writeByte(4)
      ..write(obj.isOpen)
      ..writeByte(5)
      ..write(obj.isEdit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PDFModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
