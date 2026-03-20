import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../models/subtask_model.dart';
import '../models/water_log_model.dart';

Future<void> registerHiveAdapters() async {
  // Register all Hive adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ProjectAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(SubtaskAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(WaterLogAdapter());
  }
  
  // Register enum adapters manually
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(TaskPriorityAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(ProjectStatusAdapter());
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
