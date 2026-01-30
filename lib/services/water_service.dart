import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/water_log_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class WaterService {
  final SupabaseClient _supabase = SupabaseService.client;
  final AuthService _authService = AuthService();

  Future<void> logWaterIntake(int amountMl) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _supabase.from('water_logs').insert({
        'user_id': userId,
        'amount_ml': amountMl,
        'date': DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD format
      });
    } on PostgrestException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<WaterLog>> fetchTodayWaterLogs() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final startOfDay = _getStartOfDay();
      final endOfDay = _getEndOfDay();

      final response = await _supabase
          .from('water_logs')
          .select()
          .eq('user_id', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: false);

      if (response is List) {
        return response
            .map((log) => WaterLog.fromJson(log as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on PostgrestException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<int> getTodayWaterIntake() async {
    final logs = await fetchTodayWaterLogs();
    return logs.fold<int>(0, (sum, log) => sum + log.amountMl);
  }

  Future<int> getWaterGoal() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return 2000;
      }

      final response = await _supabase
          .from('user_settings')
          .select('water_goal_ml')
          .eq('user_id', userId)
          .limit(1);

      if (response is List && response.isNotEmpty) {
        final row = response.first as Map<String, dynamic>;
        final goal = row['water_goal_ml'] as num?;
        return goal?.toInt() ?? 2000;
      }

      return 2000;
    } on PostgrestException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  DateTime _getStartOfDay() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _getEndOfDay() {
    final start = _getStartOfDay();
    return start.add(const Duration(days: 1));
  }
}
