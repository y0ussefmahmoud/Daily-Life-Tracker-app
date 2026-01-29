import 'package:flutter_test/flutter_test.dart';
import 'package:daily_life_tracker/models/report_model.dart';
import 'package:daily_life_tracker/providers/stats_provider.dart';
import 'package:daily_life_tracker/services/reports_service.dart';

class FakeReportsApi implements ReportsApi {
  FakeReportsApi({
    this.currentUserId,
    this.dailyReportHandler,
    this.projectsReportHandler,
  });

  @override
  String? currentUserId;

  DateTime? lastDailyStart;
  DateTime? lastDailyEnd;
  String? lastDailyUserId;
  String? lastProjectsUserId;

  Object? dailyError;
  Object? projectsError;

  List<Map<String, dynamic>> Function(DateTime startDate, DateTime endDate)?
      dailyReportHandler;
  List<Map<String, dynamic>> Function()? projectsReportHandler;

  @override
  Future<List<Map<String, dynamic>>> fetchDailyReport({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    lastDailyUserId = userId;
    lastDailyStart = startDate;
    lastDailyEnd = endDate;

    if (dailyError != null) {
      throw dailyError!;
    }

    return dailyReportHandler?.call(startDate, endDate) ?? [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProjectsReport({
    required String userId,
  }) async {
    lastProjectsUserId = userId;

    if (projectsError != null) {
      throw projectsError!;
    }

    return projectsReportHandler?.call() ?? [];
  }
}

bool _isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

void main() {
  test('buildWeeklyStatsFromReports uses date-based weekday mapping', () {
    final reports = [
      DailyReportModel(
        date: DateTime(2024, 1, 7),
        userId: 'user-1',
        completedTasksCount: 3,
        totalTasksCount: 4,
        completionPercentage: 75,
        waterIntakeMl: 900,
        projectHours: 1.5,
        xpEarned: 20,
        dayName: 'Sunday',
        weekNumber: 1,
      ),
      DailyReportModel(
        date: DateTime(2024, 1, 5),
        userId: 'user-1',
        completedTasksCount: 2,
        totalTasksCount: 4,
        completionPercentage: 50,
        waterIntakeMl: 700,
        projectHours: 1.0,
        xpEarned: 15,
        dayName: 'Friday',
        weekNumber: 1,
      ),
    ];

    final weeklyStats = StatsProvider.buildWeeklyStatsFromReports(reports);

    expect(weeklyStats[1].percentage, 75);
    expect(weeklyStats[6].percentage, 50);
  });

  test('fetchDailyReport maps response to model', () async {
    final api = FakeReportsApi(
      currentUserId: 'user-1',
      dailyReportHandler: (_, __) {
        return [
          {
            'date': '2024-01-01',
            'user_id': 'user-1',
            'completed_tasks_count': 4,
            'total_tasks_count': 5,
            'completion_percentage': 80,
            'water_intake_ml': 1200,
            'project_hours': 2.5,
            'xp_earned': 30,
            'day_name': 'الإثنين',
            'week_number': 1,
          }
        ];
      },
    );

    final service = ReportsService(api: api, userIdOverride: 'user-1');
    final result = await service.fetchDailyReport(
      DateTime(2024, 1, 1),
      DateTime(2024, 1, 7),
    );

    expect(result, hasLength(1));
    expect(result.first.completedTasksCount, 4);
    expect(result.first.totalTasksCount, 5);
    expect(result.first.completionPercentage, 80);
    expect(result.first.waterIntakeMl, 1200);
    expect(result.first.projectHours, 2.5);
    expect(result.first.xpEarned, 30);
    expect(result.first.dayName, 'الإثنين');
  });

  test('fetchWeeklyReport calculates week range', () async {
    final api = FakeReportsApi(currentUserId: 'user-1');
    final service = ReportsService(api: api, userIdOverride: 'user-1');

    final now = DateTime.now();
    final expectedStart = now.subtract(Duration(days: now.weekday - 1));
    final expectedEnd = expectedStart.add(const Duration(days: 6));

    await service.fetchWeeklyReport();

    expect(api.lastDailyUserId, 'user-1');
    expect(_isSameDay(api.lastDailyStart, expectedStart), isTrue);
    expect(_isSameDay(api.lastDailyEnd, expectedEnd), isTrue);
  });

  test('fetchProjectsReport maps project report data', () async {
    final api = FakeReportsApi(
      currentUserId: 'user-1',
      projectsReportHandler: () {
        return [
          {
            'project_id': 'p1',
            'project_name': 'مشروع التتبع',
            'status': 'active',
            'progress': 0.75,
            'total_time_spent': 12.5,
            'tech_stack': ['Flutter', 'Supabase'],
            'created_at': '2024-01-01T00:00:00.000Z',
            'last_updated': '2024-01-10T00:00:00.000Z',
          }
        ];
      },
    );

    final service = ReportsService(api: api, userIdOverride: 'user-1');
    final result = await service.fetchProjectsReport();

    expect(result, hasLength(1));
    expect(result.first.projectName, 'مشروع التتبع');
    expect(result.first.progress, 0.75);
    expect(result.first.techStack, ['Flutter', 'Supabase']);
  });

  test('fetchDailyReport returns empty list on error', () async {
    final api = FakeReportsApi(currentUserId: 'user-1')..dailyError = Exception('network');
    final service = ReportsService(api: api, userIdOverride: 'user-1');

    final result = await service.fetchDailyReport(
      DateTime(2024, 1, 1),
      DateTime(2024, 1, 7),
    );

    expect(result, isEmpty);
  });

  test('calculateWeeklyProductivityFromReport handles empty results', () async {
    final api = FakeReportsApi(
      currentUserId: 'user-1',
      dailyReportHandler: (_, __) => [],
    );
    final service = ReportsService(api: api, userIdOverride: 'user-1');

    final result = await service.calculateWeeklyProductivityFromReport();

    expect(result['percentage'], 0.0);
    expect(result['trend'], 0.0);
  });

  test('calculateWeeklyProductivityFromReport compares weeks', () async {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));

    final api = FakeReportsApi(
      currentUserId: 'user-1',
      dailyReportHandler: (startDate, _) {
        if (_isSameDay(startDate, currentWeekStart)) {
          return [
            {
              'date': currentWeekStart.toIso8601String(),
              'user_id': 'user-1',
              'completed_tasks_count': 3,
              'total_tasks_count': 4,
              'completion_percentage': 75,
              'water_intake_ml': 800,
              'project_hours': 1.5,
              'xp_earned': 20,
              'day_name': 'الإثنين',
              'week_number': 1,
            }
          ];
        }
        return [
          {
            'date': currentWeekStart.subtract(const Duration(days: 7)).toIso8601String(),
            'user_id': 'user-1',
            'completed_tasks_count': 2,
            'total_tasks_count': 4,
            'completion_percentage': 50,
            'water_intake_ml': 700,
            'project_hours': 1.0,
            'xp_earned': 15,
            'day_name': 'الإثنين',
            'week_number': 0,
          }
        ];
      },
    );

    final service = ReportsService(api: api, userIdOverride: 'user-1');
    final result = await service.calculateWeeklyProductivityFromReport();

    expect(result['percentage'], 75);
    expect(result['trend'], 25);
  });
}
