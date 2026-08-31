// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

// ignore_for_file: unused_import, unnecessary_non_null_assertion

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subtask_model.dart';
import '../services/local_database_service.dart';
import '../utils/constants.dart';

class SubTaskProvider extends ChangeNotifier {
  final LocalDatabaseService _db = LocalDatabaseService();
  List<SubtaskModel> _subTasks = [];
  bool _isLoading = false;

  SubTaskProvider();

  // Getters for synchronous access to cached data
  bool get isLoading => _isLoading;
  List<SubtaskModel> get subTasks => List.unmodifiable(_subTasks);
  double get completionPercentage => _subTasks.isEmpty ? 0.0 : _subTasks.where((t) => t.isCompleted).length / _subTasks.length;
  List<SubtaskModel> get inProgressTasks => _subTasks.where((t) => !t.isCompleted).toList();
  List<SubtaskModel> get completedTasks => _subTasks.where((t) => t.isCompleted).toList();

  Future<List<SubtaskModel>> getSubTasksByProject(String projectId) async {
    try {
      // SubtaskModel doesn't have projectId, so we can't filter by project
      // Return empty list for now - this feature needs to be re-implemented
      // Projects should track their subtasks differently
      _subTasks = [];
      return _subTasks;
    } catch (e) {
      return [];
    }
  }

  Future<void> toggleSubTaskCompletion(String taskId) async {
    try {
      final taskIndex = _subTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final newCompletionStatus = !_subTasks[taskIndex].isCompleted;
        final updatedTask = _subTasks[taskIndex].copyWith(
          isCompleted: newCompletionStatus,
          completedAt: newCompletionStatus ? DateTime.now() : null,
        );
        await _db.updateSubtask(updatedTask);
        _subTasks[taskIndex] = updatedTask;
        HapticFeedback.lightImpact();
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> addSubTask(SubtaskModel task) async {
    try {
      await _db.addSubtask(task);
      _subTasks.add(task);
      HapticFeedback.lightImpact();
      notifyListeners();
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> deleteSubTask(String taskId) async {
    try {
      await _db.deleteSubtask(taskId);
      _subTasks.removeWhere((task) => task.id == taskId);
      HapticFeedback.lightImpact();
      notifyListeners();
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> updateSubTask(SubtaskModel task) async {
    try {
      await _db.updateSubtask(task);
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

  void updateSubTaskPriority(String taskId, SubtaskPriority priority) {
    final index = _subTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final updatedTask = _subTasks[index].copyWith(priority: priority);
      _subTasks[index] = updatedTask;
      _db.updateSubtask(updatedTask);
      notifyListeners();
    }
  }

  void duplicateSubTask(String taskId) {
    final task = _subTasks.firstWhere((t) => t.id == taskId);
    final newTask = SubtaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: task.taskId,
      title: task.title,
      isCompleted: false,
      priority: task.priority,
      createdAt: DateTime.now(),
    );
    addSubTask(newTask);
  }

  SubtaskModel? getSubTaskById(String taskId) {
    try {
      return _subTasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadSubTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // SubtaskModel doesn't have projectId, so we can't filter by project
      // Return empty list for now - this feature needs to be re-implemented
      _subTasks = [];
    } catch (e) {
      _subTasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
