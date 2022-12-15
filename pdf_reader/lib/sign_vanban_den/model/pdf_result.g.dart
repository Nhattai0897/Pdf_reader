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
      urlLink: fields[6] as String?,
      currentIndex: fields[3] as int?,
      isOpen: fields[4] as bool?,
      isEdit: fields[5] as bool?,
      isNew: fields[10] as bool?,
      propress: fields[7] as double?,
      isDownloadSuccess: fields[8] as String?,
      status: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PDFModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.pathFile)
      ..writeByte(2)
      ..write(obj.timeOpen)
      ..writeByte(3)
      ..write(obj.currentIndex)
      ..writeByte(4)
      ..write(obj.isOpen)
      ..writeByte(5)
      ..write(obj.isEdit)
      ..writeByte(6)
      ..write(obj.urlLink)
      ..writeByte(7)
      ..write(obj.propress)
      ..writeByte(8)
      ..write(obj.isDownloadSuccess)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.isNew);
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
