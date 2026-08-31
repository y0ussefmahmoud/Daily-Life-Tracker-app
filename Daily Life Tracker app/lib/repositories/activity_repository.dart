import '../repositories/base_repository.dart';

/// Data model representing an activity log entity.
class ActivityLog {
  final String id;
  final String userId;
  final String activityName;
  final String category;
  final int durationMinutes;
  final DateTime loggedAt;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.activityName,
    this.category = 'general',
    this.durationMinutes = 0,
    required this.loggedAt,
  });

  ActivityLog copyWith({
    String? id,
    String? userId,
    String? activityName,
    String? category,
    int? durationMinutes,
    DateTime? loggedAt,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityName: activityName ?? this.activityName,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }
}

/// Repository for managing activity logs with safe fallback for legacy users.
/// Provides non-destructive queries with backward compatibility for duration tracking.
class ActivityRepository extends BaseRepository<ActivityLog> {
  /// Fetches an activity log by ID with safe fallback for missing columns.
  @override
  Future<ActivityLog?> getById(String id) async {
    return executeWithErrorHandling(
      () => _fetchActivityLogById(id),
      'Failed to fetch activity log by ID',
    );
  }

  /// Fetches all activity logs for the current user.
  @override
  Future<List<ActivityLog>> getAll() async {
    return executeWithErrorHandling(
      () => _fetchAllActivityLogs(),
      'Failed to fetch all activity logs',
    );
  }

  /// Creates a new activity log with safe defaults for new columns.
  @override
  Future<ActivityLog> create(ActivityLog entity) async {
    return executeWithErrorHandling(
      () => _createActivityLog(entity),
      'Failed to create activity log',
    );
  }

  /// Updates an existing activity log.
  @override
  Future<ActivityLog> update(ActivityLog entity) async {
    return executeWithErrorHandling(
      () => _updateActivityLog(entity),
      'Failed to update activity log',
    );
  }

  /// Deletes an activity log by ID.
  @override
  Future<void> delete(String id) async {
    return executeWithErrorHandling(
      () => _deleteActivityLog(id),
      'Failed to delete activity log',
    );
  }

  /// Fetches activity logs within a date range.
  Future<List<ActivityLog>> getLogsByDateRange(DateTime start, DateTime end) async {
    return executeWithErrorHandling(
      () => _fetchLogsByDateRange(start, end),
      'Failed to fetch logs by date range',
    );
  }

  /// Fetches activity logs by category.
  Future<List<ActivityLog>> getLogsByCategory(String category) async {
    return executeWithErrorHandling(
      () => _fetchLogsByCategory(category),
      'Failed to fetch logs by category',
    );
  }

  /// Calculates total duration for a specific date range.
  Future<int> getTotalDuration(DateTime start, DateTime end) async {
    return executeWithErrorHandling(
      () => _calculateTotalDuration(start, end),
      'Failed to calculate total duration',
    );
  }

  /// Implementation methods (to be connected to actual data source)
  Future<ActivityLog?> _fetchActivityLogById(String id) async {
    // TODO: Implement actual database query with safe fallbacks
    return null;
  }

  Future<List<ActivityLog>> _fetchAllActivityLogs() async {
    // TODO: Implement actual database query
    return [];
  }

  Future<ActivityLog> _createActivityLog(ActivityLog entity) async {
    // TODO: Implement actual database insert with safe defaults
    return entity;
  }

  Future<ActivityLog> _updateActivityLog(ActivityLog entity) async {
    // TODO: Implement actual database update
    return entity;
  }

  Future<void> _deleteActivityLog(String id) async {
    // TODO: Implement actual database delete
  }

  Future<List<ActivityLog>> _fetchLogsByDateRange(DateTime start, DateTime end) async {
    // TODO: Implement query with date range filter
    return [];
  }

  Future<List<ActivityLog>> _fetchLogsByCategory(String category) async {
    // TODO: Implement query with category filter
    return [];
  }

  Future<int> _calculateTotalDuration(DateTime start, DateTime end) async {
    // TODO: Implement aggregation query for total duration
    return 0;
  }
}
