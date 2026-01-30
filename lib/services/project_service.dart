import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_model.dart';
import '../models/subtask_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class ProjectService {
  final SupabaseClient _supabase = SupabaseService.client;
  final AuthService _authService = AuthService();

  Future<List<Project>> fetchProjects() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('projects')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response is List) {
        return response
            .map((project) => Project.fromJson(project as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<String> createProject(Project project) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final payload = project.toJson();
    payload['user_id'] = userId;
    payload.remove('id'); // Remove id as it will be auto-generated
    payload.remove('created_at'); // Remove created_at as it will be auto-generated

    final response = await _supabase
        .from('projects')
        .insert(payload)
        .select('id')
        .single();

    final projectId = response?['id'] as String?;
    if (projectId == null) {
      throw Exception('Failed to create project: No ID returned from database');
    }
    return projectId;
  }

  Future<void> updateProject(Project project) async {
    if (project.id == null) {
      throw Exception('Project ID is required for update');
    }

    await _supabase
        .from('projects')
        .update(project.toJson())
        .eq('id', project.id!);
  }

  Future<void> deleteProject(String projectId) async {
    await _supabase.from('projects').delete().eq('id', projectId);
  }

  Future<void> toggleProjectStatus(String projectId, ProjectStatus newStatus) async {
    await _supabase
        .from('projects')
        .update({'status': newStatus.name})
        .eq('id', projectId);
  }

  Future<void> updateProjectProgress(String projectId, double progress) async {
    await _supabase
        .from('projects')
        .update({'progress': progress})
        .eq('id', projectId);
  }

  // Time logging methods
  Future<void> logProjectTime(String projectId, int minutes) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final payload = {
      'user_id': userId,
      'project_id': projectId,
      'time_spent_minutes': minutes,
      'created_at': DateTime.now().toIso8601String(),
    };

    await _supabase.from('project_time_logs').insert(payload);
  }

  Future<List<Map<String, dynamic>>> fetchProjectTimeLogs(String projectId) async {
    try {
      final response = await _supabase
          .from('project_time_logs')
          .select()
          .eq('project_id', projectId)
          .order('created_at', ascending: false);

      if (response is List) {
        return response.map((log) => log as Map<String, dynamic>).toList();
      }

      return [];
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<int> getTotalTimeSpent(String projectId) async {
    try {
      final response = await _supabase
          .from('project_time_logs')
          .select('time_spent_minutes')
          .eq('project_id', projectId);

      if (response is List) {
        return response.fold<int>(0, (sum, log) {
          final minutes = (log as Map<String, dynamic>)['time_spent_minutes'] as num?;
          return sum + (minutes?.toInt() ?? 0);
        });
      }

      return 0;
    } on PostgrestException {
      return 0;
    } catch (_) {
      return 0;
    }
  }

  // SubTask methods
  Future<List<Subtask>> fetchSubTasks(String projectId) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('project_time_logs')
          .select()
          .eq('project_id', projectId)
          .eq('user_id', userId)
          .not('title', 'is', null) // Only get entries that are subtasks (have a title)
          .order('created_at', ascending: false);

      if (response is List) {
        return response
            .map((subtask) => Subtask.fromJson(subtask as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<String> createSubTask(Subtask subtask) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final payload = subtask.toJson();
    payload['user_id'] = userId;
    payload.remove('id'); // Remove id as it will be auto-generated
    payload.remove('created_at'); // Remove created_at as it will be auto-generated

    final response = await _supabase
        .from('project_time_logs')
        .insert(payload)
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<void> updateSubTask(Subtask subtask) async {
    if (subtask.id == null) return;
    
    await _supabase
        .from('project_time_logs')
        .update(subtask.toJson())
        .eq('id', subtask.id!);
  }

  Future<void> deleteSubTask(String subtaskId) async {
    await _supabase.from('project_time_logs').delete().eq('id', subtaskId);
  }

  Future<void> toggleSubTaskCompletion(String subtaskId, bool isCompleted) async {
    final updateData = {
      'is_completed': isCompleted,
      'completed_at': isCompleted, // Treat as boolean based on database schema
    };

    await _supabase
        .from('project_time_logs')
        .update(updateData)
        .eq('id', subtaskId);
  }
}
