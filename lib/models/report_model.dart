import '../models/stats_model.dart';

class DailyReportModel {
  final DateTime date;
  final String userId;
  final int completedTasksCount;
  final int totalTasksCount;
  final double completionPercentage;
  final int waterIntakeMl;
  final double projectHours;
  final int xpEarned;
  final String dayName;
  final int weekNumber;

  DailyReportModel({
    required this.date,
    required this.userId,
    required this.completedTasksCount,
    required this.totalTasksCount,
    required this.completionPercentage,
    required this.waterIntakeMl,
    required this.projectHours,
    required this.xpEarned,
    required this.dayName,
    required this.weekNumber,
  });

  factory DailyReportModel.fromJson(Map<String, dynamic> json) {
    return DailyReportModel(
      date: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
      userId: json['user_id'] as String? ?? '',
      completedTasksCount: (json['completed_tasks_count'] as num?)?.toInt() ?? 0,
      totalTasksCount: (json['total_tasks_count'] as num?)?.toInt() ?? 0,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
      waterIntakeMl: (json['water_intake_ml'] as num?)?.toInt() ?? 0,
      projectHours: (json['project_hours'] as num?)?.toDouble() ?? 0.0,
      xpEarned: (json['xp_earned'] as num?)?.toInt() ?? 0,
      dayName: json['day_name'] as String? ?? '',
      weekNumber: (json['week_number'] as num?)?.toInt() ?? 0,
    );
  }

  WeeklyStats toWeeklyStats() {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    return WeeklyStats(
      dayName: dayName,
      percentage: completionPercentage,
      isToday: isToday,
    );
  }

  int get weekdayIndex => date.weekday;
}

class ProjectReportModel {
  final String projectId;
  final String projectName;
  final String status;
  final double progress;
  final double totalTimeSpent;
  final List<String> techStack;
  final DateTime createdAt;
  final DateTime lastUpdated;

  ProjectReportModel({
    required this.projectId,
    required this.projectName,
    required this.status,
    required this.progress,
    required this.totalTimeSpent,
    required this.techStack,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory ProjectReportModel.fromJson(Map<String, dynamic> json) {
    final techStackRaw = json['tech_stack'];
    final List<String> parsedTechStack;

    if (techStackRaw is List) {
      parsedTechStack = techStackRaw.map((item) => item.toString()).toList();
    } else if (techStackRaw is String) {
      parsedTechStack = techStackRaw
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    } else {
      parsedTechStack = [];
    }

    return ProjectReportModel(
      projectId: json['project_id'] as String? ?? '',
      projectName: json['project_name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      totalTimeSpent: (json['total_time_spent'] as num?)?.toDouble() ?? 0.0,
      techStack: parsedTechStack,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      lastUpdated: DateTime.parse(json['last_updated'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  String formatTimeSpent() {
    final totalMinutes = (totalTimeSpent * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0 && minutes == 0) {
      return '0 ساعة';
    }

    if (hours == 0) {
      return '$minutes دقيقة';
    }

    if (minutes == 0) {
      return '$hours ساعة';
    }

    return '$hours ساعة و $minutes دقيقة';
  }

  String displayStatus() {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'paused':
      case 'on_hold':
        return 'متوقف مؤقتا';
      case 'completed':
      case 'done':
        return 'مكتمل';
      default:
        return 'غير محدد';
    }
  }
}
