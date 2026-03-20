import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/water_service.dart';
import '../models/water_log_model.dart';

class WaterProvider extends ChangeNotifier {
  final WaterService _waterService = WaterService();

  int _currentIntakeMl = 0;
  int _goalMl = 2000;

  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  int get currentCups => (_currentIntakeMl / 250).floor();
  int get targetCups => (_goalMl / 250.0).ceil().toInt();
  int get currentIntakeMl => _currentIntakeMl;
  int get goalMl => _goalMl;
  int get currentIntake => _currentIntakeMl;
  int get dailyGoal => _goalMl;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _initialized;
  int get todayWaterIntake => currentIntake;
  int get waterGoal => goalMl;

  Future<void> initialize() async {
    debugPrint('=== WATER PROVIDER INIT START ===');
    if (_initialized) {
      debugPrint('Already initialized');
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Getting water goal...');
      _goalMl = await _waterService.getWaterGoal();
      debugPrint('Water goal: $_goalMl');
      
      debugPrint('Getting today water intake...');
      _currentIntakeMl = await _waterService.getTodayWaterIntake();
      debugPrint('Today water intake: $_currentIntakeMl');
      
      _initialized = true;
      debugPrint('=== WATER PROVIDER INIT COMPLETE ===');
    } catch (e, stackTrace) {
      debugPrint('WATER PROVIDER INIT ERROR: $e');
      debugPrint('STACK: $stackTrace');
      _error = e.toString();
      // Still mark as initialized to prevent infinite retries
      _initialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWater(int amount) async {
    debugPrint('=== ADD WATER START ===');
    debugPrint('Amount: $amount');
    debugPrint('Current: $_currentIntakeMl, Goal: $_goalMl');
    
    if (_currentIntakeMl >= _goalMl) {
      debugPrint('Goal already reached, skipping');
      return;
    }

    final previousIntake = _currentIntakeMl;
    _currentIntakeMl += amount;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Logging water intake...');
      await _waterService.logWaterIntake(amount);
      debugPrint('Water logged successfully');
      debugPrint('=== ADD WATER COMPLETE ===');
    } catch (e, stackTrace) {
      debugPrint('ADD WATER ERROR: $e');
      debugPrint('STACK: $stackTrace');
      _currentIntakeMl = previousIntake;
      _error = 'Failed to add water: $e';
      notifyListeners();
    }
  }

  Future<void> addCup() async {
    debugPrint('=== ADD CUP START ===');
    await addWater(250);
    debugPrint('=== ADD CUP COMPLETE ===');
  }

  Future<void> resetDaily() async {
    debugPrint('=== RESET DAILY START ===');
    _currentIntakeMl = 0;
    _error = null;
    notifyListeners();
    debugPrint('=== RESET DAILY COMPLETE ===');
  }

  Future<void> setGoal(int newGoal) async {
    debugPrint('=== SET GOAL START ===');
    debugPrint('New goal: $newGoal');
    _goalMl = newGoal;
    _error = null;
    notifyListeners();
    debugPrint('=== SET GOAL COMPLETE ===');
  }

  double get progressPercentage {
    if (_goalMl == 0) return 0.0;
    return (_currentIntakeMl / _goalMl).clamp(0.0, 1.0);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<List<WaterLog>> getTodayLogs() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final allLogs = await _waterService.getWaterLogs();
    return allLogs.where((log) => 
      log.date.isAfter(todayStart) && 
      log.date.isBefore(todayEnd)
    ).toList();
  }

  Future<double> getWeeklyAverage() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    final allLogs = await _waterService.getWaterLogs();
    final weekLogs = allLogs.where((log) => 
      log.date.isAfter(weekStart) && 
      log.date.isBefore(weekEnd)
    ).toList();
    
    if (weekLogs.isEmpty) return 0.0;
    
    final totalAmount = weekLogs.fold<double>(0, (sum, log) => sum + log.amount);
    return totalAmount / 7; // Average per day
  }

  Future<double> getMonthlyAverage() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    
    final allLogs = await _waterService.getWaterLogs();
    final monthLogs = allLogs.where((log) => 
      log.date.isAfter(monthStart) && 
      log.date.isBefore(monthEnd)
    ).toList();
    
    if (monthLogs.isEmpty) return 0.0;
    
    final totalAmount = monthLogs.fold<double>(0, (sum, log) => sum + log.amount);
    final daysInMonth = monthEnd.difference(monthStart).inDays;
    return totalAmount / daysInMonth; // Average per day
  }

  Future<String> getBestDay() async {
    final allLogs = await _waterService.getWaterLogs();
    if (allLogs.isEmpty) return 'لا توجد بيانات';
    
    // Group logs by day of week
    final Map<int, double> dailyTotals = {};
    for (final log in allLogs) {
      final dayOfWeek = log.date.weekday; // 1 = Monday, 7 = Sunday
      dailyTotals[dayOfWeek] = (dailyTotals[dayOfWeek] ?? 0) + log.amount;
    }
    
    if (dailyTotals.isEmpty) return 'لا توجد بيانات';
    
    // Find the day with maximum intake
    final bestDay = dailyTotals.entries.reduce((a, b) => 
      a.value > b.value ? a : b
    ).key;
    
    const dayNames = ['', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return '${dayNames[bestDay]} (${dailyTotals[bestDay]!.toInt()} مل)';
  }

  Future<void> addWaterLog(int amount, {String? notes}) async {
    await addWater(amount);
  }

  Future<void> setWaterGoal(double goal) async {
    await setGoal(goal.toInt());
  }

  Future<void> resetData() async {
    await resetDaily();
  }
}
