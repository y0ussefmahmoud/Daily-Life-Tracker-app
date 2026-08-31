// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../models/water_log_model.dart';
import '../models/prayer_log.dart';

Future<void> registerHiveAdapters() async {
  // Register all Hive adapters
  // TODO: TaskAdapter and SubtaskAdapter need code generation with Hive annotations
  // Commented out until new models are properly annotated
  // if (!Hive.isAdapterRegistered(0)) {
  //   Hive.registerAdapter(TaskAdapter());
  // }
  // TODO: ProjectAdapter needs code generation with Hive annotations
  // Commented out until Project model is properly annotated
  // if (!Hive.isAdapterRegistered(1)) {
  //   Hive.registerAdapter(ProjectAdapter());
  // }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(PrayerLogAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(WaterLogAdapter());
  }
  // if (!Hive.isAdapterRegistered(2)) {
  //   Hive.registerAdapter(SubtaskAdapter());
  // }
  
  // Register enum adapters manually
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(TaskPriorityAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(ProjectStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(PrayerTypeAdapter());
  }
}

// Manual enum adapters
class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 4;

  @override
  TaskPriority read(BinaryReader reader) {
    final index = reader.readByte();
    return TaskPriority.values[index];
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    writer.writeByte(obj.index);
  }
}

class ProjectStatusAdapter extends TypeAdapter<ProjectStatus> {
  @override
  final int typeId = 5;

  @override
  ProjectStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return ProjectStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, ProjectStatus obj) {
    writer.writeByte(obj.index);
  }
}

class PrayerTypeAdapter extends TypeAdapter<PrayerType> {
  @override
  final int typeId = 6;

  @override
  PrayerType read(BinaryReader reader) {
    final index = reader.readByte();
    return PrayerType.values[index];
  }

  @override
  void write(BinaryWriter writer, PrayerType obj) {
    writer.writeByte(obj.index);
  }
}

class PrayerLogAdapter extends TypeAdapter<PrayerLog> {
  @override
  final int typeId = 2;

  @override
  PrayerLog read(BinaryReader reader) {
    return PrayerLog(
      id: reader.readString(),
      type: reader.read() as PrayerType,
      date: reader.read() as DateTime,
      isCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, PrayerLog obj) {
    writer.writeString(obj.id);
    writer.write(obj.type);
    writer.write(obj.date);
    writer.writeBool(obj.isCompleted);
  }
}

class WaterLogAdapter extends TypeAdapter<WaterLog> {
  @override
  final int typeId = 3;

  @override
  WaterLog read(BinaryReader reader) {
    return WaterLog(
      id: reader.readString(),
      amount: reader.readInt(),
      date: reader.read() as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WaterLog obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.amount);
    writer.write(obj.date);
  }
}
