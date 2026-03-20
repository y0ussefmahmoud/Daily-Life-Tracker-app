// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerLogAdapter extends TypeAdapter<PrayerLog> {
  @override
  final int typeId = 2;

  @override
  PrayerLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerLog(
      id: fields[0] as String,
      type: fields[1] as PrayerType,
      date: fields[2] as DateTime,
      isCompleted: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
