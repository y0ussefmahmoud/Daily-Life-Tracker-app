import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class TaskService {
  final SupabaseClient _supabase = SupabaseService.client;
  final AuthService _authService = AuthService();

  Future<List<Task>> fetchTasks() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('daily_tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response is List) {
        return response
            .map((task) => Task.fromJson(task as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<String> createTask(Task task) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final payload = {
      'user_id': userId,
      'title': task.title,
      'category': task.category,
      'is_completed': task.isCompleted,
      'icon': task.icon.codePoint.toString(),
      'reminder_time': _timeOfDayToJson(task.reminderTime),
      'is_repeating': task.isRepeating,
      'priority': task.priority?.name,
    };

    final response = await _supabase
        .from('daily_tasks')
        .insert(payload)
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      throw Exception('Task ID is required for update');
    }
    
    await _supabase
        .from('daily_tasks')
        .update(task.toJson())
        .eq('id', task.id!);
  }

  Future<void> deleteTask(String taskId) async {
    await _supabase.from('daily_tasks').delete().eq('id', taskId);
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _supabase
        .from('daily_tasks')
        .update({'is_completed': isCompleted})
        .eq('id', taskId);
  }

  String? _timeOfDayToJson(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
