import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subtask_model.dart';
import '../services/project_service.dart';

class SubTaskProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<Subtask> _subTasks = [];
  bool _isLoading = false;

  SubTaskProvider();

  // Getters for synchronous access to cached data
  bool get isLoading => _isLoading;
  List<Subtask> get subTasks => List.unmodifiable(_subTasks);
  double get completionPercentage => _subTasks.isEmpty ? 0.0 : _subTasks.where((t) => t.isCompleted).length / _subTasks.length;
  List<Subtask> get inProgressTasks => _subTasks.where((t) => !t.isCompleted).toList();
  List<Subtask> get completedTasks => _subTasks.where((t) => t.isCompleted).toList();

  Future<List<Subtask>> getSubTasksByProject(String projectId) async {
    try {
      final subTasks = await _projectService.fetchSubTasks(projectId);
      _subTasks = subTasks;
      return subTasks;
    } catch (e) {
      return [];
    }
  }

  Future<List<Subtask>> getInProgressTasks(String projectId) async {
    final subTasks = await getSubTasksByProject(projectId);
    return subTasks.where((task) => !task.isCompleted).toList();
  }

  Future<List<Subtask>> getCompletedTasks(String projectId) async {
    final subTasks = await getSubTasksByProject(projectId);
    return subTasks.where((task) => task.isCompleted).toList();
  }

  Future<void> toggleSubTaskCompletion(String taskId) async {
    try {
      final taskIndex = _subTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final newCompletionStatus = !_subTasks[taskIndex].isCompleted;
        await _projectService.toggleSubTaskCompletion(taskId, newCompletionStatus);
        _subTasks[taskIndex] = _subTasks[taskIndex].copyWith(
          isCompleted: newCompletionStatus,
          completedAt: newCompletionStatus ? DateTime.now() : null,
        );
        HapticFeedback.lightImpact();
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> addSubTask(Subtask task) async {
    try {
      final taskId = await _projectService.createSubTask(task);
      final newTask = task.copyWith(id: taskId);
      _subTasks.add(newTask);
      HapticFeedback.lightImpact();
      notifyListeners();
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> deleteSubTask(String taskId) async {
    try {
      await _projectService.deleteSubTask(taskId);
      _subTasks.removeWhere((task) => task.id == taskId);
      HapticFeedback.lightImpact();
      notifyListeners();
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> updateSubTask(Subtask task) async {
    try {
      await _projectService.updateSubTask(task);
      final taskIndex = _subTasks.indexWhere((t) => t.id == task.id);
      if (taskIndex != -1) {
        _subTasks[taskIndex] = task;
        HapticFeedback.lightImpact();
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<double> getCompletionPercentage(String projectId) async {
    final projectTasks = await getSubTasksByProject(projectId);
    if (projectTasks.isEmpty) return 0.0;
    
    final completedTasks = projectTasks.where((task) => task.isCompleted).length;
    return completedTasks / projectTasks.length;
  }

  Future<void> reorderSubTasks(String projectId, int oldIndex, int newIndex) async {
    final projectTasks = await getSubTasksByProject(projectId);
    if (oldIndex < projectTasks.length && newIndex < projectTasks.length) {
      final task = projectTasks[oldIndex];
      
      // Find the actual indices in _subTasks
      final actualOldIndex = _subTasks.indexWhere((t) => t.id == task.id);
      if (actualOldIndex == -1) return;
      
      // Remove from actual position
      _subTasks.removeAt(actualOldIndex);
      
      // Find the actual new index (accounting for the removal)
      int actualNewIndex;
      if (newIndex >= projectTasks.length) {
        actualNewIndex = _subTasks.length;
      } else {
        final targetTask = projectTasks[newIndex];
        actualNewIndex = _subTasks.indexWhere((t) => t.id == targetTask.id);
        if (actualNewIndex == -1) actualNewIndex = _subTasks.length;
      }
      
      // Insert at the new position
      _subTasks.insert(actualNewIndex, task);
      notifyListeners();
    }
  }

  void updateSubTaskPriority(String taskId, TaskPriority priority) {
    final taskIndex = _subTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _subTasks[taskIndex] = _subTasks[taskIndex].copyWith(priority: priority);
      HapticFeedback.lightImpact();
      notifyListeners();
    }
  }

  void duplicateSubTask(String taskId) {
    final task = _subTasks.firstWhere((t) => t.id == taskId);
    final newTask = Subtask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: task.title,
      isCompleted: false,
      priority: task.priority,
      projectId: task.projectId,
    );
    addSubTask(newTask);
  }

  Subtask? getSubTaskById(String taskId) {
    try {
      return _subTasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCompletedTasks(String projectId) async {
    try {
      final completedTasks = await getCompletedTasks(projectId);
      for (final task in completedTasks) {
        await _projectService.deleteSubTask(task.id!);
      }
      _subTasks.removeWhere((task) => 
          task.projectId == projectId && task.isCompleted);
      HapticFeedback.lightImpact();
      notifyListeners();
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<Map<String, dynamic>> getTaskStatistics(String projectId) async {
    final projectTasks = await getSubTasksByProject(projectId);
    final inProgressTasks = await getInProgressTasks(projectId);
    final completedTasks = await getCompletedTasks(projectId);
    
    return {
      'total': projectTasks.length,
      'inProgress': inProgressTasks.length,
      'completed': completedTasks.length,
      'completionPercentage': await getCompletionPercentage(projectId),
      'highPriority': projectTasks.where((t) => t.priority == TaskPriority.high).length,
      'mediumPriority': projectTasks.where((t) => t.priority == TaskPriority.medium).length,
      'lowPriority': projectTasks.where((t) => t.priority == TaskPriority.low).length,
    };
  }

  Future<void> loadSubTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _subTasks = await _projectService.fetchSubTasks(projectId);
    } catch (e) {
      _subTasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
