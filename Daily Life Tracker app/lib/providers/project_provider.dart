import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';
import '../services/local_database_service.dart';

class ProjectProvider extends ChangeNotifier {
  final LocalDatabaseService _db = LocalDatabaseService();
  final Uuid _uuid = const Uuid();
  List<Project> _projects = [];

  bool _isLoading = false;
  String? _error;

  List<Project> get projects => List.unmodifiable(_projects);
  List<Project> get activeProjects => _projects.where((project) => project.status == ProjectStatus.active).toList();
  List<Project> get pausedProjects => _projects.where((project) => project.status == ProjectStatus.paused).toList();
  List<Project> get completedProjects => _projects.where((project) => project.status == ProjectStatus.completed).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _projects.isNotEmpty || _error != null;

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await loadProjects();
    } catch (e) {
      _projects = [];
      _error = 'Failed to load projects: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProject({
    required String name,
    required List<String> techStack,
    required int weeklyHours,
    required ProjectStatus status,
    required String category,
    required int totalHoursSpent,
    String? description,
    required double progress,
  }) async {
    if (name.trim().isEmpty) {
      throw Exception('Project name cannot be empty');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final project = Project(
        id: _uuid.v4(),
        name: name.trim(),
        progress: progress,
        techStack: techStack,
        weeklyHours: weeklyHours,
        status: status,
        createdAt: DateTime.now(),
        category: category,
        totalHoursSpent: totalHoursSpent,
        priority: 3, // Default priority
        description: description,
      );

      await _db.addProject(project);
      _projects = _db.getAllProjects() as List<Project>;
    } catch (e) {
      _error = 'Failed to add project: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProject(Project updatedProject) async {
    try {
      await _db.updateProject(updatedProject);
      final projectIndex = _projects.indexWhere((project) => project.id == updatedProject.id);
      if (projectIndex != -1) {
        _projects[projectIndex] = updatedProject;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update project: $e';
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _db.deleteProject(projectId);
      _projects.removeWhere((project) => project.id == projectId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete project: $e';
      rethrow;
    }
  }

  Future<void> toggleProjectStatus(String projectId) async {
    try {
      final projectIndex = _projects.indexWhere((project) => project.id == projectId);
      if (projectIndex != -1) {
        final currentProject = _projects[projectIndex];
        ProjectStatus newStatus;
        
        switch (currentProject.status) {
          case ProjectStatus.active:
            newStatus = ProjectStatus.paused;
            break;
          case ProjectStatus.paused:
            newStatus = ProjectStatus.active;
            break;
          case ProjectStatus.completed:
            newStatus = ProjectStatus.active;
            break;
          case ProjectStatus.inProgress:
            newStatus = ProjectStatus.paused;
            break;
        }
        
        final updatedProject = currentProject.copyWith(status: newStatus);
        _projects[projectIndex] = updatedProject;
        await _db.updateProject(updatedProject);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to toggle project status: $e';
      notifyListeners();
    }
  }

  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((project) => project.id == projectId);
    } catch (e) {
      return null;
    }
  }

  int get activeProjectsCount => activeProjects.length;
  int get pausedProjectsCount => pausedProjects.length;
  int get completedProjectsCount => completedProjects.length;

  String generateProjectId() {
    return _uuid.v4();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadProjects() async {
    try {
      _error = null;
      _projects = await _db.getAllProjects();
    } catch (e) {
      _projects = [];
      _error = 'Failed to load projects: $e';
    } finally {
      notifyListeners();
    }
  }

  // Statistics
  Future<double> getOverallProgress() async {
    return await _db.getOverallProjectProgress();
  }

  // Search functionality
  List<Project> searchProjects(String query) {
    if (query.isEmpty) return _projects;
    
    final lowerQuery = query.toLowerCase();
    return _projects.where((project) =>
      project.name.toLowerCase().contains(lowerQuery) ||
      project.techStack.any((tech) => tech.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  Future<void> updateProjectProgress(String projectId, double progress) async {
    try {
      await _db.updateProjectProgress(projectId, progress);
      await loadProjects();
    } catch (e) {
      _error = 'Failed to update project progress: $e';
      notifyListeners();
    }
  }

  Future<void> refreshProjects() async {
    await initialize();
  }
}
