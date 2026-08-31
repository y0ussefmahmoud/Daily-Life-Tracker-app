// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import '../models/task_model.dart';
import '../models/project_model.dart';
import '../models/subtask_model.dart';

/// Handles JSON serialization and deserialization for backup data models.
/// Provides conversion methods for TaskModel, Project, and SubtaskModel entities.
class BackupJsonConverters {
  /// Converts TaskModel object to JSON-serializable map.
  Map<String, dynamic> taskToJson(TaskModel task) {
    return task.toMap();
  }

  /// Converts JSON map to TaskModel object.
  TaskModel taskFromJson(Map<String, dynamic> json) {
    return TaskModel.fromMap(json);
  }

  /// Converts Project object to JSON-serializable map.
  Map<String, dynamic> projectToJson(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'progress': project.progress,
      'techStack': project.techStack,
      'weeklyHours': project.weeklyHours,
      'status': project.status.name,
      'deadline': project.deadline?.toIso8601String(),
      'statusMessage': project.statusMessage,
      'weeklyFocus': project.weeklyFocus,
      'startDate': project.startDate?.toIso8601String(),
      'endDate': project.endDate?.toIso8601String(),
      'createdAt': project.createdAt.toIso8601String(),
    };
  }

  /// Converts JSON map to Project object.
  Project projectFromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Project',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      techStack: json['techStack'] != null 
          ? List<String>.from(json['techStack'] as List) 
          : [],
      weeklyHours: json['weeklyHours'] as int? ?? 40,
      status: ProjectStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ProjectStatus.active,
      ),
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline'] as String) 
          : null,
      statusMessage: json['statusMessage'] as String?,
      weeklyFocus: json['weeklyFocus'] as String?,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String) 
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      category: json['category'] as String? ?? 'uncategorized',
      totalHoursSpent: json['totalHoursSpent'] as int? ?? 0,
      priority: json['priority'] as int? ?? 3,
      description: json['description'] as String?,
    );
  }

  /// Converts SubtaskModel object to JSON-serializable map.
  Map<String, dynamic> subtaskToJson(SubtaskModel subtask) {
    return subtask.toMap();
  }

  /// Converts JSON map to SubtaskModel object.
  SubtaskModel subtaskFromJson(Map<String, dynamic> json) {
    return SubtaskModel.fromMap(json);
  }
}
