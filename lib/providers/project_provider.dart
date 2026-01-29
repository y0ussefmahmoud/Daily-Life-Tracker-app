import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';
import '../providers/achievements_provider.dart';
import '../utils/error_handler.dart';
import '../utils/constants.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  AchievementsProvider? _achievementsProvider;
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => List.unmodifiable(_projects);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setAchievementsProvider(AchievementsProvider achievementsProvider) {
    _achievementsProvider = achievementsProvider;
  }

  List<Project> get activeProjects {
    return _projects.where((project) => project.status == ProjectStatus.active).toList();
  }

  List<Project> get pausedProjects {
    return _projects.where((project) => project.status == ProjectStatus.paused).toList();
  }

  List<Project> get completedProjects {
    return _projects.where((project) => project.status == ProjectStatus.completed).toList();
  }

  List<Project> get allProjects => List.unmodifiable(_projects);

  double getMonthlyProgress() {
    final activeProjects = this.activeProjects;
    if (activeProjects.isEmpty) return 0.0;
    
    final totalProgress = activeProjects.fold<double>(
      0.0, 
      (sum, project) => sum + project.progress
    );
    
    return totalProgress / activeProjects.length;
  }

  Future<void> toggleProjectStatus(String projectId) async {
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
      }
      
      try {
        await _projectService.toggleProjectStatus(projectId, newStatus);
        _projects[projectIndex] = currentProject.copyWith(status: newStatus);
        notifyListeners();
      } catch (e) {
        _error = handleProviderError(e, 'projects');
        notifyListeners();
      }
    }
  }

  Future<void> updateProjectProgress(String projectId, double progress) async {
    final projectIndex = _projects.indexWhere((project) => project.id == projectId);
    if (projectIndex != -1) {
      final currentProject = _projects[projectIndex];
      final wasJustCompleted = progress >= 1.0 && currentProject.status != ProjectStatus.completed;
      
      try {
        // Auto-mark as completed if progress reaches 100%
        if (progress >= 1.0) {
          await _projectService.updateProjectProgress(projectId, progress);
          await _projectService.toggleProjectStatus(projectId, ProjectStatus.completed);
          _projects[projectIndex] = _projects[projectIndex].copyWith(
            progress: progress,
            status: ProjectStatus.completed,
            statusMessage: 'مكتمل بنجاح'
          );
          
          // Award XP if project was just completed
          if (wasJustCompleted && _achievementsProvider != null) {
            final xpAmount = _calculateXPForProject(currentProject);
            await _achievementsProvider!.addXP(xpAmount);
          }
        } else {
          await _projectService.updateProjectProgress(projectId, progress);
          _projects[projectIndex] = _projects[projectIndex].copyWith(progress: progress);
        }
        
        notifyListeners();
      } catch (e) {
        _error = handleProviderError(e, 'projects');
        notifyListeners();
      }
    }
  }

  int _calculateXPForProject(Project project) {
    // Base XP for completing a project
    int baseXP = 50;
    
    // Bonus XP based on project complexity/duration
    int bonusXP = 0;
    
    // Add bonus XP for subtasks (if project has them)
    if (project.subtasks.isNotEmpty) {
      bonusXP += (project.subtasks.length * 10) as int;
    }
    
    // Add bonus XP based on project duration (longer projects get more XP)
    if (project.startDate != null && project.endDate != null) {
      final duration = project.endDate!.difference(project.startDate!).inDays;
      bonusXP += (duration ~/ 7) * 5 as int; // 5 XP per week
    }
    
    return baseXP + bonusXP;
  }

  Future<void> addProject(Project project) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final projectId = await _projectService.createProject(project);
      final newProject = project.copyWith(id: projectId);
      _projects.add(newProject);
    } catch (e) {
      _error = handleProviderError(e, 'projects');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProjects() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await loadProjects();
    } catch (e) {
      _error = handleProviderError(e, 'projects');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProject(Project updatedProject) async {
    try {
      await _projectService.updateProject(updatedProject);
      final projectIndex = _projects.indexWhere((project) => project.id == updatedProject.id);
      if (projectIndex != -1) {
        _projects[projectIndex] = updatedProject;
        notifyListeners();
      }
    } catch (e) {
      _error = handleProviderError(e, 'projects');
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _projectService.deleteProject(projectId);
      _projects.removeWhere((project) => project.id == projectId);
      notifyListeners();
    } catch (e) {
      _error = handleProviderError(e, 'projects');
      rethrow;
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
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadProjects() async {
    try {
      _projects = await _projectService.fetchProjects();
    } catch (e) {
      _projects = [];
      _error = handleProviderError(e, 'projects');
    } finally {
      notifyListeners();
    }
  }
}
