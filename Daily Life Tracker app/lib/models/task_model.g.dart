// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String? ?? '',
      title: fields[1] as String? ?? 'مهمة بدون عنوان',
      iconCodePoint: fields[2] as int? ?? 0xe876,
      isCompleted: fields[3] as bool? ?? false,
      category: fields[4] as String? ?? 'عام',
      reminderTimeString: fields[5] as String?,
      isRepeating: fields[6] as bool? ?? false,
      createdAt: fields[7] as DateTime? ?? DateTime.now(),
      priority: fields[8] as TaskPriority? ?? TaskPriority.medium,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.iconCodePoint)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.reminderTimeString)
      ..writeByte(6)
      ..write(obj.isRepeating)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
