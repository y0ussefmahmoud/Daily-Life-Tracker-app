import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';
import '../services/supabase_service.dart';

abstract class ReportsApi {
  String? get currentUserId;

  Future<List<Map<String, dynamic>>> fetchDailyReport({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<Map<String, dynamic>>> fetchProjectsReport({
    required String userId,
  });
}

class SupabaseReportsApi implements ReportsApi {
  final SupabaseClient _supabase;

  SupabaseReportsApi(this._supabase);

  @override
  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<List<Map<String, dynamic>>> fetchDailyReport({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _supabase
        .from('daily_report')
        .select()
        .eq('user_id', userId)
        .gte('date', startDate.toIso8601String().split('T')[0])
        .lte('date', endDate.toIso8601String().split('T')[0]);

    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }

    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProjectsReport({
    required String userId,
  }) async {
    final response = await _supabase
        .from('projects_report')
        .select()
        .eq('user_id', userId)
        .order('last_updated', ascending: false);

    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }

    return [];
  }
}

class ReportsService {
  final ReportsApi _api;
  final String? _userIdOverride;

  ReportsService({ReportsApi? api, String? userIdOverride})
      : _api = api ?? SupabaseReportsApi(SupabaseService.client),
        _userIdOverride = userIdOverride;

  String? get _currentUserId => _userIdOverride ?? _api.currentUserId;

  Future<List<DailyReportModel>> fetchDailyReport(DateTime startDate, DateTime endDate) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      final response = await _api.fetchDailyReport(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return response.map(DailyReportModel.fromJson).toList();
    } on PostgrestException catch (e) {
      debugPrint('Error fetching daily report: $e');
      rethrow;
    }
  }

  Future<List<DailyReportModel>> fetchWeeklyReport() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final reports = await fetchDailyReport(weekStart, weekEnd);
    reports.sort((a, b) => a.date.compareTo(b.date));
    return reports;
  }

  Future<List<ProjectReportModel>> fetchProjectsReport() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      final response = await _api.fetchProjectsReport(userId: userId);
      return response.map(ProjectReportModel.fromJson).toList();
    } on PostgrestException catch (e) {
      debugPrint('Error fetching projects report: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> calculateWeeklyProductivityFromReport() async {
    final currentWeekReports = await fetchWeeklyReport();
    final percentage = _calculateAverageCompletion(currentWeekReports);

    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    final previousWeekEnd = currentWeekStart.subtract(const Duration(days: 1));

    final previousWeekReports = await fetchDailyReport(previousWeekStart, previousWeekEnd);
    final previousPercentage = _calculateAverageCompletion(previousWeekReports);
    final trend = percentage - previousPercentage;

    return {
      'percentage': percentage,
      'trend': trend,
    };
  }

  double _calculateAverageCompletion(List<DailyReportModel> reports) {
    if (reports.isEmpty) {
      return 0.0;
    }

    final total = reports.fold<double>(
      0.0,
      (sum, report) => sum + report.completionPercentage,
    );

    return total / reports.length;
  }
}
