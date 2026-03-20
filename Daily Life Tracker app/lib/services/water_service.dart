import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/water_log_model.dart';
import '../services/local_database_service.dart';

class WaterService {
  final LocalDatabaseService _db = LocalDatabaseService();
  final Uuid _uuid = const Uuid();

  Future<void> logWaterIntake(int amountMl) async {
    debugPrint('=== LOG WATER INTAKE START ===');
    debugPrint('Amount: $amountMl');
    
    try {
      // Check if waterLogBox is initialized
      if (!_db.isWaterLogBoxInitialized()) {
        debugPrint('Water log box not initialized, initializing...');
        await _db.initialize();
      }
      
      final waterLog = WaterLog(
        id: _uuid.v4(),
        amount: amountMl,
        date: DateTime.now(),
      );
      
      debugPrint('Creating water log: ${waterLog.id}');
      await _db.waterLogBox.put(waterLog.id, waterLog);
      debugPrint('Water log saved successfully');
      debugPrint('=== LOG WATER INTAKE COMPLETE ===');
    } catch (e, stackTrace) {
      debugPrint('LOG WATER INTAKE ERROR: $e');
      debugPrint('STACK: $stackTrace');
      throw Exception('Failed to log water intake: $e');
    }
  }

  Future<List<WaterLog>> fetchTodayWaterLogs() async {
    debugPrint('=== FETCH TODAY WATER LOGS START ===');
    
    try {
      // Check if waterLogBox is initialized
      if (!_db.isWaterLogBoxInitialized()) {
        debugPrint('Water log box not initialized, initializing...');
        await _db.initialize();
      }
      
      final today = DateTime.now();
      final logs = _db.waterLogBox.values.where((log) =>
        log.date.year == today.year &&
        log.date.month == today.month &&
        log.date.day == today.day
      ).toList();
      
      debugPrint('Found ${logs.length} logs for today');
      debugPrint('=== FETCH TODAY WATER LOGS COMPLETE ===');
      return logs;
    } catch (e, stackTrace) {
      debugPrint('FETCH TODAY WATER LOGS ERROR: $e');
      debugPrint('STACK: $stackTrace');
      throw Exception('Failed to fetch today water logs: $e');
    }
  }

  Future<List<WaterLog>> fetchWaterLogsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return _db.waterLogBox.values.where((log) =>
        log.date.isAfter(startDate.subtract(Duration(days: 1))) &&
        log.date.isBefore(endDate.add(Duration(days: 1)))
      ).toList();
    } catch (e, stackTrace) {
      debugPrint('FETCH WATER LOGS BY RANGE ERROR: $e');
      debugPrint('STACK: $stackTrace');
      throw Exception('Failed to fetch water logs by date range: $e');
    }
  }

  Future<int> getTodayTotalWaterIntake() async {
    try {
      final todayLogs = await fetchTodayWaterLogs();
      final total = todayLogs.fold<int>(0, (sum, log) => sum + log.amount);
      debugPrint('Today total water intake: $total');
      return total;
    } catch (e, stackTrace) {
      debugPrint('GET TODAY TOTAL ERROR: $e');
      debugPrint('STACK: $stackTrace');
      throw Exception('Failed to get today total water intake: $e');
    }
  }

  Future<int> getTodayWaterIntake() async {
    debugPrint('=== GET TODAY WATER INTAKE START ===');
    
    try {
      final logs = await fetchTodayWaterLogs();
      final total = logs.fold<int>(0, (sum, log) => sum + log.amount);
      debugPrint('Today water intake calculated: $total');
      debugPrint('=== GET TODAY WATER INTAKE COMPLETE ===');
      return total;
    } catch (e, stackTrace) {
      debugPrint('GET TODAY WATER INTAKE ERROR: $e');
      debugPrint('STACK: $stackTrace');
      throw Exception('Failed to get today water intake: $e');
    }
  }

  Future<int> getWaterGoal() async {
    debugPrint('=== GET WATER GOAL START ===');
    
    try {
      // Default goal for now
      final goal = 2000;
      debugPrint('Water goal: $goal');
      debugPrint('=== GET WATER GOAL COMPLETE ===');
      return goal;
    } catch (e, stackTrace) {
      debugPrint('GET WATER GOAL ERROR: $e');
      debugPrint('STACK: $stackTrace');
      throw Exception('Failed to get water goal: $e');
    }
  }

  Future<void> deleteWaterLog(String id) async {
    debugPrint('=== DELETE WATER LOG START ===');
    debugPrint('ID: $id');
    
    try {
      await _db.waterLogBox.delete(id);
      debugPrint('Water log deleted successfully');
      debugPrint('=== DELETE WATER LOG COMPLETE ===');
    } catch (e, stackTrace) {
      debugPrint('DELETE WATER LOG ERROR: $e');
      debugPrint('STACK: $stackTrace');
      throw Exception('Failed to delete water log: $e');
    }
  }

  Future<void> updateWaterLog(WaterLog waterLog) async {
    debugPrint('=== UPDATE WATER LOG START ===');
    debugPrint('ID: ${waterLog.id}');
    
    try {
      await _db.waterLogBox.put(waterLog.id, waterLog);
      debugPrint('Water log updated successfully');
      debugPrint('=== UPDATE WATER LOG COMPLETE ===');
    } catch (e, stackTrace) {
      debugPrint('UPDATE WATER LOG ERROR: $e');
      debugPrint('STACK: $stackTrace');
      throw Exception('Failed to update water log: $e');
    }
  }

  Future<List<WaterLog>> getAllWaterLogs() async {
    try {
      return _db.waterLogBox.values.toList();
    } catch (e, stackTrace) {
      debugPrint('GET ALL WATER LOGS ERROR: $e');
      debugPrint('STACK: $stackTrace');
      throw Exception('Failed to fetch all water logs: $e');
    }
  }

  Future<List<WaterLog>> getWaterLogs() async {
    try {
      return _db.waterLogBox.values.toList();
    } catch (e, stackTrace) {
      debugPrint('GET WATER LOGS ERROR: $e');
      debugPrint('STACK: $stackTrace');
      throw Exception('Failed to fetch water logs: $e');
    }
  }

  Future<Map<String, int>> getWeeklyWaterIntake() async {
    debugPrint('=== GET WEEKLY WATER INTAKE START ===');
    
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = now.add(Duration(days: 7 - now.weekday));
      
      final weeklyLogs = await fetchWaterLogsByDateRange(weekStart, weekEnd);
      final weeklyData = <String, int>{};
      
      for (final log in weeklyLogs) {
        final dayKey = log.date.day.toString();
        weeklyData[dayKey] = (weeklyData[dayKey] ?? 0) + log.amount;
      }
      
      return weeklyData;
    } catch (e, stackTrace) {
      debugPrint('GET WEEKLY WATER INTAKE ERROR: $e');
      debugPrint('STACK: $stackTrace');
      throw Exception('Failed to get weekly water intake: $e');
    }
  }
}
