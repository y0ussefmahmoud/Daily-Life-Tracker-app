// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

/// Time log model for focus, work, and exercise durations.
/// Tracks dedicated time sessions for gamification and productivity metrics.
class ActivityLogModel {
  final String id;
  final String userId;
  final String activityName;
  final String category;
  final int durationMinutes;
  final DateTime loggedAt;
  final DateTime createdAt;

  ActivityLogModel({
    required this.id,
    required this.userId,
    required this.activityName,
    this.category = 'general',
    this.durationMinutes = 0,
    required this.loggedAt,
    required this.createdAt,
  });

  /// Creates an ActivityLogModel from a JSON map with safe fallbacks for null values.
  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      activityName: map['activity_name'] as String? ?? 'Untitled Activity',
      category: map['category'] as String? ?? 'general',
      durationMinutes: map['duration_minutes'] as int? ?? 0,
      loggedAt: map['logged_at'] != null
          ? DateTime.parse(map['logged_at'] as String)
          : DateTime.now(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts the ActivityLogModel to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'activity_name': activityName,
      'category': category,
      'duration_minutes': durationMinutes,
      'logged_at': loggedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of the ActivityLogModel with updated fields.
  ActivityLogModel copyWith({
    String? id,
    String? userId,
    String? activityName,
    String? category,
    int? durationMinutes,
    DateTime? loggedAt,
    DateTime? createdAt,
  }) {
    return ActivityLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityName: activityName ?? this.activityName,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns the duration in hours.
  double get durationHours {
    return durationMinutes / 60.0;
  }

  /// Returns a formatted duration string.
  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Checks if this log is for the current day.
  bool get isToday {
    final now = DateTime.now();
    return loggedAt.year == now.year &&
        loggedAt.month == now.month &&
        loggedAt.day == now.day;
  }
}
