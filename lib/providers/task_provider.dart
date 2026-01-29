import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';
import '../services/task_service.dart';
import '../providers/achievements_provider.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  AchievementsProvider? _achievementsProvider;

  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setAchievementsProvider(AchievementsProvider achievementsProvider) {
    _achievementsProvider = achievementsProvider;
  }

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.fetchTasks();
    } on PostgrestException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'حدث خطأ غير متوقع';
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
        await _taskService.toggleTaskCompletion(taskId, updatedTask.isCompleted);
        
        // Award XP if task was just completed
        if (updatedTask.isCompleted && !currentTask.isCompleted) {
          final xpAmount = _calculateXPForTask(updatedTask);
          if (_achievementsProvider != null) {
            await _achievementsProvider!.addXP(xpAmount);
          }
        }
      } on PostgrestException catch (e) {
        _tasks[taskIndex] = currentTask;
        _error = e.message;
      } catch (_) {
        _tasks[taskIndex] = currentTask;
        _error = 'حدث خطأ غير متوقع';
      } finally {
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

  double getCompletionPercentage() {
    if (_tasks.isEmpty) return 0.0;
    final completedTasks = _tasks.where((task) => task.isCompleted).length;
    return completedTasks / _tasks.length;
  }

  Future<void> addTask(Task task) async {
    if (task.title.trim().isEmpty) {
      throw Exception('Task title cannot be empty');
    }
    if (task.category.trim().isEmpty) {
      throw Exception('Task category cannot be empty');
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _taskService.createTask(task);
      _tasks = await _taskService.fetchTasks();
    } on PostgrestException catch (e) {
      _error = e.message;
      rethrow;
    } catch (_) {
      _error = 'حدث خطأ غير متوقع';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.fetchTasks();
    } on PostgrestException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'حدث خطأ غير متوقع';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
