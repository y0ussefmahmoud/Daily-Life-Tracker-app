// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../services/local_database_service.dart';
import 'backup_json_converters.dart';
import 'backup_validators.dart';

/// Service for exporting and importing application data in JSON format.
/// Handles schema validation and data transformation for backup/restore operations.
class BackupService {
  static const String _currentVersion = '2.4.0';
  final LocalDatabaseService _db = LocalDatabaseService();
  final Uuid _uuid = const Uuid();
  final BackupJsonConverters _converters = BackupJsonConverters();
  final BackupValidators _validators = BackupValidators();

  /// Exports all user data to a JSON string following the backup schema.
  /// 
  /// Returns a JSON string containing:
  /// - version: Schema version identifier
  /// - exported_at: ISO8601 timestamp of export
  /// - user_id: Generated UUID for the user
  /// - data: Object containing profile, tasks, projects, subtasks, and settings
  /// 
  /// Throws [Exception] if data export fails.
  Future<String> exportData() async {
    try {
      final backup = {
        'version': _currentVersion,
        'exported_at': DateTime.now().toIso8601String(),
        'user_id': _uuid.v4(),
        'data': {
          'profile': await _exportProfile(),
          'tasks': await _exportTasks(),
          'projects': await _exportProjects(),
          'subtasks': await _exportSubtasks(),
          'settings': await _exportSettings(),
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      return jsonString;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Imports data from a JSON string and validates schema compatibility.
  /// 
  /// Parameters:
  /// - jsonString: JSON string containing backup data
  /// 
  /// Performs schema version validation before import.
  /// Clears existing data and imports from backup using upsert logic.
  /// 
  /// Throws [Exception] if:
  /// - JSON parsing fails
  /// - Schema validation fails
  /// - Data import fails
  Future<void> importData(String jsonString) async {
    try {
      final backup = jsonDecode(jsonString) as Map<String, dynamic>;
      
      if (!_validators.validateBackupFormat(backup)) {
        throw Exception('Invalid backup format');
      }

      final data = backup['data'] as Map<String, dynamic>;
      
      await _importSettings(data['settings'] as Map<String, dynamic>?);
      await _importTasks(data['tasks'] as List<dynamic>?);
      await _importProjects(data['projects'] as List<dynamic>?);
      await _importSubtasks(data['subtasks'] as List<dynamic>?);
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Exports user profile data from settings.
  Future<Map<String, dynamic>> _exportProfile() async {
    final settings = await _db.getSettings();
    return {
      'user_level': settings['user_level'] ?? {},
      'total_xp': settings['total_xp'] ?? 0,
      'current_level': settings['current_level'] ?? 1,
    };
  }

  /// Exports all tasks to JSON-serializable format.
  Future<List<Map<String, dynamic>>> _exportTasks() async {
    final tasks = await _db.getAllTasks();
    return tasks.map((task) => _converters.taskToJson(task)).toList();
  }

  /// Exports all projects to JSON-serializable format.
  Future<List<Map<String, dynamic>>> _exportProjects() async {
    final projects = await _db.getAllProjects();
    return projects.map((project) => _converters.projectToJson(project)).toList();
  }

  /// Exports all subtasks to JSON-serializable format.
  Future<List<Map<String, dynamic>>> _exportSubtasks() async {
    final subtasks = await _db.getAllSubtasks();
    return subtasks.map((subtask) => _converters.subtaskToJson(subtask)).toList();
  }

  /// Exports application settings.
  Future<Map<String, dynamic>> _exportSettings() async {
    return await _db.getSettings();
  }

  /// Imports settings data.
  Future<void> _importSettings(Map<String, dynamic>? settings) async {
    if (settings == null) return;
    
    for (final entry in settings.entries) {
      await _db.setSetting(entry.key, entry.value);
    }
  }

  /// Imports tasks data using upsert logic.
  Future<void> _importTasks(List<dynamic>? tasksData) async {
    if (tasksData == null) return;
    
    for (final taskData in tasksData) {
      final task = _converters.taskFromJson(taskData as Map<String, dynamic>);
      await _db.updateTask(task);
    }
  }

  /// Imports projects data using upsert logic.
  Future<void> _importProjects(List<dynamic>? projectsData) async {
    if (projectsData == null) return;
    
    for (final projectData in projectsData) {
      final project = _converters.projectFromJson(projectData as Map<String, dynamic>);
      await _db.updateProject(project);
    }
  }

  /// Imports subtasks data using upsert logic.
  Future<void> _importSubtasks(List<dynamic>? subtasksData) async {
    if (subtasksData == null) return;
    
    for (final subtaskData in subtasksData) {
      final subtask = _converters.subtaskFromJson(subtaskData as Map<String, dynamic>);
      await _db.updateSubtask(subtask);
    }
  }
}
