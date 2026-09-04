// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

// ignore_for_file: await_only_futures, unused_local_variable, unused_import, constant_identifier_names

import 'dart:convert';
import 'dart:developer'; // Added import for debugPrint
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:file_picker/file_picker.dart';  // DISABLED - Samsung A55 compatibility
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../models/subtask_model.dart';
import '../models/user_level_model.dart';
import '../models/water_log_model.dart';
import 'hive_adapters.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  late Box<String> taskBox; // Store as JSON strings
  late Box<String> projectBox; // Store as JSON strings
  late Box<String> subtaskBox; // Store as JSON strings
  late Box<WaterLog> waterLogBox;
  late Box settingsBox;

  static const String TASK_BOX_NAME = 'tasks';
  static const String PROJECT_BOX_NAME = 'projects';
  static const String SUBTASK_BOX_NAME = 'subtasks';
  static const String WATER_LOG_BOX_NAME = 'water_logs';
  static const String SETTINGS_BOX_NAME = 'settings';

  Future<void>? _initFuture;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;
    _initFuture ??= _initializeInternal().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _initFuture = null;
        throw Exception('Database initialization timeout');
      },
    );
    try {
      await _initFuture!;
    } catch (e) {
      _initFuture = null;
      rethrow;
    }
  }
  
  Future<void> _initializeInternal() async {
    if (_isInitialized) return;
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    
    // Register adapters
    await registerHiveAdapters();
    
    // Open boxes
    taskBox = await Hive.openBox<String>(TASK_BOX_NAME);
    projectBox = await Hive.openBox<String>(PROJECT_BOX_NAME);
    subtaskBox = await Hive.openBox<String>(SUBTASK_BOX_NAME);
    waterLogBox = await Hive.openBox<WaterLog>(WATER_LOG_BOX_NAME);
    settingsBox = await Hive.openBox(SETTINGS_BOX_NAME);
    
    // Check database version and migrate if needed
    await _migrateDatabaseIfNeeded();
    
    _isInitialized = true;
    debugPrint('Database initialized successfully');
  }

  Future<void> _migrateDatabaseIfNeeded() async {
    const String DB_VERSION_KEY = 'db_version';
    const String CURRENT_DB_VERSION = '2.4.2';
    
    final rawSettings = settingsBox.get('settings');
    final settings = _safeMapCast(rawSettings) ?? <String, dynamic>{};
    final currentVersion = settings[DB_VERSION_KEY] as String?;
    
    if (currentVersion == null) {
      // First time installation
      settings[DB_VERSION_KEY] = CURRENT_DB_VERSION;
      await settingsBox.put('settings', settings);
      debugPrint('First time installation, set database version to $CURRENT_DB_VERSION');
    } else if (currentVersion != CURRENT_DB_VERSION) {
      // Migration needed
      debugPrint('Migrating database from version $currentVersion to $CURRENT_DB_VERSION');
      await _migrateFromVersion(currentVersion);
      settings[DB_VERSION_KEY] = CURRENT_DB_VERSION;
      await settingsBox.put('settings', settings);
      debugPrint('Database migration completed to version $CURRENT_DB_VERSION');
    } else {
      debugPrint('Database is already at version $CURRENT_DB_VERSION');
    }
  }

  Future<void> _migrateFromVersion(String? fromVersion) async {
    // Add migration logic here for future versions
    // For now, just update the version as the data structure is compatible
    
    // Example migration for future versions:
    // if (fromVersion == '2.3.0') {
    //   await _migrateFrom230To240();
    // }
    
    debugPrint('Migration from $fromVersion completed (no structural changes needed)');
  }

  Future<void> initialize() async {
    await init();
  }

  bool isWaterLogBoxInitialized() {
    try {
      return waterLogBox.isOpen;
    } catch (e) {
      return false;
    }
  }

  // Task operations
  Future<void> addTask(TaskModel task) async {
    await taskBox.put(task.id, jsonEncode(task.toMap()));
  }

  Future<void> updateTask(TaskModel task) async {
    await taskBox.put(task.id, jsonEncode(task.toMap()));
  }

  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }

  Future<List<TaskModel>> getAllTasks() async {
    return taskBox.values.map((jsonStr) => TaskModel.fromMap(jsonDecode(jsonStr))).toList();
  }

  List<TaskModel> getCompletedTasks() {
    return taskBox.values.map((jsonStr) => TaskModel.fromMap(jsonDecode(jsonStr))).where((task) => task.isCompleted).toList();
  }

  List<TaskModel> getPendingTasks() {
    return taskBox.values.map((jsonStr) => TaskModel.fromMap(jsonDecode(jsonStr))).where((task) => !task.isCompleted).toList();
  }

  // Project operations - using JSON serialization
  Future<Project?> getProject(String id) async {
    final jsonStr = projectBox.get(id);
    if (jsonStr == null) return null;
    return _projectFromJson(jsonDecode(jsonStr));
  }

  Future<List<Project>> getAllProjects() async {
    return projectBox.values.map((jsonStr) => _projectFromJson(jsonDecode(jsonStr))).toList();
  }

  Future<List<Project>> getActiveProjects() async {
    return projectBox.values.map((jsonStr) => _projectFromJson(jsonDecode(jsonStr))).where((p) => p.status == ProjectStatus.active).toList();
  }

  Future<List<Project>> getCompletedProjects() async {
    return projectBox.values.map((jsonStr) => _projectFromJson(jsonDecode(jsonStr))).where((p) => p.status == ProjectStatus.completed).toList();
  }

  Future<void> updateProjectProgress(String projectId, double progress) async {
    try {
      final jsonStr = projectBox.get(projectId);
      if (jsonStr != null) {
        final project = _projectFromJson(jsonDecode(jsonStr));
        final updatedProject = project.copyWith(progress: progress);
        await projectBox.put(projectId, jsonEncode(_projectToJson(updatedProject)));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getOverallProjectProgress() async {
    final projects = await getAllProjects();
    if (projects.isEmpty) return 0.0;
    
    final totalProgress = projects.fold<double>(0, (sum, project) => sum + project.progress);
    return totalProgress / projects.length;
  }

  Future<void> updateProject(Project project) async {
    await projectBox.put(project.id, jsonEncode(_projectToJson(project)));
  }

  Future<void> addProject(Project project) async {
    await projectBox.put(project.id, jsonEncode(_projectToJson(project)));
  }

  Future<void> deleteProject(String id) async {
    await projectBox.delete(id);
    // Also delete related subtasks
    final subtasksToDelete = subtaskBox.values
        .map((jsonStr) => SubtaskModel.fromMap(jsonDecode(jsonStr)))
        .where((subtask) => subtask.taskId == id);
    for (final subtask in subtasksToDelete) {
      await subtaskBox.delete(subtask.id);
    }
  }

  // Subtask operations
  Future<void> addSubtask(SubtaskModel subtask) async {
    await subtaskBox.put(subtask.id, jsonEncode(subtask.toMap()));
  }

  Future<void> updateSubtask(SubtaskModel subtask) async {
    await subtaskBox.put(subtask.id, jsonEncode(subtask.toMap()));
  }

  Future<void> deleteSubtask(String id) async {
    await subtaskBox.delete(id);
  }

  Future<List<SubtaskModel>> getAllSubtasks() async {
    return subtaskBox.values.map((jsonStr) => SubtaskModel.fromMap(jsonDecode(jsonStr))).toList();
  }

  Future<List<SubtaskModel>> getSubtasksByTaskId(String taskId) async {
    return subtaskBox.values
        .map((jsonStr) => SubtaskModel.fromMap(jsonDecode(jsonStr)))
        .where((subtask) => subtask.taskId == taskId)
        .toList();
  }

  List<SubtaskModel> getCompletedSubtasks() {
    return subtaskBox.values.map((jsonStr) => SubtaskModel.fromMap(jsonDecode(jsonStr))).where((subtask) => subtask.isCompleted).toList();
  }

  // Settings operations
  Future<void> setSetting(String key, dynamic value) async {
    try {
      final currentSettings = await getSettings();
      currentSettings[key] = value;
      await settingsBox.put('settings', currentSettings);
    } catch (e) {
      throw Exception('Failed to save setting: $e');
    }
  }

  Future<void> removeSetting(String key) async {
    try {
      final currentSettings = await getSettings();
      currentSettings.remove(key);
      await settingsBox.put('settings', currentSettings);
    } catch (e) {
      throw Exception('Failed to remove setting: $e');
    }
  }

  Future<dynamic> getSetting(String key) async {
    try {
      final settings = await getSettings();
      return settings[key];
    } catch (e) {
      throw Exception('Failed to get setting: $e');
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final rawSettings = settingsBox.get('settings');
      return _safeMapCast(rawSettings) ?? <String, dynamic>{};
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  // Statistics
  int getTotalTasksCount() {
    return taskBox.length;
  }

  int getCompletedTasksCount() {
    return getCompletedTasks().length;
  }

  int getTotalProjectsCount() {
    return projectBox.length;
  }

  Future<int> getCompletedProjectsCount() async {
    final completedProjects = await getCompletedProjects();
    return completedProjects.length;
  }

  // Backup and Restore
  Future<Map<String, dynamic>> exportData() async {
    final backup = {
      'tasks': taskBox.values.map((jsonStr) => _taskFromJson(jsonDecode(jsonStr))).map((task) => _taskToJson(task)).toList(),
      'projects': projectBox.values.map((jsonStr) => _projectFromJson(jsonDecode(jsonStr))).map((project) => _projectToJson(project)).toList(),
      'subtasks': subtaskBox.values.map((jsonStr) => _subtaskFromJson(jsonDecode(jsonStr))).map((subtask) => _subtaskToJson(subtask)).toList(),
      'settings': settingsBox.toMap(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
    return backup;
  }

  Future<void> importData(Map<String, dynamic> backup) async {
    try {
      // Clear existing data
      await taskBox.clear();
      await projectBox.clear();
      await subtaskBox.clear();
      await waterLogBox.clear();
      await settingsBox.clear();
      
      // Import tasks
      final tasksData = backup['tasks'] as List<dynamic>;
      for (final taskData in tasksData) {
        final task = _taskFromJson(Map<String, dynamic>.from(taskData as Map));
        await taskBox.put(task.id, jsonEncode(_taskToJson(task)));
      }
      
      // Import projects
      final projectsData = backup['projects'] as List<dynamic>;
      for (final projectData in projectsData) {
        final project = _projectFromJson(Map<String, dynamic>.from(projectData as Map));
        await projectBox.put(project.id, jsonEncode(_projectToJson(project)));
      }
      
      // Import subtasks
      final subtasksData = backup['subtasks'] as List<dynamic>;
      for (final subtaskData in subtasksData) {
        final subtask = _subtaskFromJson(Map<String, dynamic>.from(subtaskData as Map));
        await subtaskBox.put(subtask.id, jsonEncode(_subtaskToJson(subtask)));
      }
      
      // Import settings
      final settingsData = Map<String, dynamic>.from(backup['settings'] as Map);
      for (final entry in settingsData.entries) {
        await settingsBox.put(entry.key, entry.value);
      }
    } catch (e) {
      throw Exception('Failed to import backup: $e');
    }
  }

  Future<void> close() async {
    await taskBox.close();
    await projectBox.close();
    await subtaskBox.close();
    await waterLogBox.close();
    await settingsBox.close();
    _isInitialized = false;
    _initFuture = null;
  }

  Future<void> clearDatabase() async {
    try {
      // Close existing boxes if open
      await close();
      
      // Delete box files from disk
      await Hive.deleteBoxFromDisk(TASK_BOX_NAME);
      await Hive.deleteBoxFromDisk(PROJECT_BOX_NAME);
      await Hive.deleteBoxFromDisk(SUBTASK_BOX_NAME);
      await Hive.deleteBoxFromDisk(WATER_LOG_BOX_NAME);
      await Hive.deleteBoxFromDisk(SETTINGS_BOX_NAME);
    } catch (e) {
      // Ignore errors during cleanup
    }
  }

  // User Level Management
  Future<void> saveUserLevel(UserLevelModel userLevel) async {
    try {
      final currentSettings = await getSettings();
      currentSettings['user_level'] = {
        'level': userLevel.level,
        'title': userLevel.title,
        'minPoints': userLevel.minPoints,
        'maxPoints': userLevel.maxPoints,
      };
      await settingsBox.put('settings', currentSettings);
    } catch (e) {
      throw Exception('Failed to save user level: $e');
    }
  }

  Future<UserLevelModel?> getUserLevel() async {
    try {
      final settings = await getSettings();
      final levelData = settings['user_level'];
      if (levelData == null) return null;
      
      final data = _safeMapCast(levelData);
      if (data == null) return null;
      return UserLevelModel(
        level: data['level'] as int,
        title: data['title'] as String,
        minPoints: data['minPoints'] as int,
        maxPoints: data['maxPoints'] as int,
      );
    } catch (e) {
      throw Exception('Failed to get user level: $e');
    }
  }

  // JSON conversion methods
  Map<String, dynamic> _taskToJson(TaskModel task) {
    return task.toMap();
  }

  TaskModel _taskFromJson(Map<String, dynamic> json) {
    return TaskModel.fromMap(json);
  }

  Map<String, dynamic> _projectToJson(Project project) {
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
      'subtasks': project.subtasks.map((subtask) => _subtaskToJson(subtask)).toList(),
      'createdAt': project.createdAt.toIso8601String(),
      'category': project.category,
      'totalHoursSpent': project.totalHoursSpent,
      'priority': project.priority,
      'description': project.description,
    };
  }

  Project _projectFromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'مشروع بدون اسم',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      techStack: json['techStack'] != null ? List<String>.from(json['techStack'] as List) : [],
      weeklyHours: json['weeklyHours'] as int? ?? 40,
      status: ProjectStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ProjectStatus.active,
      ),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      statusMessage: json['statusMessage'] as String?,
      weeklyFocus: json['weeklyFocus'] as String?,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      subtasks: json['subtasks'] != null
          ? (json['subtasks'] as List<dynamic>)
              .map((subtask) => _subtaskFromJson(Map<String, dynamic>.from(subtask as Map)))
              .toList()
          : [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      category: json['category'] as String? ?? 'غير محدد',
      totalHoursSpent: json['totalHoursSpent'] as int? ?? 0,
      priority: json['priority'] as int? ?? 3,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> _subtaskToJson(SubtaskModel subtask) {
    return subtask.toMap();
  }

  SubtaskModel _subtaskFromJson(Map<String, dynamic> json) {
    return SubtaskModel.fromMap(json);
  }

  /// Safely converts a dynamic value (typically `Map<dynamic, dynamic>` from Hive)
  /// to `Map<String, dynamic>`. Returns null if the input is null or not a Map.
  static Map<String, dynamic>? _safeMapCast(dynamic rawData) {
    if (rawData == null) return null;
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is Map) {
      return Map<String, dynamic>.from(rawData);
    }
    return null;
  }
}
