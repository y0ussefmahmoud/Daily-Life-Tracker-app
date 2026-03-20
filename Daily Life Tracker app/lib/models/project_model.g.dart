// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 1;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String? ?? '',
      name: fields[1] as String? ?? 'مشروع بدون اسم',
      progress: (fields[2] as num?)?.toDouble() ?? 0.0,
      techStack: fields[3] != null ? List<String>.from(fields[3] as List) : [],
      weeklyHours: fields[4] as int? ?? 40,
      status: fields[5] as ProjectStatus? ?? ProjectStatus.active,
      deadline: fields[6] as DateTime?,
      statusMessage: fields[7] as String?,
      weeklyFocus: fields[8] as String?,
      startDate: fields[9] as DateTime?,
      endDate: fields[10] as DateTime?,
      subtasks: fields[11] != null ? (fields[11] as List).cast<Subtask>() : [],
      createdAt: fields[12] as DateTime? ?? DateTime.now(),
      category: fields[13] as String? ?? 'غير محدد',
      totalHoursSpent: fields[14] as int? ?? 0,
      priority: fields[15] as int? ?? 3,
      description: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.progress)
      ..writeByte(3)
      ..write(obj.techStack)
      ..writeByte(4)
      ..write(obj.weeklyHours)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.deadline)
      ..writeByte(7)
      ..write(obj.statusMessage)
      ..writeByte(8)
      ..write(obj.weeklyFocus)
      ..writeByte(9)
      ..write(obj.startDate)
      ..writeByte(10)
      ..write(obj.endDate)
      ..writeByte(11)
      ..write(obj.subtasks)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.category)
      ..writeByte(14)
      ..write(obj.totalHoursSpent)
      ..writeByte(15)
      ..write(obj.priority)
      ..writeByte(16)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
