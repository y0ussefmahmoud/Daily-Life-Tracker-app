/**
 * Developed by:
 * - Arabic: م / يوسف محمود عبد الجواد
 * - English: Eng / Youssef Mahmoud Abdelgawad
 * - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
 * - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
 * - Email: info@Youssef.com
 */

/// Database table and column name constants.
/// Prevents hardcoded strings and provides centralized schema reference.
class DbTables {
  // Table names
  static const String profiles = 'profiles';
  static const String habits = 'habits';
  static const String habitLogs = 'habit_logs';
  static const String tasks = 'tasks';
  static const String activityLogs = 'activity_logs';

  // Profiles table columns
  static const String profilesId = 'id';
  static const String profilesUserId = 'user_id';
  static const String profilesSchemaVersion = 'schema_version';
  static const String profilesTotalXp = 'total_xp';
  static const String profilesCurrentLevel = 'current_level';
  static const String profilesCreatedAt = 'created_at';
  static const String profilesUpdatedAt = 'updated_at';

  // Habits table columns
  static const String habitsId = 'id';
  static const String habitsUserId = 'user_id';
  static const String habitsTitle = 'title';
  static const String habitsCategory = 'category';
  static const String habitsFrequency = 'frequency';
  static const String habitsIsBreakHabit = 'is_break_habit';
  static const String habitsQuitDate = 'quit_date';
  static const String habitsCurrentStreak = 'current_streak';
  static const String habitsBestStreak = 'best_streak';
  static const String habitsCreatedAt = 'created_at';
  static const String habitsUpdatedAt = 'updated_at';

  // Habit logs table columns
  static const String habitLogsId = 'id';
  static const String habitLogsHabitId = 'habit_id';
  static const String habitLogsUserId = 'user_id';
  static const String habitLogsCompletedAt = 'completed_at';
  static const String habitLogsCreatedAt = 'created_at';

  // Tasks table columns
  static const String tasksId = 'id';
  static const String tasksUserId = 'user_id';
  static const String tasksTitle = 'title';
  static const String tasksDescription = 'description';
  static const String tasksDueDate = 'due_date';
  static const String tasksIsCompleted = 'is_completed';
  static const String tasksCompletedAt = 'completed_at';
  static const String tasksCategory = 'category';
  static const String tasksPriority = 'priority';
  static const String tasksCreatedAt = 'created_at';
  static const String tasksUpdatedAt = 'updated_at';

  // Activity logs table columns
  static const String activityLogsId = 'id';
  static const String activityLogsUserId = 'user_id';
  static const String activityLogsActivityName = 'activity_name';
  static const String activityLogsCategory = 'category';
  static const String activityLogsDurationMinutes = 'duration_minutes';
  static const String activityLogsLoggedAt = 'logged_at';
}
