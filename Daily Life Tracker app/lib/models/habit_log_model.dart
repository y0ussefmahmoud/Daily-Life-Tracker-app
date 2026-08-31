// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

/// Daily check-in execution log model for habit tracking.
/// Records completion timestamps for habit check-ins with date-based uniqueness.
class HabitLogModel {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final DateTime createdAt;

  HabitLogModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    required this.createdAt,
  });

  /// Creates a HabitLogModel from a JSON map with safe fallbacks for null values.
  factory HabitLogModel.fromMap(Map<String, dynamic> map) {
    return HabitLogModel(
      id: map['id'] as String? ?? '',
      habitId: map['habit_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : DateTime.now(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts the HabitLogModel to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'completed_at': completedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of the HabitLogModel with updated fields.
  HabitLogModel copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return HabitLogModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns the date portion of the completion timestamp for uniqueness checks.
  DateTime get completedDate {
    return DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
  }

  /// Checks if this log is for the current day.
  bool get isToday {
    final now = DateTime.now();
    return completedDate.year == now.year &&
        completedDate.month == now.month &&
        completedDate.day == now.day;
  }
}
