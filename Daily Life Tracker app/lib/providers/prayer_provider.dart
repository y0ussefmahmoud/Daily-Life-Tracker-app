import 'package:flutter/material.dart';
import '../models/prayer_log.dart';

class PrayerProvider with ChangeNotifier {
  final List<PrayerLog> _prayers = [];

  PrayerProvider() {
    _init();
  }

  Future<void> _init() async {
    // In a real app, you'd initialize Hive here
    // For now, we'll use in-memory storage
    notifyListeners();
  }

  List<PrayerLog> getTodayPrayers() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _prayers.where((prayer) =>
      prayer.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
      prayer.date.isBefore(endOfDay)
    ).toList();
  }

  Future<void> markPrayerCompleted(PrayerType type) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Remove existing log for today
    _prayers.removeWhere((prayer) =>
      prayer.type == type &&
      prayer.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
      prayer.date.isBefore(endOfDay)
    );

    // Add new completed log
    final newLog = PrayerLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      date: DateTime.now(),
      isCompleted: true,
    );

    _prayers.add(newLog);
    notifyListeners();
  }

  Future<void> unmarkPrayerCompleted(PrayerType type) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Remove existing log for today
    _prayers.removeWhere((prayer) =>
      prayer.type == type &&
      prayer.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
      prayer.date.isBefore(endOfDay)
    );

    notifyListeners();
  }

  bool isPrayerCompletedToday(PrayerType type) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _prayers.any((prayer) =>
      prayer.type == type &&
      prayer.isCompleted &&
      prayer.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
      prayer.date.isBefore(endOfDay)
    );
  }

  Future<void> markQuranCompleted() async {
    // Quran completion is handled separately - could be extended
    notifyListeners();
  }

  Future<void> unmarkQuranCompleted() async {
    // Quran completion is handled separately - could be extended
    notifyListeners();
  }

  bool isQuranCompletedToday() {
    // For now, return false - this could be extended with Quran tracking
    return false;
  }

  Map<String, dynamic> getWeeklyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final weekPrayers = _prayers.where((prayer) =>
      prayer.date.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
      prayer.date.isBefore(weekEnd)
    ).toList();

    final completedPrayers = weekPrayers.where((p) => p.isCompleted).length;
    final totalPrayers = 7 * 5; // 7 days * 5 prayers
    final average = totalPrayers > 0 ? (completedPrayers / totalPrayers) * 5 : 0;

    // Find best day
    final dayStats = <int, int>{};
    for (final prayer in weekPrayers) {
      if (prayer.isCompleted) {
        final day = prayer.date.weekday;
        dayStats[day] = (dayStats[day] ?? 0) + 1;
      }
    }

    final bestDay = dayStats.isNotEmpty ? dayStats.entries.reduce((a, b) => a.value > b.value ? a : b).key : 0;

    return {
      'average': average,
      'bestDay': bestDay,
    };
  }

  Map<String, dynamic> getMonthlyStats() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    final monthPrayers = _prayers.where((prayer) =>
      prayer.date.isAfter(monthStart.subtract(const Duration(seconds: 1))) &&
      prayer.date.isBefore(monthEnd)
    ).toList();

    final completedPrayers = monthPrayers.where((p) => p.isCompleted).length;
    final totalDays = now.day;
    final totalPrayers = totalDays * 5;
    final average = totalPrayers > 0 ? (completedPrayers / totalPrayers) * 5 : 0;

    final perfectDays = _getPerfectDaysCount(monthPrayers, monthStart, now.day);

    return {
      'average': average,
      'perfectDays': perfectDays,
    };
  }

  int _getPerfectDaysCount(List<PrayerLog> prayers, DateTime monthStart, int days) {
    int perfectDays = 0;

    for (int i = 0; i < days; i++) {
      final day = monthStart.add(Duration(days: i));
      final dayPrayers = prayers.where((p) =>
        p.date.year == day.year &&
        p.date.month == day.month &&
        p.date.day == day.day
      ).toList();

      final completedCount = dayPrayers.where((p) => p.isCompleted).length;
      if (completedCount == 5) {
        perfectDays++;
      }
    }

    return perfectDays;
  }

  Map<String, dynamic> getPrayerStats(PrayerType type) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final prayerLogs = _prayers.where((prayer) =>
      prayer.type == type &&
      prayer.date.isAfter(thirtyDaysAgo)
    ).toList();

    final completedCount = prayerLogs.where((p) => p.isCompleted).length;
    final totalCount = prayerLogs.length;
    final completionRate = totalCount > 0 ? completedCount / totalCount : 0.0;

    return {
      'completionRate': completionRate,
      'totalPrayers': totalCount,
      'completedPrayers': completedCount,
    };
  }
}
