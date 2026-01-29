import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daily_life_tracker/providers/stats_provider.dart';
import 'package:daily_life_tracker/providers/task_provider.dart';
import 'package:daily_life_tracker/providers/project_provider.dart';
import 'package:daily_life_tracker/providers/water_provider.dart';
import 'package:daily_life_tracker/providers/achievements_provider.dart';
import 'package:daily_life_tracker/services/stats_service.dart';
import 'package:daily_life_tracker/services/reports_service.dart';
import 'package:daily_life_tracker/services/project_service.dart';
import 'package:daily_life_tracker/models/task_model.dart';
import 'package:daily_life_tracker/models/project_model.dart';
import 'package:daily_life_tracker/models/report_model.dart';
import 'package:daily_life_tracker/models/user_level_model.dart';

import 'stats_provider_test.mocks.dart';

@GenerateMocks([
  StatsService,
  ReportsService,
  ProjectService,
  TaskProvider,
  ProjectProvider,
  WaterProvider,
  AchievementsProvider,
  UserLevelModel,
])
void main() {
  group('StatsProvider Unit Tests', () {
    late StatsProvider statsProvider;
    late MockStatsService mockStatsService;
    late MockReportsService mockReportsService;
    late MockProjectService mockProjectService;
    late MockTaskProvider mockTaskProvider;
    late MockProjectProvider mockProjectProvider;
    late MockWaterProvider mockWaterProvider;
    late MockAchievementsProvider mockAchievementsProvider;

    setUp(() {
      mockStatsService = MockStatsService();
      mockReportsService = MockReportsService();
      mockProjectService = MockProjectService();
      mockTaskProvider = MockTaskProvider();
      mockProjectProvider = MockProjectProvider();
      mockWaterProvider = MockWaterProvider();
      mockAchievementsProvider = MockAchievementsProvider();
      
      statsProvider = StatsProvider();
      statsProvider.setProviders(
        mockTaskProvider,
        mockProjectProvider,
        mockWaterProvider,
        mockAchievementsProvider,
      );
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(statsProvider.isLoading, isFalse);
        expect(statsProvider.errorMessage, isNull);
      });
    });

    group('Set Providers', () {
      test('should set providers correctly', () {
        final newStatsProvider = StatsProvider();
        newStatsProvider.setProviders(
          mockTaskProvider,
          mockProjectProvider,
          mockWaterProvider,
          mockAchievementsProvider,
        );

        expect(newStatsProvider._taskProvider, equals(mockTaskProvider));
        expect(newStatsProvider._projectProvider, equals(mockProjectProvider));
        expect(newStatsProvider._waterProvider, equals(mockWaterProvider));
        expect(newStatsProvider._achievementsProvider, equals(mockAchievementsProvider));
      });

      test('should notify listeners when setting providers', () {
        final newStatsProvider = StatsProvider();
        
        var notificationCount = 0;
        newStatsProvider.addListener(() => notificationCount++);

        newStatsProvider.setProviders(
          mockTaskProvider,
          mockProjectProvider,
          mockWaterProvider,
          mockAchievementsProvider,
        );

        expect(notificationCount, greaterThan(0));
      });
    });

    group('Refresh Stats', () {
      test('should refresh stats successfully', () async {
        final mockTasks = [
          Task(
            id: '1',
            title: 'Completed Task',
            category: 'work',
            priority: TaskPriority.high,
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
          Task(
            id: '2',
            title: 'Incomplete Task',
            category: 'work',
            priority: TaskPriority.medium,
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ];
        
        final mockProjects = [
          Project(
            id: '1',
            title: 'Test Project',
            description: 'Test project',
            status: ProjectStatus.active,
            progress: 0.5,
            createdAt: DateTime.now(),
          ),
        ];
        
        final mockUserLevel = MockUserLevel();
        when(mockUserLevel.totalXP).thenReturn(100);
        
        when(mockTaskProvider.tasks).thenReturn(mockTasks);
        when(mockTaskProvider.getCompletionPercentage()).thenReturn(0.5);
        when(mockWaterProvider.currentIntakeMl).thenReturn(1000);
        when(mockProjectProvider.projects).thenReturn(mockProjects);
        when(mockAchievementsProvider.userLevel).thenReturn(mockUserLevel);
        when(mockProjectService.getTotalTimeSpent(any)).thenAnswer((_) async => 60);
        when(mockStatsService.saveDailyStats(
          completedTasksCount: anyNamed('completedTasksCount'),
          totalTasksCount: anyNamed('totalTasksCount'),
          waterIntakeMl: anyNamed('waterIntakeMl'),
          projectHours: anyNamed('projectHours'),
          completionPercentage: anyNamed('completionPercentage'),
          xpEarned: anyNamed('xpEarned'),
        )).thenAnswer((_) async {});

        await statsProvider.refreshStats();

        expect(statsProvider.isLoading, isFalse);
        expect(statsProvider.errorMessage, isNull);
        verify(mockStatsService.saveDailyStats(
          completedTasksCount: 1,
          totalTasksCount: 2,
          waterIntakeMl: 1000,
          projectHours: 1.0,
          completionPercentage: 50.0,
          xpEarned: 100,
        )).called(1);
      });

      test('should handle refresh stats error', () async {
        when(mockTaskProvider.tasks).thenReturn([]);
        when(mockTaskProvider.getCompletionPercentage()).thenReturn(0.0);
        when(mockWaterProvider.currentIntakeMl).thenReturn(0);
        when(mockProjectProvider.projects).thenReturn([]);
        when(mockAchievementsProvider.userLevel).thenReturn(null);
        when(mockStatsService.saveDailyStats(any)).thenThrow(Exception('Save failed'));

        await statsProvider.refreshStats();

        expect(statsProvider.isLoading, isFalse);
        expect(statsProvider.errorMessage, isNull);
      });

      test('should set loading state during refresh', () async {
        when(mockTaskProvider.tasks).thenReturn([]);
        when(mockTaskProvider.getCompletionPercentage()).thenReturn(0.0);
        when(mockWaterProvider.currentIntakeMl).thenReturn(0);
        when(mockProjectProvider.projects).thenReturn([]);
        when(mockAchievementsProvider.userLevel).thenReturn(null);
        when(mockStatsService.saveDailyStats(any)).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });

        final future = statsProvider.refreshStats();

        expect(statsProvider.isLoading, isTrue);
        await future;
        expect(statsProvider.isLoading, isFalse);
      });
    });

    group('Get Weekly Productivity', () {
      test('should get weekly productivity successfully', () async {
        final expectedResult = {'percentage': 0.75, 'trend': 0.1};
        when(mockReportsService.calculateWeeklyProductivityFromReport())
            .thenAnswer((_) async => expectedResult);

        final result = await statsProvider.getWeeklyProductivity();

        expect(result, equals(expectedResult));
        verify(mockReportsService.calculateWeeklyProductivityFromReport()).called(1);
      });

      test('should handle weekly productivity error and use fallback', () async {
        when(mockReportsService.calculateWeeklyProductivityFromReport())
            .thenThrow(PostgrestException('Report error'));
        when(mockStatsService.calculateWeeklyProductivity()).thenAnswer((_) async => 0.6);

        final result = await statsProvider.getWeeklyProductivity();

        expect(result, equals({'percentage': 0.6, 'trend': 0.0}));
        verify(mockReportsService.calculateWeeklyProductivityFromReport()).called(1);
        verify(mockStatsService.calculateWeeklyProductivity()).called(1);
      });

      test('should handle fallback error', () async {
        when(mockReportsService.calculateWeeklyProductivityFromReport())
            .thenThrow(PostgrestException('Report error'));
        when(mockStatsService.calculateWeeklyProductivity()).thenThrow(Exception('Fallback error'));

        final result = await statsProvider.getWeeklyProductivity();

        expect(result, equals({'percentage': 0.0, 'trend': 0.0}));
      });

      test('should throw StatsException on report error', () async {
        when(mockReportsService.calculateWeeklyProductivityFromReport())
            .thenThrow(PostgrestException('Report error'));
        when(mockStatsService.calculateWeeklyProductivity()).thenAnswer((_) async => 0.6);

        expect(() async => await statsProvider.getWeeklyProductivity(), 
               throwsA(isA<StatsException>()));
      });
    });

    group('Build Weekly Stats From Reports', () {
      test('should build weekly stats correctly', () {
        final reports = [
          DailyReportModel(
            id: '1',
            date: DateTime(2024, 1, 15), // Monday
            weekdayIndex: DateTime.monday,
            completionPercentage: 0.8,
            totalTasks: 5,
            completedTasks: 4,
          ),
          DailyReportModel(
            id: '2',
            date: DateTime(2024, 1, 16), // Tuesday
            weekdayIndex: DateTime.tuesday,
            completionPercentage: 0.6,
            totalTasks: 5,
            completedTasks: 3,
          ),
        ];

        final result = StatsProvider.buildWeeklyStatsFromReports(
          reports,
          now: DateTime(2024, 1, 16), // Tuesday
        );

        expect(result.length, equals(7));
        expect(result[0].dayName, equals('السبت'));
        expect(result[1].dayName, equals('الأحد'));
        expect(result[2].dayName, equals('الإثنين'));
        expect(result[2].percentage, equals(0.8));
        expect(result[3].dayName, equals('الثلاثاء'));
        expect(result[3].percentage, equals(0.6));
        expect(result[3].isToday, isTrue);
      });

      test('should handle empty reports', () {
        final result = StatsProvider.buildWeeklyStatsFromReports([]);

        expect(result.length, equals(7));
        expect(result.every((stat) => stat.percentage == 0.0), isTrue);
      });

      test('should handle invalid weekday index', () {
        final reports = [
          DailyReportModel(
            id: '1',
            date: DateTime.now(),
            weekdayIndex: 8, // Invalid
            completionPercentage: 0.8,
            totalTasks: 5,
            completedTasks: 4,
          ),
        ];

        final result = StatsProvider.buildWeeklyStatsFromReports(reports);

        expect(result.length, equals(7));
        expect(result.every((stat) => stat.percentage == 0.0), isTrue);
      });
    });

    group('Get Completed Tasks Count', () {
      test('should return correct completed tasks count', () {
        final mockTasks = [
          Task(id: '1', title: 'Task 1', category: 'work', priority: TaskPriority.high, isCompleted: true, createdAt: DateTime.now()),
          Task(id: '2', title: 'Task 2', category: 'work', priority: TaskPriority.medium, isCompleted: false, createdAt: DateTime.now()),
          Task(id: '3', title: 'Task 3', category: 'work', priority: TaskPriority.low, isCompleted: true, createdAt: DateTime.now()),
        ];
        
        when(mockTaskProvider.tasks).thenReturn(mockTasks);

        final count = statsProvider.getCompletedTasksCount();

        expect(count, equals(2));
      });

      test('should return 0 for empty tasks list', () {
        when(mockTaskProvider.tasks).thenReturn([]);

        final count = statsProvider.getCompletedTasksCount();

        expect(count, equals(0));
      });
    });

    group('Get Task Completion Percentage', () {
      test('should return correct completion percentage', () {
        when(mockTaskProvider.getCompletionPercentage()).thenReturn(0.75);

        final percentage = statsProvider.getTaskCompletionPercentage();

        expect(percentage, equals(75.0));
      });

      test('should return 0 when no tasks', () {
        when(mockTaskProvider.getCompletionPercentage()).thenReturn(0.0);

        final percentage = statsProvider.getTaskCompletionPercentage();

        expect(percentage, equals(0.0));
      });
    });

    group('Error Handling', () {
      test('should handle multiple consecutive errors', () async {
        when(mockReportsService.calculateWeeklyProductivityFromReport())
            .thenThrow(PostgrestException('Error 1'));

        expect(() async => await statsProvider.getWeeklyProductivity(), 
               throwsA(isA<StatsException>()));

        when(mockReportsService.fetchProjectsReport())
            .thenThrow(PostgrestException('Error 2'));

        expect(() async => await statsProvider.getProjectsOverview(), 
               throwsA(isA<StatsException>()));
      });

      test('should set error message correctly', () async {
        when(mockReportsService.calculateWeeklyProductivityFromReport())
            .thenThrow(PostgrestException('Report error'));
        when(mockStatsService.calculateWeeklyProductivity()).thenAnswer((_) async => 0.6);

        try {
          await statsProvider.getWeeklyProductivity();
        } catch (e) {
          expect(statsProvider.errorMessage, isNotNull);
        }
      });

      test('should not set same error message twice', () async {
        when(mockReportsService.calculateWeeklyProductivityFromReport())
            .thenThrow(PostgrestException('Report error'));
        when(mockStatsService.calculateWeeklyProductivity()).thenAnswer((_) async => 0.6);

        try {
          await statsProvider.getWeeklyProductivity();
        } catch (e) {
          final firstError = statsProvider.errorMessage;
          
          try {
            await statsProvider.getWeeklyProductivity();
          } catch (e2) {
            expect(statsProvider.errorMessage, equals(firstError));
          }
        }
      });
    });

    group('Static Methods', () {
      test('should convert weekday to index correctly', () {
        expect(StatsProvider._weekdayToIndex(DateTime.saturday), equals(0));
        expect(StatsProvider._weekdayToIndex(DateTime.sunday), equals(1));
        expect(StatsProvider._weekdayToIndex(DateTime.monday), equals(2));
        expect(StatsProvider._weekdayToIndex(DateTime.tuesday), equals(3));
        expect(StatsProvider._weekdayToIndex(DateTime.wednesday), equals(4));
        expect(StatsProvider._weekdayToIndex(DateTime.thursday), equals(5));
        expect(StatsProvider._weekdayToIndex(DateTime.friday), equals(6));
        expect(StatsProvider._weekdayToIndex(8), isNull);
      });

      test('should build default weekly stats correctly', () {
        final monday = DateTime(2024, 1, 15); // Monday
        final result = StatsProvider._buildDefaultWeeklyStats(monday);

        expect(result.length, equals(7));
        expect(result[0].dayName, equals('السبت'));
        expect(result[1].dayName, equals('الأحد'));
        expect(result[2].dayName, equals('الإثنين'));
        expect(result[2].isToday, isTrue);
        expect(result[3].dayName, equals('الثلاثاء'));
        expect(result[4].dayName, equals('الأربعاء'));
        expect(result[5].dayName, equals('الخميس'));
        expect(result[6].dayName, equals('الجمعة'));
        expect(result.every((stat) => stat.percentage == 0.0), isTrue);
      });
    });

    group('StatsException', () {
      test('should create StatsException correctly', () {
        const message = 'Test error';
        final exception = StatsException(message);

        expect(exception.message, equals(message));
        expect(exception.toString(), equals(message));
      });
    });
  });
}
