import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daily_life_tracker/providers/task_provider.dart';
import 'package:daily_life_tracker/providers/achievements_provider.dart';
import 'package:daily_life_tracker/services/task_service.dart';
import 'package:daily_life_tracker/models/task_model.dart';

import 'task_provider_test.mocks.dart';

@GenerateMocks([TaskService, AchievementsProvider])
void main() {
  group('TaskProvider Unit Tests', () {
    late TaskProvider taskProvider;
    late MockTaskService mockTaskService;
    late MockAchievementsProvider mockAchievementsProvider;

    setUp(() {
      mockTaskService = MockTaskService();
      mockAchievementsProvider = MockAchievementsProvider();
      taskProvider = TaskProvider();
      taskProvider.setAchievementsProvider(mockAchievementsProvider);
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(taskProvider.tasks, isEmpty);
        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.error, isNull);
      });
    });

    group('Initialize', () {
      test('should initialize tasks successfully', () async {
        final testTasks = [
          Task(
            id: '1',
            title: 'Test Task 1',
            category: 'work',
            priority: TaskPriority.high,
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Task(
            id: '2',
            title: 'Test Task 2',
            category: 'personal',
            priority: TaskPriority.medium,
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockTaskService.fetchTasks()).thenAnswer((_) async => testTasks);

        await taskProvider.initialize();

        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.error, isNull);
        expect(taskProvider.tasks.length, equals(2));
        expect(taskProvider.tasks[0].title, equals('Test Task 1'));
        expect(taskProvider.tasks[1].title, equals('Test Task 2'));
        verify(mockTaskService.fetchTasks()).called(1);
      });

      test('should handle initialize error', () async {
        when(mockTaskService.fetchTasks()).thenThrow(PostgrestException('Database error'));

        await taskProvider.initialize();

        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.error, equals('Database error'));
        expect(taskProvider.tasks, isEmpty);
      });

      test('should handle general initialize error', () async {
        when(mockTaskService.fetchTasks()).thenThrow(Exception('General error'));

        await taskProvider.initialize();

        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.error, equals('حدث خطأ غير متوقع'));
        expect(taskProvider.tasks, isEmpty);
      });

      test('should set loading state during initialize', () async {
        when(mockTaskService.fetchTasks()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        final future = taskProvider.initialize();

        expect(taskProvider.isLoading, isTrue);
        await future;
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('Toggle Task', () {
      setUp(() {
        final testTask = Task(
          id: '1',
          title: 'Test Task',
          category: 'work',
          priority: TaskPriority.high,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        
        when(mockTaskService.fetchTasks()).thenAnswer((_) async => [testTask]);
        when(mockTaskService.toggleTaskCompletion(any, any)).thenAnswer((_) async {});
        when(mockAchievementsProvider.addXP(any)).thenAnswer((_) async {});
      });

      test('should toggle task from incomplete to complete', () async {
        await taskProvider.initialize();
        
        await taskProvider.toggleTask('1');

        expect(taskProvider.tasks[0].isCompleted, isTrue);
        verify(mockTaskService.toggleTaskCompletion('1', true)).called(1);
        verify(mockAchievementsProvider.addXP(15)).called(1);
      });

      test('should toggle task from complete to incomplete', () async {
        final testTask = Task(
          id: '1',
          title: 'Test Task',
          category: 'work',
          priority: TaskPriority.high,
          isCompleted: true,
          createdAt: DateTime.now(),
        );
        
        when(mockTaskService.fetchTasks()).thenAnswer((_) async => [testTask]);
        when(mockTaskService.toggleTaskCompletion(any, any)).thenAnswer((_) async {});
        
        await taskProvider.initialize();
        await taskProvider.toggleTask('1');

        expect(taskProvider.tasks[0].isCompleted, isFalse);
        verify(mockTaskService.toggleTaskCompletion('1', false)).called(1);
        verifyNever(mockAchievementsProvider.addXP(any));
      });

      test('should handle toggle task error', () async {
        when(mockTaskService.toggleTaskCompletion(any, any))
            .thenThrow(PostgrestException('Toggle failed'));

        await taskProvider.initialize();
        final originalState = taskProvider.tasks[0].isCompleted;
        
        await taskProvider.toggleTask('1');

        expect(taskProvider.tasks[0].isCompleted, equals(originalState));
        expect(taskProvider.error, equals('Toggle failed'));
      });

      test('should handle general toggle task error', () async {
        when(mockTaskService.toggleTaskCompletion(any, any))
            .thenThrow(Exception('General error'));

        await taskProvider.initialize();
        final originalState = taskProvider.tasks[0].isCompleted;
        
        await taskProvider.toggleTask('1');

        expect(taskProvider.tasks[0].isCompleted, equals(originalState));
        expect(taskProvider.error, equals('حدث خطأ غير متوقع'));
      });

      test('should not toggle non-existent task', () async {
        await taskProvider.initialize();
        
        await taskProvider.toggleTask('non-existent');

        verifyNever(mockTaskService.toggleTaskCompletion(any, any));
      });

      test('should award correct XP based on task priority', () async {
        final highPriorityTask = Task(
          id: '1',
          title: 'High Priority Task',
          category: 'work',
          priority: TaskPriority.high,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        
        final mediumPriorityTask = Task(
          id: '2',
          title: 'Medium Priority Task',
          category: 'work',
          priority: TaskPriority.medium,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        
        final lowPriorityTask = Task(
          id: '3',
          title: 'Low Priority Task',
          category: 'work',
          priority: TaskPriority.low,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        
        when(mockTaskService.fetchTasks()).thenAnswer((_) async => [
          highPriorityTask, mediumPriorityTask, lowPriorityTask
        ]);
        when(mockTaskService.toggleTaskCompletion(any, any)).thenAnswer((_) async {});
        
        await taskProvider.initialize();
        
        await taskProvider.toggleTask('1');
        verify(mockAchievementsProvider.addXP(15)).called(1);
        
        await taskProvider.toggleTask('2');
        verify(mockAchievementsProvider.addXP(10)).called(1);
        
        await taskProvider.toggleTask('3');
        verify(mockAchievementsProvider.addXP(5)).called(1);
      });

      test('should not award XP when achievements provider is null', () async {
        taskProvider.setAchievementsProvider(null);
        
        await taskProvider.initialize();
        await taskProvider.toggleTask('1');

        verifyNever(mockAchievementsProvider.addXP(any));
      });
    });

    group('Get Tasks by Category', () {
      test('should filter tasks by category correctly', () async {
        final testTasks = [
          Task(
            id: '1',
            title: 'Work Task',
            category: 'work',
            priority: TaskPriority.high,
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Task(
            id: '2',
            title: 'Personal Task',
            category: 'personal',
            priority: TaskPriority.medium,
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Task(
            id: '3',
            title: 'Another Work Task',
            category: 'work',
            priority: TaskPriority.low,
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockTaskService.fetchTasks()).thenAnswer((_) async => testTasks);

        await taskProvider.initialize();

        final workTasks = taskProvider.getTasksByCategory('work');
        final personalTasks = taskProvider.getTasksByCategory('personal');
        final healthTasks = taskProvider.getTasksByCategory('health');

        expect(workTasks.length, equals(2));
        expect(personalTasks.length, equals(1));
        expect(healthTasks.length, equals(0));
        expect(workTasks[0].title, equals('Work Task'));
        expect(workTasks[1].title, equals('Another Work Task'));
        expect(personalTasks[0].title, equals('Personal Task'));
      });
    });

    group('Get Completion Percentage', () {
      test('should calculate completion percentage correctly', () async {
        final testTasks = [
          Task(
            id: '1',
            title: 'Task 1',
            category: 'work',
            priority: TaskPriority.high,
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
          Task(
            id: '2',
            title: 'Task 2',
            category: 'work',
            priority: TaskPriority.medium,
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Task(
            id: '3',
            title: 'Task 3',
            category: 'work',
            priority: TaskPriority.low,
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockTaskService.fetchTasks()).thenAnswer((_) async => testTasks);

        await taskProvider.initialize();

        expect(taskProvider.getCompletionPercentage(), equals(2.0 / 3.0));
      });

      test('should return 0 for empty tasks list', () async {
        when(mockTaskService.fetchTasks()).thenAnswer((_) async => []);

        await taskProvider.initialize();

        expect(taskProvider.getCompletionPercentage(), equals(0.0));
      });

      test('should return 1.0 for all completed tasks', () async {
        final testTasks = [
          Task(
            id: '1',
            title: 'Task 1',
            category: 'work',
            priority: TaskPriority.high,
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
          Task(
            id: '2',
            title: 'Task 2',
            category: 'work',
            priority: TaskPriority.medium,
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockTaskService.fetchTasks()).thenAnswer((_) async => testTasks);

        await taskProvider.initialize();

        expect(taskProvider.getCompletionPercentage(), equals(1.0));
      });
    });

    group('Add Task', () {
      test('should add task successfully', () async {
        final newTask = Task(
          id: '3',
          title: 'New Task',
          category: 'work',
          priority: TaskPriority.high,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        
        final allTasks = [
          Task(
            id: '1',
            title: 'Task 1',
            category: 'work',
            priority: TaskPriority.high,
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          newTask,
        ];
        
        when(mockTaskService.createTask(any)).thenAnswer((_) async {});
        when(mockTaskService.fetchTasks()).thenAnswer((_) async => allTasks);

        await taskProvider.addTask(newTask);

        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.error, isNull);
        expect(taskProvider.tasks.length, equals(2));
        verify(mockTaskService.createTask(newTask)).called(1);
        verify(mockTaskService.fetchTasks()).called(1);
      });

      test('should handle add task error', () async {
        final newTask = Task(
          id: '3',
          title: 'New Task',
          category: 'work',
          priority: TaskPriority.high,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        
        when(mockTaskService.createTask(any)).thenThrow(PostgrestException('Create failed'));

        expect(() async => await taskProvider.addTask(newTask), throwsException);
        expect(taskProvider.error, equals('Create failed'));
      });

      test('should throw exception for empty task title', () async {
        final newTask = Task(
          id: '3',
          title: '',
          category: 'work',
          priority: TaskPriority.high,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        expect(() async => await taskProvider.addTask(newTask), 
               throwsA(isA<Exception>().having(
                 (e) => e.toString(), 
                 'message', 
                 contains('Task title cannot be empty'))));
      });

      test('should throw exception for empty task category', () async {
        final newTask = Task(
          id: '3',
          title: 'New Task',
          category: '',
          priority: TaskPriority.high,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        expect(() async => await taskProvider.addTask(newTask), 
               throwsA(isA<Exception>().having(
                 (e) => e.toString(), 
                 'message', 
                 contains('Task category cannot be empty'))));
      });

      test('should set loading state during add task', () async {
        final newTask = Task(
          id: '3',
          title: 'New Task',
          category: 'work',
          priority: TaskPriority.high,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        
        when(mockTaskService.createTask(any)).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });
        when(mockTaskService.fetchTasks()).thenAnswer((_) async => []);

        final future = taskProvider.addTask(newTask);

        expect(taskProvider.isLoading, isTrue);
        await future;
        expect(taskProvider.isLoading, isFalse);
      });
    });

    group('Refresh Tasks', () {
      test('should refresh tasks successfully', () async {
        final refreshedTasks = [
          Task(
            id: '1',
            title: 'Refreshed Task 1',
            category: 'work',
            priority: TaskPriority.high,
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockTaskService.fetchTasks()).thenAnswer((_) async => refreshedTasks);

        await taskProvider.refreshTasks();

        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.error, isNull);
        expect(taskProvider.tasks.length, equals(1));
        expect(taskProvider.tasks[0].title, equals('Refreshed Task 1'));
        verify(mockTaskService.fetchTasks()).called(1);
      });

      test('should handle refresh tasks error', () async {
        when(mockTaskService.fetchTasks()).thenThrow(PostgrestException('Refresh failed'));

        await taskProvider.refreshTasks();

        expect(taskProvider.isLoading, isFalse);
        expect(taskProvider.error, equals('Refresh failed'));
      });
    });

    group('Clear Error', () {
      test('should clear error message', () async {
        when(mockTaskService.fetchTasks()).thenThrow(PostgrestException('Test error'));

        await taskProvider.initialize();
        expect(taskProvider.error, equals('Test error'));

        taskProvider.clearError();
        expect(taskProvider.error, isNull);
      });
    });

    group('Set Achievements Provider', () {
      test('should set achievements provider', () {
        taskProvider.setAchievementsProvider(mockAchievementsProvider);
        expect(taskProvider._achievementsProvider, equals(mockAchievementsProvider));
      });
    });
  });
}
