import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:daily_life_tracker/providers/project_provider.dart';
import 'package:daily_life_tracker/providers/achievements_provider.dart';
import 'package:daily_life_tracker/services/project_service.dart';
import 'package:daily_life_tracker/models/project_model.dart';

import 'project_provider_test.mocks.dart';

@GenerateMocks([ProjectService, AchievementsProvider])
void main() {
  group('ProjectProvider Unit Tests', () {
    late ProjectProvider projectProvider;
    late MockProjectService mockProjectService;
    late MockAchievementsProvider mockAchievementsProvider;

    setUp(() {
      mockProjectService = MockProjectService();
      mockAchievementsProvider = MockAchievementsProvider();
      projectProvider = ProjectProvider();
      projectProvider.setAchievementsProvider(mockAchievementsProvider);
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(projectProvider.projects, isEmpty);
        expect(projectProvider.isLoading, isFalse);
        expect(projectProvider.error, isNull);
        expect(projectProvider.activeProjects, isEmpty);
        expect(projectProvider.pausedProjects, isEmpty);
        expect(projectProvider.completedProjects, isEmpty);
      });
    });

    group('Load Projects', () {
      test('should load projects successfully', () async {
        final testProjects = [
          Project(
            id: '1',
            title: 'Active Project',
            description: 'Test project',
            status: ProjectStatus.active,
            progress: 0.5,
            createdAt: DateTime.now(),
          ),
          Project(
            id: '2',
            title: 'Completed Project',
            description: 'Test project',
            status: ProjectStatus.completed,
            progress: 1.0,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => testProjects);

        await projectProvider.loadProjects();

        expect(projectProvider.projects.length, equals(2));
        expect(projectProvider.activeProjects.length, equals(1));
        expect(projectProvider.completedProjects.length, equals(1));
        expect(projectProvider.activeProjects[0].title, equals('Active Project'));
        expect(projectProvider.completedProjects[0].title, equals('Completed Project'));
        verify(mockProjectService.fetchProjects()).called(1);
      });

      test('should handle load projects error', () async {
        when(mockProjectService.fetchProjects()).thenThrow(Exception('Load failed'));

        await projectProvider.loadProjects();

        expect(projectProvider.projects, isEmpty);
        expect(projectProvider.error, isNotNull);
      });
    });

    group('Toggle Project Status', () {
      setUp(() {
        final testProject = Project(
          id: '1',
          title: 'Test Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.5,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [testProject]);
        when(mockProjectService.toggleProjectStatus(any, any)).thenAnswer((_) async {});
      });

      test('should toggle from active to paused', () async {
        await projectProvider.loadProjects();
        
        await projectProvider.toggleProjectStatus('1');

        expect(projectProvider.projects[0].status, equals(ProjectStatus.paused));
        verify(mockProjectService.toggleProjectStatus('1', ProjectStatus.paused)).called(1);
      });

      test('should toggle from paused to active', () async {
        final pausedProject = Project(
          id: '1',
          title: 'Test Project',
          description: 'Test project',
          status: ProjectStatus.paused,
          progress: 0.5,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [pausedProject]);
        
        await projectProvider.loadProjects();
        await projectProvider.toggleProjectStatus('1');

        expect(projectProvider.projects[0].status, equals(ProjectStatus.active));
        verify(mockProjectService.toggleProjectStatus('1', ProjectStatus.active)).called(1);
      });

      test('should toggle from completed to active', () async {
        final completedProject = Project(
          id: '1',
          title: 'Test Project',
          description: 'Test project',
          status: ProjectStatus.completed,
          progress: 1.0,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [completedProject]);
        
        await projectProvider.loadProjects();
        await projectProvider.toggleProjectStatus('1');

        expect(projectProvider.projects[0].status, equals(ProjectStatus.active));
        verify(mockProjectService.toggleProjectStatus('1', ProjectStatus.active)).called(1);
      });

      test('should handle toggle status error', () async {
        when(mockProjectService.toggleProjectStatus(any, any))
            .thenThrow(Exception('Toggle failed'));

        await projectProvider.loadProjects();
        final originalStatus = projectProvider.projects[0].status;
        
        await projectProvider.toggleProjectStatus('1');

        expect(projectProvider.projects[0].status, equals(originalStatus));
        expect(projectProvider.error, isNotNull);
      });

      test('should not toggle non-existent project', () async {
        await projectProvider.loadProjects();
        
        await projectProvider.toggleProjectStatus('non-existent');

        verifyNever(mockProjectService.toggleProjectStatus(any, any));
      });
    });

    group('Update Project Progress', () {
      setUp(() {
        final testProject = Project(
          id: '1',
          title: 'Test Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.5,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [testProject]);
        when(mockProjectService.updateProjectProgress(any, any)).thenAnswer((_) async {});
        when(mockProjectService.toggleProjectStatus(any, any)).thenAnswer((_) async {});
        when(mockAchievementsProvider.addXP(any)).thenAnswer((_) async {});
      });

      test('should update progress successfully', () async {
        await projectProvider.loadProjects();
        
        await projectProvider.updateProjectProgress('1', 0.75);

        expect(projectProvider.projects[0].progress, equals(0.75));
        expect(projectProvider.projects[0].status, equals(ProjectStatus.active));
        verify(mockProjectService.updateProjectProgress('1', 0.75)).called(1);
        verifyNever(mockAchievementsProvider.addXP(any));
      });

      test('should auto-complete project when progress reaches 100%', () async {
        await projectProvider.loadProjects();
        
        await projectProvider.updateProjectProgress('1', 1.0);

        expect(projectProvider.projects[0].progress, equals(1.0));
        expect(projectProvider.projects[0].status, equals(ProjectStatus.completed));
        expect(projectProvider.projects[0].statusMessage, equals('مكتمل بنجاح'));
        verify(mockProjectService.updateProjectProgress('1', 1.0)).called(1);
        verify(mockProjectService.toggleProjectStatus('1', ProjectStatus.completed)).called(1);
        verify(mockAchievementsProvider.addXP(any)).called(1);
      });

      test('should not award XP if project was already completed', () async {
        final completedProject = Project(
          id: '1',
          title: 'Test Project',
          description: 'Test project',
          status: ProjectStatus.completed,
          progress: 1.0,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [completedProject]);
        
        await projectProvider.loadProjects();
        await projectProvider.updateProjectProgress('1', 1.0);

        verifyNever(mockAchievementsProvider.addXP(any));
      });

      test('should handle update progress error', () async {
        when(mockProjectService.updateProjectProgress(any, any))
            .thenThrow(Exception('Update failed'));

        await projectProvider.loadProjects();
        final originalProgress = projectProvider.projects[0].progress;
        
        await projectProvider.updateProjectProgress('1', 0.75);

        expect(projectProvider.projects[0].progress, equals(originalProgress));
        expect(projectProvider.error, isNotNull);
      });

      test('should not update non-existent project', () async {
        await projectProvider.loadProjects();
        
        await projectProvider.updateProjectProgress('non-existent', 0.75);

        verifyNever(mockProjectService.updateProjectProgress(any, any));
      });
    });

    group('Calculate XP for Project', () {
      test('should calculate base XP correctly', () async {
        final simpleProject = Project(
          id: '1',
          title: 'Simple Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.5,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [simpleProject]);
        when(mockProjectService.updateProjectProgress(any, any)).thenAnswer((_) async {});
        when(mockProjectService.toggleProjectStatus(any, any)).thenAnswer((_) async {});
        when(mockAchievementsProvider.addXP(any)).thenAnswer((_) async {});
        
        await projectProvider.loadProjects();
        await projectProvider.updateProjectProgress('1', 1.0);

        verify(mockAchievementsProvider.addXP(50)).called(1);
      });

      test('should calculate XP with subtasks bonus', () async {
        final projectWithSubtasks = Project(
          id: '1',
          title: 'Complex Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.5,
          subtasks: [
            Subtask(id: '1', title: 'Subtask 1', isCompleted: true),
            Subtask(id: '2', title: 'Subtask 2', isCompleted: false),
            Subtask(id: '3', title: 'Subtask 3', isCompleted: true),
          ],
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [projectWithSubtasks]);
        when(mockProjectService.updateProjectProgress(any, any)).thenAnswer((_) async {});
        when(mockProjectService.toggleProjectStatus(any, any)).thenAnswer((_) async {});
        when(mockAchievementsProvider.addXP(any)).thenAnswer((_) async {});
        
        await projectProvider.loadProjects();
        await projectProvider.updateProjectProgress('1', 1.0);

        verify(mockAchievementsProvider.addXP(80)).called(1); // 50 base + 30 subtasks bonus
      });

      test('should calculate XP with duration bonus', () async {
        final longProject = Project(
          id: '1',
          title: 'Long Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.5,
          startDate: DateTime.now().subtract(Duration(days: 21)),
          endDate: DateTime.now().add(Duration(days: 7)),
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [longProject]);
        when(mockProjectService.updateProjectProgress(any, any)).thenAnswer((_) async {});
        when(mockProjectService.toggleProjectStatus(any, any)).thenAnswer((_) async {});
        when(mockAchievementsProvider.addXP(any)).thenAnswer((_) async {});
        
        await projectProvider.loadProjects();
        await projectProvider.updateProjectProgress('1', 1.0);

        verify(mockAchievementsProvider.addXP(65)).called(1); // 50 base + 15 duration bonus
      });

      test('should calculate XP with all bonuses', () async {
        final complexProject = Project(
          id: '1',
          title: 'Complex Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.5,
          subtasks: [
            Subtask(id: '1', title: 'Subtask 1', isCompleted: true),
            Subtask(id: '2', title: 'Subtask 2', isCompleted: false),
          ],
          startDate: DateTime.now().subtract(Duration(days: 14)),
          endDate: DateTime.now().add(Duration(days: 14)),
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [complexProject]);
        when(mockProjectService.updateProjectProgress(any, any)).thenAnswer((_) async {});
        when(mockProjectService.toggleProjectStatus(any, any)).thenAnswer((_) async {});
        when(mockAchievementsProvider.addXP(any)).thenAnswer((_) async {});
        
        await projectProvider.loadProjects();
        await projectProvider.updateProjectProgress('1', 1.0);

        verify(mockAchievementsProvider.addXP(80)).called(1); // 50 base + 20 subtasks + 10 duration
      });
    });

    group('Add Project', () {
      test('should add project successfully', () async {
        final newProject = Project(
          id: '1',
          title: 'New Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.0,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.createProject(any)).thenAnswer((_) async => '1');

        await projectProvider.addProject(newProject);

        expect(projectProvider.isLoading, isFalse);
        expect(projectProvider.error, isNull);
        expect(projectProvider.projects.length, equals(1));
        expect(projectProvider.projects[0].id, equals('1'));
        verify(mockProjectService.createProject(newProject)).called(1);
      });

      test('should handle add project error', () async {
        final newProject = Project(
          id: '1',
          title: 'New Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.0,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.createProject(any)).thenThrow(Exception('Create failed'));

        expect(() async => await projectProvider.addProject(newProject), throwsException);
        expect(projectProvider.error, isNotNull);
      });

      test('should set loading state during add project', () async {
        final newProject = Project(
          id: '1',
          title: 'New Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.0,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.createProject(any)).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return '1';
        });

        final future = projectProvider.addProject(newProject);

        expect(projectProvider.isLoading, isTrue);
        await future;
        expect(projectProvider.isLoading, isFalse);
      });
    });

    group('Update Project', () {
      test('should update project successfully', () async {
        final originalProject = Project(
          id: '1',
          title: 'Original Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.5,
          createdAt: DateTime.now(),
        );
        
        final updatedProject = Project(
          id: '1',
          title: 'Updated Project',
          description: 'Updated project',
          status: ProjectStatus.active,
          progress: 0.75,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [originalProject]);
        when(mockProjectService.updateProject(any)).thenAnswer((_) async {});

        await projectProvider.loadProjects();
        await projectProvider.updateProject(updatedProject);

        expect(projectProvider.projects[0].title, equals('Updated Project'));
        expect(projectProvider.projects[0].description, equals('Updated project'));
        expect(projectProvider.projects[0].progress, equals(0.75));
        verify(mockProjectService.updateProject(updatedProject)).called(1);
      });

      test('should handle update project error', () async {
        final originalProject = Project(
          id: '1',
          title: 'Original Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.5,
          createdAt: DateTime.now(),
        );
        
        final updatedProject = Project(
          id: '1',
          title: 'Updated Project',
          description: 'Updated project',
          status: ProjectStatus.active,
          progress: 0.75,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [originalProject]);
        when(mockProjectService.updateProject(any)).thenThrow(Exception('Update failed'));

        await projectProvider.loadProjects();

        expect(() async => await projectProvider.updateProject(updatedProject), throwsException);
        expect(projectProvider.error, isNotNull);
      });

      test('should not update non-existent project', () async {
        final updatedProject = Project(
          id: 'non-existent',
          title: 'Updated Project',
          description: 'Updated project',
          status: ProjectStatus.active,
          progress: 0.75,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.updateProject(any)).thenAnswer((_) async {});

        await projectProvider.updateProject(updatedProject);

        verifyNever(mockProjectService.updateProject(any));
      });
    });

    group('Delete Project', () {
      test('should delete project successfully', () async {
        final project = Project(
          id: '1',
          title: 'Test Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.5,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [project]);
        when(mockProjectService.deleteProject(any)).thenAnswer((_) async {});

        await projectProvider.loadProjects();
        await projectProvider.deleteProject('1');

        expect(projectProvider.projects, isEmpty);
        verify(mockProjectService.deleteProject('1')).called(1);
      });

      test('should handle delete project error', () async {
        final project = Project(
          id: '1',
          title: 'Test Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.5,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [project]);
        when(mockProjectService.deleteProject(any)).thenThrow(Exception('Delete failed'));

        await projectProvider.loadProjects();

        expect(() async => await projectProvider.deleteProject('1'), throwsException);
        expect(projectProvider.error, isNotNull);
      });
    });

    group('Get Project by ID', () {
      test('should return project when found', () async {
        final project = Project(
          id: '1',
          title: 'Test Project',
          description: 'Test project',
          status: ProjectStatus.active,
          progress: 0.5,
          createdAt: DateTime.now(),
        );
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => [project]);

        await projectProvider.loadProjects();

        final foundProject = projectProvider.getProjectById('1');
        expect(foundProject, isNotNull);
        expect(foundProject!.title, equals('Test Project'));
      });

      test('should return null when not found', () async {
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => []);

        await projectProvider.loadProjects();

        final foundProject = projectProvider.getProjectById('non-existent');
        expect(foundProject, isNull);
      });
    });

    group('Get Monthly Progress', () {
      test('should calculate monthly progress correctly', () async {
        final projects = [
          Project(
            id: '1',
            title: 'Project 1',
            description: 'Test project',
            status: ProjectStatus.active,
            progress: 0.5,
            createdAt: DateTime.now(),
          ),
          Project(
            id: '2',
            title: 'Project 2',
            description: 'Test project',
            status: ProjectStatus.active,
            progress: 0.75,
            createdAt: DateTime.now(),
          ),
          Project(
            id: '3',
            title: 'Project 3',
            description: 'Test project',
            status: ProjectStatus.completed,
            progress: 1.0,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => projects);

        await projectProvider.loadProjects();

        expect(projectProvider.getMonthlyProgress(), equals(0.625)); // (0.5 + 0.75) / 2
      });

      test('should return 0 when no active projects', () async {
        final projects = [
          Project(
            id: '1',
            title: 'Completed Project',
            description: 'Test project',
            status: ProjectStatus.completed,
            progress: 1.0,
            createdAt: DateTime.now(),
          ),
          Project(
            id: '2',
            title: 'Paused Project',
            description: 'Test project',
            status: ProjectStatus.paused,
            progress: 0.5,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => projects);

        await projectProvider.loadProjects();

        expect(projectProvider.getMonthlyProgress(), equals(0.0));
      });
    });

    group('Project Counts', () {
      test('should return correct project counts', () async {
        final projects = [
          Project(
            id: '1',
            title: 'Active Project 1',
            description: 'Test project',
            status: ProjectStatus.active,
            progress: 0.5,
            createdAt: DateTime.now(),
          ),
          Project(
            id: '2',
            title: 'Active Project 2',
            description: 'Test project',
            status: ProjectStatus.active,
            progress: 0.75,
            createdAt: DateTime.now(),
          ),
          Project(
            id: '3',
            title: 'Paused Project',
            description: 'Test project',
            status: ProjectStatus.paused,
            progress: 0.3,
            createdAt: DateTime.now(),
          ),
          Project(
            id: '4',
            title: 'Completed Project',
            description: 'Test project',
            status: ProjectStatus.completed,
            progress: 1.0,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => projects);

        await projectProvider.loadProjects();

        expect(projectProvider.activeProjectsCount, equals(2));
        expect(projectProvider.pausedProjectsCount, equals(1));
        expect(projectProvider.completedProjectsCount, equals(1));
      });
    });

    group('Refresh Projects', () {
      test('should refresh projects successfully', () async {
        final refreshedProjects = [
          Project(
            id: '1',
            title: 'Refreshed Project',
            description: 'Test project',
            status: ProjectStatus.active,
            progress: 0.8,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockProjectService.fetchProjects()).thenAnswer((_) async => refreshedProjects);

        await projectProvider.refreshProjects();

        expect(projectProvider.isLoading, isFalse);
        expect(projectProvider.projects.length, equals(1));
        expect(projectProvider.projects[0].title, equals('Refreshed Project'));
        verify(mockProjectService.fetchProjects()).called(1);
      });

      test('should handle refresh projects error', () async {
        when(mockProjectService.fetchProjects()).thenThrow(Exception('Refresh failed'));

        expect(() async => await projectProvider.refreshProjects(), throwsException);
        expect(projectProvider.error, isNotNull);
      });

      test('should set loading state during refresh', () async {
        when(mockProjectService.fetchProjects()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        final future = projectProvider.refreshProjects();

        expect(projectProvider.isLoading, isTrue);
        await future;
        expect(projectProvider.isLoading, isFalse);
      });
    });

    group('Generate Project ID', () {
      test('should generate unique project IDs', () {
        final id1 = projectProvider.generateProjectId();
        final id2 = projectProvider.generateProjectId();

        expect(id1, isNot(equals(id2)));
        expect(id1, isA<String>());
        expect(id2, isA<String>());
      });
    });

    group('Clear Error', () {
      test('should clear error message', () async {
        when(mockProjectService.fetchProjects()).thenThrow(Exception('Test error'));

        await projectProvider.loadProjects();
        expect(projectProvider.error, isNotNull);

        projectProvider.clearError();
        expect(projectProvider.error, isNull);
      });
    });

    group('Set Achievements Provider', () {
      test('should set achievements provider', () {
        projectProvider.setAchievementsProvider(mockAchievementsProvider);
        expect(projectProvider._achievementsProvider, equals(mockAchievementsProvider));
      });
    });
  });
}
