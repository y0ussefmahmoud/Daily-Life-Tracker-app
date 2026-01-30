import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stats_model.dart';
import '../models/task_model.dart';
import '../models/report_model.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/water_provider.dart';
import '../providers/achievements_provider.dart';
import '../services/project_service.dart';
import '../utils/constants.dart';
import '../services/stats_service.dart';
import '../services/reports_service.dart';

class StatsProvider extends ChangeNotifier {
  final StatsService _statsService = StatsService();
  final ReportsService _reportsService = ReportsService();
  final ProjectService _projectService = ProjectService();
  TaskProvider? _taskProvider;
  ProjectProvider? _projectProvider;
  WaterProvider? _waterProvider;
  AchievementsProvider? _achievementsProvider;
  bool _isLoading = false;
  String? _errorMessage;

  void setProviders(
    TaskProvider? taskProvider,
    ProjectProvider? projectProvider,
    WaterProvider? waterProvider,
    AchievementsProvider? achievementsProvider,
  ) {
    _taskProvider = taskProvider;
    _projectProvider = projectProvider;
    _waterProvider = waterProvider;
    _achievementsProvider = achievementsProvider;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> refreshStats() async {
    _isLoading = true;
    _setErrorMessage(null);
    notifyListeners();
    
    try {
      // Save current day stats to database
      final completedTasksCount = getCompletedTasksCount();
      final totalTasksCount = _taskProvider?.tasks.length ?? 0;
      final completionPercentage = getTaskCompletionPercentage();
      final waterIntakeMl = _waterProvider?.currentIntakeMl ?? 0;
      final projectHours = await _calculateProjectHours();
      final xpEarned = _achievementsProvider?.userLevel?.totalXP ?? 0;
      
      await _statsService.saveDailyStats(
        completedTasksCount: completedTasksCount,
        totalTasksCount: totalTasksCount,
        waterIntakeMl: waterIntakeMl,
        projectHours: projectHours,
        completionPercentage: completionPercentage,
        xpEarned: xpEarned,
      );
    } catch (e) {
      debugPrint('Error refreshing stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, double>> getWeeklyProductivity() async {
    try {
      final reportResult = await _reportsService.calculateWeeklyProductivityFromReport();
      return reportResult;
    } on PostgrestException catch (e) {
      debugPrint('Error getting weekly productivity from report: $e');
      await getWeeklyProductivityFallback();
      _setErrorMessage(AppStrings.errorLoadingReports);
      throw StatsException(AppStrings.errorLoadingReports);
    } catch (e) {
      debugPrint('Unexpected error getting weekly productivity from report: $e');
      await getWeeklyProductivityFallback();
      _setErrorMessage(AppStrings.errorLoadingReports);
      throw StatsException(AppStrings.errorLoadingReports);
    }
  }

  Future<Map<String, double>> getWeeklyProductivityFallback() async {
    try {
      final percentage = await _statsService.calculateWeeklyProductivity();
      return {
        'percentage': percentage,
        'trend': 0.0,
      };
    } catch (fallbackError) {
      debugPrint('Error getting weekly productivity fallback: $fallbackError');
      return {
        'percentage': 0.0,
        'trend': 0.0,
      };
    }
  }

  @visibleForTesting
  static List<WeeklyStats> buildWeeklyStatsFromReports(
    List<DailyReportModel> reports, {
    DateTime? now,
  }) {
    final referenceDate = now ?? DateTime.now();
    final weeklyStats = _buildDefaultWeeklyStats(referenceDate);

    for (final report in reports) {
      final index = _weekdayToIndex(report.weekdayIndex);
      if (index == null || index < 0 || index >= weeklyStats.length) {
        continue;
      }

      final isToday = report.date.year == referenceDate.year &&
          report.date.month == referenceDate.month &&
          report.date.day == referenceDate.day;

      weeklyStats[index] = WeeklyStats(
        dayName: weeklyStats[index].dayName,
        percentage: report.completionPercentage,
        isToday: weeklyStats[index].isToday || isToday,
      );
    }

    return weeklyStats;
  }

  Future<List<WeeklyStats>> getWeeklyChartData() async {
    try {
      final reports = await _reportsService.fetchWeeklyReport();
      if (reports.isEmpty) {
        return _getDefaultWeeklyStats();
      }

      return StatsProvider.buildWeeklyStatsFromReports(reports);
    } on PostgrestException catch (e) {
      debugPrint('Error getting weekly chart data from report: $e');
      await getWeeklyChartDataFallback();
      _setErrorMessage(AppStrings.errorLoadingReports);
      throw StatsException(AppStrings.errorLoadingReports);
    } catch (e) {
      debugPrint('Unexpected error getting weekly chart data from report: $e');
      await getWeeklyChartDataFallback();
      _setErrorMessage(AppStrings.errorLoadingReports);
      throw StatsException(AppStrings.errorLoadingReports);
    }
  }

  Future<List<WeeklyStats>> getWeeklyChartDataFallback() async {
    try {
      return await _statsService.getWeeklyChartData();
    } catch (fallbackError) {
      debugPrint('Error getting weekly chart data fallback: $fallbackError');
      return _getDefaultWeeklyStats();
    }
  }

  Future<List<ProjectReportModel>> getProjectsOverview() async {
    try {
      return await _reportsService.fetchProjectsReport();
    } on PostgrestException catch (e) {
      debugPrint('Error getting projects overview: $e');
      _setErrorMessage(AppStrings.errorLoadingReports);
      throw StatsException(AppStrings.errorLoadingReports);
    } catch (e) {
      debugPrint('Unexpected error getting projects overview: $e');
      _setErrorMessage(AppStrings.errorLoadingReports);
      throw StatsException(AppStrings.errorLoadingReports);
    }
  }

  Future<List<TimeDistribution>> getTimeDistribution() async {
    try {
      return await _statsService.calculateTimeDistribution();
    } catch (e) {
      debugPrint('Error getting time distribution: $e');
      return _getDefaultTimeDistribution();
    }
  }

  Future<List<Achievement>> getWeeklyAchievements() async {
    try {
      return await _statsService.getWeeklyAchievements();
    } catch (e) {
      debugPrint('Error getting weekly achievements: $e');
      return _getDefaultAchievements();
    }
  }

  int getCompletedTasksCount() {
    return _taskProvider?.tasks.where((task) => task.isCompleted).length ?? 0;
  }

  double getTaskCompletionPercentage() {
    final pct = _taskProvider?.getCompletionPercentage() ?? 0.0;
    return pct * 100;
  }

  Future<double> _calculateProjectHours() async {
    double totalMinutes = 0;

    if (_projectProvider == null) return 0.0;
    
    for (final project in _projectProvider!.projects) {
      final projectId = project.id;
      if (projectId == null) {
        continue;
      }
      totalMinutes += await _projectService.getTotalTimeSpent(projectId);
    }

    return totalMinutes / 60.0;
  }

  List<WeeklyStats> _getDefaultWeeklyStats() {
    return _buildDefaultWeeklyStats(DateTime.now());
  }

  static List<WeeklyStats> _buildDefaultWeeklyStats(DateTime now) {
    final currentDay = now.weekday;

    return [
      WeeklyStats(
        dayName: 'السبت',
        percentage: 0.0,
        isToday: currentDay == DateTime.saturday,
      ),
      WeeklyStats(
        dayName: 'الأحد',
        percentage: 0.0,
        isToday: currentDay == DateTime.sunday,
      ),
      WeeklyStats(
        dayName: 'الإثنين',
        percentage: 0.0,
        isToday: currentDay == DateTime.monday,
      ),
      WeeklyStats(
        dayName: 'الثلاثاء',
        percentage: 0.0,
        isToday: currentDay == DateTime.tuesday,
      ),
      WeeklyStats(
        dayName: 'الأربعاء',
        percentage: 0.0,
        isToday: currentDay == DateTime.wednesday,
      ),
      WeeklyStats(
        dayName: 'الخميس',
        percentage: 0.0,
        isToday: currentDay == DateTime.thursday,
      ),
      WeeklyStats(
        dayName: 'الجمعة',
        percentage: 0.0,
        isToday: currentDay == DateTime.friday,
      ),
    ];
  }

  List<TimeDistribution> _getDefaultTimeDistribution() {
    return [
      TimeDistribution(
        category: 'العمل',
        hours: 0.0,
        percentage: 0.0,
        icon: Icons.work,
        color: AppColors.successColor,
      ),
      TimeDistribution(
        category: 'المشاريع الخاصة',
        hours: 0.0,
        percentage: 0.0,
        icon: Icons.rocket_launch,
        color: AppColors.warningColor,
      ),
      TimeDistribution(
        category: 'النادي الرياضي',
        hours: 0.0,
        percentage: 0.0,
        icon: Icons.fitness_center,
        color: const Color(0xFF4c869a),
      ),
    ];
  }

  List<Achievement> _getDefaultAchievements() {
    return [
      Achievement(
        title: 'لا توجد إنجازات',
        subtitle: 'ابدأ بإكمال المهام للحصول على إنجازات',
        icon: Icons.hourglass_empty,
        iconColor: Colors.grey,
        backgroundColor: Colors.grey.withOpacity(0.1),
      ),
    ];
  }

  void _setErrorMessage(String? message) {
    if (_errorMessage == message) {
      return;
    }
    _errorMessage = message;
    notifyListeners();
  }

  static int? _weekdayToIndex(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return 0;
      case DateTime.sunday:
        return 1;
      case DateTime.monday:
        return 2;
      case DateTime.tuesday:
        return 3;
      case DateTime.wednesday:
        return 4;
      case DateTime.thursday:
        return 5;
      case DateTime.friday:
        return 6;
      default:
        return null;
    }
  }
}

class StatsException implements Exception {
  final String message;

  StatsException(this.message);

  @override
  String toString() => message;
}
