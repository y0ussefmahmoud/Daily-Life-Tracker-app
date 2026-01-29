import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stats_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class StatsService {
  final SupabaseClient _supabase = SupabaseService.client;
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> fetchDailyStats(DateTime date) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return null;
      }

      final dateStr = date.toIso8601String().split('T')[0];
      
      final response = await _supabase
          .from('daily_stats')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .limit(1);

      if (response is List && response.isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }

      return null;
    } on PostgrestException catch (e) {
      debugPrint('Error fetching daily stats: $e');
      return null;
    } catch (e) {
      debugPrint('Unexpected error fetching daily stats: $e');
      return null;
    }
  }

  Future<double> calculateWeeklyProductivity() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return 0.0;
      }

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final response = await _supabase
          .from('daily_stats')
          .select('completion_percentage')
          .eq('user_id', userId)
          .gte('date', weekStart.toIso8601String().split('T')[0])
          .lte('date', weekEnd.toIso8601String().split('T')[0]);

      if (response is List && response.isNotEmpty) {
        final totalPercentage = response.fold<double>(
          0.0,
          (sum, stat) => sum + ((stat['completion_percentage'] as num?)?.toDouble() ?? 0.0),
        );
        return totalPercentage / response.length;
      }

      return 0.0;
    } on PostgrestException catch (e) {
      debugPrint('Error calculating weekly productivity: $e');
      return 0.0;
    } catch (e) {
      debugPrint('Unexpected error calculating weekly productivity: $e');
      return 0.0;
    }
  }

  Future<List<WeeklyStats>> getWeeklyChartData() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return _getDefaultWeeklyStats();
      }

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      
      final List<WeeklyStats> weeklyStats = [];
      
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];
        final dayName = _getDayNameArabic(date.weekday);
        final isToday = date.day == now.day && date.month == now.month && date.year == now.year;

        final response = await _supabase
            .from('daily_stats')
            .select('completion_percentage')
            .eq('user_id', userId)
            .eq('date', dateStr)
            .limit(1);

        double percentage = 0.0;
        if (response is List && response.isNotEmpty) {
          percentage = (response.first['completion_percentage'] as num?)?.toDouble() ?? 0.0;
        }

        weeklyStats.add(WeeklyStats(
          dayName: dayName,
          percentage: percentage,
          isToday: isToday,
        ));
      }

      return weeklyStats;
    } on PostgrestException catch (e) {
      debugPrint('Error getting weekly chart data: $e');
      return _getDefaultWeeklyStats();
    } catch (e) {
      debugPrint('Unexpected error getting weekly chart data: $e');
      return _getDefaultWeeklyStats();
    }
  }

  Future<List<TimeDistribution>> calculateTimeDistribution() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return _getDefaultTimeDistribution();
      }

      // Query daily_tasks for category distribution
      final tasksResponse = await _supabase
          .from('daily_tasks')
          .select('category')
          .eq('user_id', userId)
          .eq('is_completed', true);

      // Query project_time_logs for project time distribution
      final projectsResponse = await _supabase
          .from('project_time_logs')
          .select('project_id, hours_spent')
          .eq('user_id', userId);

      final Map<String, double> categoryHours = {};

      // Process tasks (estimate 1 hour per completed task)
      if (tasksResponse is List) {
        for (final task in tasksResponse) {
          final category = task['category'] as String? ?? 'other';
          categoryHours[category] = (categoryHours[category] ?? 0.0) + 1.0;
        }
      }

      // Process project time logs
      if (projectsResponse is List) {
        for (final project in projectsResponse) {
          final hours = (project['hours_spent'] as num?)?.toDouble() ?? 0.0;
          categoryHours['المشاريع'] = (categoryHours['المشاريع'] ?? 0.0) + hours;
        }
      }

      final totalHours = categoryHours.values.fold<double>(0.0, (sum, hours) => sum + hours);
      
      if (totalHours == 0.0) {
        return _getDefaultTimeDistribution();
      }

      final List<TimeDistribution> distribution = [];
      categoryHours.forEach((category, hours) {
        distribution.add(TimeDistribution(
          category: _getCategoryDisplayName(category),
          hours: hours,
          percentage: (hours / totalHours) * 100,
          icon: _getCategoryIcon(category),
          color: _getCategoryColor(category),
        ));
      });

      // Sort by hours descending
      distribution.sort((a, b) => b.hours.compareTo(a.hours));
      
      return distribution.take(5).toList(); // Return top 5 categories
    } on PostgrestException catch (e) {
      debugPrint('Error calculating time distribution: $e');
      return _getDefaultTimeDistribution();
    } catch (e) {
      debugPrint('Unexpected error calculating time distribution: $e');
      return _getDefaultTimeDistribution();
    }
  }

  Future<List<Achievement>> getWeeklyAchievements() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return _getDefaultAchievements();
      }

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      // Get completed tasks count for the week
      final tasksResponse = await _supabase
          .from('daily_tasks')
          .select('category, is_completed')
          .eq('user_id', userId)
          .gte('created_at', weekStart.toIso8601String());

      // Get daily stats for the week
      final statsResponse = await _supabase
          .from('daily_stats')
          .select('completed_tasks_count, total_tasks_count, water_intake_ml, xp_earned')
          .eq('user_id', userId)
          .gte('date', weekStart.toIso8601String().split('T')[0]);

      final List<Achievement> achievements = [];

      if (tasksResponse is List) {
        final totalTasks = tasksResponse.length;
        final completedTasks = tasksResponse.where((task) => task['is_completed'] == true).length;
        final completionPercentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

        achievements.add(Achievement(
          title: '$completedTasks مهمة مكتملة',
          subtitle: 'إنجاز ${completionPercentage.toStringAsFixed(0)}% من القائمة الأسبوعية',
          icon: Icons.task_alt,
          iconColor: Colors.blue,
          backgroundColor: Colors.blue.withOpacity(0.1),
        ));
      }

      if (statsResponse is List) {
        final totalXP = statsResponse.fold<int>(
          0,
          (sum, stat) => sum + ((stat['xp_earned'] as int?) ?? 0),
        );

        achievements.add(Achievement(
          title: '$totalXP نقطة خبرة',
          subtitle: 'إجمالي النقاط هذا الأسبوع',
          icon: Icons.stars,
          iconColor: Colors.amber,
          backgroundColor: Colors.amber.withOpacity(0.1),
        ));
      }

      // Add prayer achievement (placeholder)
      achievements.add(Achievement(
        title: '٩٠٪ المحافظة على الصلاة',
        subtitle: 'بارك الله في التزامك',
        icon: Icons.auto_awesome,
        iconColor: Colors.orange,
        backgroundColor: Colors.orange.withOpacity(0.1),
      ));

      return achievements;
    } on PostgrestException catch (e) {
      debugPrint('Error getting weekly achievements: $e');
      return _getDefaultAchievements();
    } catch (e) {
      debugPrint('Unexpected error getting weekly achievements: $e');
      return _getDefaultAchievements();
    }
  }

  Future<void> saveDailyStats({
    required int completedTasksCount,
    required int totalTasksCount,
    required int waterIntakeMl,
    required double projectHours,
    required double completionPercentage,
    required int xpEarned,
  }) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final today = DateTime.now().toIso8601String().split('T')[0];

      // Check if stats already exist for today
      final existingStats = await _supabase
          .from('daily_stats')
          .select('id')
          .eq('user_id', userId)
          .eq('date', today)
          .limit(1);

      final statsData = {
        'user_id': userId,
        'date': today,
        'completed_tasks_count': completedTasksCount,
        'total_tasks_count': totalTasksCount,
        'water_intake_ml': waterIntakeMl,
        'project_hours': projectHours,
        'completion_percentage': completionPercentage,
        'xp_earned': xpEarned,
      };

      if (existingStats is List && existingStats.isNotEmpty) {
        // Update existing stats
        await _supabase
            .from('daily_stats')
            .update(statsData)
            .eq('user_id', userId)
            .eq('date', today);
      } else {
        // Insert new stats
        await _supabase.from('daily_stats').insert(statsData);
      }
    } on PostgrestException catch (e) {
      debugPrint('Error saving daily stats: $e');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error saving daily stats: $e');
      rethrow;
    }
  }

  List<WeeklyStats> _getDefaultWeeklyStats() {
    final now = DateTime.now();
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
        color: Colors.blue,
      ),
      TimeDistribution(
        category: 'المشاريع الخاصة',
        hours: 0.0,
        percentage: 0.0,
        icon: Icons.rocket_launch,
        color: Colors.orange,
      ),
      TimeDistribution(
        category: 'النادي الرياضي',
        hours: 0.0,
        percentage: 0.0,
        icon: Icons.fitness_center,
        color: Colors.grey,
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

  String _getDayNameArabic(int weekday) {
    switch (weekday) {
      case 1:
        return 'الإثنين';
      case 2:
        return 'الثلاثاء';
      case 3:
        return 'الأربعاء';
      case 4:
        return 'الخميس';
      case 5:
        return 'الجمعة';
      case 6:
        return 'السبت';
      case 7:
        return 'الأحد';
      default:
        return '';
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'work':
      case 'العمل':
        return 'العمل';
      case 'personal':
      case 'شخصي':
        return 'شخصي';
      case 'health':
      case 'صحة':
        return 'الصحة';
      case 'learning':
      case 'تعلم':
        return 'التعلم';
      case 'projects':
      case 'المشاريع':
        return 'المشاريع';
      default:
        return 'أخرى';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
      case 'العمل':
        return Icons.work;
      case 'personal':
      case 'شخصي':
        return Icons.person;
      case 'health':
      case 'صحة':
        return Icons.fitness_center;
      case 'learning':
      case 'تعلم':
        return Icons.school;
      case 'projects':
      case 'المشاريع':
        return Icons.rocket_launch;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
      case 'العمل':
        return Colors.blue;
      case 'personal':
      case 'شخصي':
        return Colors.green;
      case 'health':
      case 'صحة':
        return Colors.red;
      case 'learning':
      case 'تعلم':
        return Colors.purple;
      case 'projects':
      case 'المشاريع':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
