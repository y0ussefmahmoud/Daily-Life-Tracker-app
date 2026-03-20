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

  late Box<Task> taskBox;
  late Box<Project> projectBox;
  late Box<Subtask> subtaskBox;
  late Box<WaterLog> waterLogBox;
  late Box<Map<String, dynamic>> settingsBox;

  static const String TASK_BOX_NAME = 'tasks';
  static const String PROJECT_BOX_NAME = 'projects';
  static const String SUBTASK_BOX_NAME = 'subtasks';
  static const String WATER_LOG_BOX_NAME = 'water_logs';
  static const String SETTINGS_BOX_NAME = 'settings';

  Future<void> init() async {
    await _initializeInternal().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Database initialization timeout');
      },
    );
  }
  
  Future<void> _initializeInternal() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    
    // Register adapters
    await registerHiveAdapters();
    
    // Try to open boxes, if fails, clear database and retry
    try {
      taskBox = await Hive.openBox<Task>(TASK_BOX_NAME);
      projectBox = await Hive.openBox<Project>(PROJECT_BOX_NAME);
      subtaskBox = await Hive.openBox<Subtask>(SUBTASK_BOX_NAME);
      waterLogBox = await Hive.openBox<WaterLog>(WATER_LOG_BOX_NAME);
      settingsBox = await Hive.openBox<Map<String, dynamic>>(SETTINGS_BOX_NAME);
    } catch (e) {
      debugPrint('Error opening boxes: $e');
      debugPrint('Clearing database and retrying...');
      
      // Clear the entire database
      try {
        await clearDatabase();
        debugPrint('Database cleared successfully');
        
        // Retry opening boxes
        taskBox = await Hive.openBox<Task>(TASK_BOX_NAME);
        projectBox = await Hive.openBox<Project>(PROJECT_BOX_NAME);
        subtaskBox = await Hive.openBox<Subtask>(SUBTASK_BOX_NAME);
        waterLogBox = await Hive.openBox<WaterLog>(WATER_LOG_BOX_NAME);
        settingsBox = await Hive.openBox<Map<String, dynamic>>(SETTINGS_BOX_NAME);
        debugPrint('Boxes opened successfully after clearing database');
      } catch (retryError) {
        debugPrint('Failed to open boxes even after clearing database: $retryError');
        // Continue with empty boxes - this will allow the app to start
        taskBox = await Hive.openBox<Task>(TASK_BOX_NAME);
        projectBox = await Hive.openBox<Project>(PROJECT_BOX_NAME);
        subtaskBox = await Hive.openBox<Subtask>(SUBTASK_BOX_NAME);
        waterLogBox = await Hive.openBox<WaterLog>(WATER_LOG_BOX_NAME);
        settingsBox = await Hive.openBox<Map<String, dynamic>>(SETTINGS_BOX_NAME);
      }
    }
  }

  Future<void> initialize() async {
    await _initializeInternal();
  }

  bool isWaterLogBoxInitialized() {
    try {
      return waterLogBox.isOpen;
    } catch (e) {
      return false;
    }
  }

  // Task operations
  Future<void> addTask(Task task) async {
    await taskBox.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }

  Future<List<Task>> getAllTasks() async {
    return taskBox.values.toList();
  }

  List<Task> getCompletedTasks() {
    return taskBox.values.where((task) => task.isCompleted).toList();
  }

  List<Task> getPendingTasks() {
    return taskBox.values.where((task) => !task.isCompleted).toList();
  }

  // Project operations
  Future<Project?> getProject(String id) async {
    return projectBox.get(id);
  }

  Future<List<Project>> getAllProjects() async {
    return projectBox.values.toList();
  }

  Future<List<Project>> getActiveProjects() async {
    return projectBox.values.where((p) => p.status == ProjectStatus.active).toList();
  }

  Future<List<Project>> getCompletedProjects() async {
    return projectBox.values.where((p) => p.status == ProjectStatus.completed).toList();
  }

  Future<void> updateProjectProgress(String projectId, double progress) async {
    try {
      final project = projectBox.get(projectId);
      if (project != null) {
        final updatedProject = project.copyWith(progress: progress);
        await projectBox.put(projectId, updatedProject);
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
    await projectBox.put(project.id, project);
  }

  Future<void> addProject(Project project) async {
    await projectBox.put(project.id, project);
  }

  Future<void> deleteProject(String id) async {
    await projectBox.delete(id);
    // Also delete related subtasks
    final subtasksToDelete = subtaskBox.values.where((subtask) => subtask.projectId == id);
    for (final subtask in subtasksToDelete) {
      await subtaskBox.delete(subtask.id);
    }
  }

  // Subtask operations
  Future<void> addSubtask(Subtask subtask) async {
    await subtaskBox.put(subtask.id, subtask);
  }

  Future<void> updateSubtask(Subtask subtask) async {
    await subtaskBox.put(subtask.id, subtask);
  }

  Future<void> deleteSubtask(String id) async {
    await subtaskBox.delete(id);
  }

  Subtask? getSubtask(String id) {
    return subtaskBox.get(id);
  }

  List<Subtask> getSubtasksByProject(String projectId) {
    return subtaskBox.values.where((subtask) => subtask.projectId == projectId).toList();
  }

  List<Subtask> getAllSubtasks() {
    return subtaskBox.values.toList();
  }

  List<Subtask> getCompletedSubtasks() {
    return subtaskBox.values.where((subtask) => subtask.isCompleted).toList();
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

  Future<Map<String, dynamic>?> getSetting(String key) async {
    try {
      final settings = await getSettings();
      return settings[key];
    } catch (e) {
      throw Exception('Failed to get setting: $e');
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final settings = await settingsBox.get('settings');
      return settings ?? <String, dynamic>{};
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
      'tasks': taskBox.values.map((task) => _taskToJson(task)).toList(),
      'projects': projectBox.values.map((project) => _projectToJson(project)).toList(),
      'subtasks': subtaskBox.values.map((subtask) => _subtaskToJson(subtask)).toList(),
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
        final task = _taskFromJson(taskData as Map<String, dynamic>);
        await taskBox.put(task.id, task);
      }
      
      // Import projects
      final projectsData = backup['projects'] as List<dynamic>;
      for (final projectData in projectsData) {
        final project = _projectFromJson(projectData as Map<String, dynamic>);
        await projectBox.put(project.id, project);
      }
      
      // Import subtasks
      final subtasksData = backup['subtasks'] as List<dynamic>;
      for (final subtaskData in subtasksData) {
        final subtask = _subtaskFromJson(subtaskData as Map<String, dynamic>);
        await subtaskBox.put(subtask.id, subtask);
      }
      
      // Import settings
      final settingsData = backup['settings'] as Map<String, dynamic>;
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
      
      final data = levelData as Map<String, dynamic>;
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
  Map<String, dynamic> _taskToJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'category': task.category,
      'iconCodePoint': task.iconCodePoint,
      'isCompleted': task.isCompleted,
      'reminderTimeString': task.reminderTimeString,
      'isRepeating': task.isRepeating,
      'priority': task.priority.name,
      'createdAt': task.createdAt.toIso8601String(),
    };
  }

  Task _taskFromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'مهمة بدون عنوان',
      category: json['category'] as String? ?? 'عام',
      iconCodePoint: json['iconCodePoint'] as int? ?? 0xE87C,
      isCompleted: json['isCompleted'] as bool? ?? false,
      reminderTimeString: json['reminderTimeString'] as String?,
      isRepeating: json['isRepeating'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      priority: json['priority'] != null
          ? TaskPriority.values.firstWhere(
              (p) => p.name == json['priority'],
              orElse: () => TaskPriority.medium,
            )
          : TaskPriority.medium,
    );
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
              .map((subtask) => _subtaskFromJson(subtask as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      category: json['category'] as String? ?? 'غير محدد',
      totalHoursSpent: json['totalHoursSpent'] as int? ?? 0,
      priority: json['priority'] as int? ?? 3,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> _subtaskToJson(Subtask subtask) {
    return {
      'id': subtask.id,
      'title': subtask.title,
      'isCompleted': subtask.isCompleted,
      'priority': subtask.priority.name,
      'projectId': subtask.projectId,
      'createdAt': subtask.createdAt.toIso8601String(),
      'completedAt': subtask.completedAt?.toIso8601String(),
      'timeSpentMinutes': subtask.timeSpentMinutes,
    };
  }

  Subtask _subtaskFromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'مهمة فرعية بدون عنوان',
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: json['priority'] != null
          ? SubtaskPriority.values.firstWhere(
              (p) => p.name == json['priority'],
              orElse: () => SubtaskPriority.medium,
            )
          : SubtaskPriority.medium,
      projectId: json['projectId'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      timeSpentMinutes: json['timeSpentMinutes'] as int?,
    );
  }
}
