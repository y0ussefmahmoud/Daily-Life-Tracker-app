// ignore_for_file: unnecessary_import, unreachable_switch_default

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/local_database_service.dart';
import '../providers/achievements_provider.dart';

class TaskProvider extends ChangeNotifier {
  final LocalDatabaseService _db = LocalDatabaseService();
  final Uuid _uuid = const Uuid();
  List<Task> _tasks = [];
  AchievementsProvider? _achievementsProvider;

  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Task> get todayTasks => _tasks.where((task) {
    final today = DateTime.now();
    final taskDate = task.createdAt;
    return taskDate.year == today.year &&
        taskDate.month == today.month &&
        taskDate.day == today.day;
  }).toList();
  
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  String? get error => _error;
  bool get isInitialized => _tasks.isNotEmpty || _error != null;

  void setAchievementsProvider(AchievementsProvider achievementsProvider) {
    _achievementsProvider = achievementsProvider;
  }

  Future<void> initialize() async {
    await loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    
    try {
      _tasks = await _db.getAllTasks();
    } catch (e) {
      _error = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTask(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final currentTask = _tasks[taskIndex];
      final updatedTask = currentTask.copyWith(
        isCompleted: !currentTask.isCompleted,
      );
      _tasks[taskIndex] = updatedTask;
      notifyListeners();
      
      try {
        await _db.updateTask(updatedTask);
        
        // Award XP if task was just completed
        if (updatedTask.isCompleted && !currentTask.isCompleted) {
          final xpAmount = _calculateXPForTask(updatedTask);
          if (_achievementsProvider != null) {
            await _achievementsProvider?.addXP(xpAmount);
          }
        }
      } catch (e) {
        _tasks[taskIndex] = currentTask;
        _error = 'حدث خطأ غير متوقع: $e';
        notifyListeners();
      }
    }
  }

  int _calculateXPForTask(Task task) {
    // Calculate XP based on task priority
    switch (task.priority) {
      case TaskPriority.high:
        return 15;
      case TaskPriority.medium:
        return 10;
      case TaskPriority.low:
        return 5;
      default:
        return 5;
    }
  }

  List<Task> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  List<Task> getCompletedTasks() {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  List<Task> getPendingTasks() {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  double getCompletionPercentage() {
    if (_tasks.isEmpty) return 0.0;
    final completedTasks = _tasks.where((task) => task.isCompleted).length;
    return completedTasks / _tasks.length;
  }

  Future<void> addTask({
    required String title,
    required String category,
    required IconData icon,
    TaskPriority priority = TaskPriority.medium,
    TimeOfDay? reminderTime,
    bool isRepeating = false,
  }) async {
    debugPrint('=== TASK PROVIDER ADD TASK START ===');
    debugPrint('Title: $title');
    debugPrint('Category: $category');
    debugPrint('Priority: $priority');
    debugPrint('Icon: ${icon.codePoint}');
    debugPrint('IsRepeating: $isRepeating');
    
    if (title.trim().isEmpty) {
      debugPrint('ERROR: Task title is empty');
      throw Exception('Task title cannot be empty');
    }
    if (category.trim().isEmpty) {
      debugPrint('ERROR: Task category is empty');
      throw Exception('Task category cannot be empty');
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      debugPrint('Creating Task object...');
      final task = Task(
        id: _uuid.v4(),
        title: title.trim(),
        iconCodePoint: icon.codePoint,
        category: category.trim(),
        priority: priority,
        isRepeating: isRepeating,
        createdAt: DateTime.now(),
      );
      
      debugPrint('Task object created: ${task.id}');
      
      if (reminderTime != null) {
        task.reminderTime = reminderTime;
        debugPrint('Reminder time set: $reminderTime');
      }

      debugPrint('Calling database addTask...');
      await _db.addTask(task);
      debugPrint('Database addTask completed');
      
      debugPrint('Loading tasks from database...');
      _tasks = await _db.getAllTasks();
      debugPrint('Tasks loaded: ${_tasks.length} items');
      
      debugPrint('=== TASK PROVIDER ADD TASK COMPLETE ===');
    } catch (e, stackTrace) {
      debugPrint('TASK PROVIDER ADD ERROR: $e');
      debugPrint('STACK: $stackTrace');
      _error = 'حدث خطأ غير متوقع: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      _tasks.removeAt(taskIndex);
      notifyListeners();
      
      try {
        await _db.deleteTask(taskId);
      } catch (e) {
        _tasks.insert(taskIndex, task);
        _error = 'حدث خطأ غير متوقع: $e';
        notifyListeners();
      }
    }
  }

  Future<void> updateTask(Task task) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = task;
      notifyListeners();
      
      try {
        await _db.updateTask(task);
      } catch (e) {
        _tasks = await _db.getAllTasks();
        _error = 'حدث خطأ غير متوقع: $e';
        notifyListeners();
      }
    }
  }

  Future<void> refreshTasks() async {
    await loadTasks();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Statistics
  int get totalTasksCount => _tasks.length;
  int get completedTasksCount => getCompletedTasks().length;
  int get pendingTasksCount => getPendingTasks().length;

  // Search functionality
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _tasks;
    
    final lowerQuery = query.toLowerCase();
    return _tasks.where((task) =>
      task.title.toLowerCase().contains(lowerQuery) ||
      task.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
