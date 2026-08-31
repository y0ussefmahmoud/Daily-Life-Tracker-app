// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

/// Core habit model supporting standard daily routines and break habits.
/// Handles both regular habits (positive routines) and break habits (quit tracking).
class HabitModel {
  final String id;
  final String userId;
  final String title;
  final String category;
  final String frequency;
  final bool isBreakHabit;
  final DateTime? quitDate;
  final int currentStreak;
  final int bestStreak;
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitModel({
    required this.id,
    required this.userId,
    required this.title,
    this.category = 'general',
    this.frequency = 'daily',
    this.isBreakHabit = false,
    this.quitDate,
    this.currentStreak = 0,
    this.bestStreak = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a HabitModel from a JSON map with safe fallbacks for null values.
  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled Habit',
      category: map['category'] as String? ?? 'general',
      frequency: map['frequency'] as String? ?? 'daily',
      isBreakHabit: map['is_break_habit'] as bool? ?? false,
      quitDate: map['quit_date'] != null 
          ? DateTime.parse(map['quit_date'] as String) 
          : null,
      currentStreak: map['current_streak'] as int? ?? 0,
      bestStreak: map['best_streak'] as int? ?? 0,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : DateTime.now(),
    );
  }

  /// Converts the HabitModel to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'frequency': frequency,
      'is_break_habit': isBreakHabit,
      'quit_date': quitDate?.toIso8601String(),
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of the HabitModel with updated fields.
  HabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    String? frequency,
    bool? isBreakHabit,
    DateTime? quitDate,
    int? currentStreak,
    int? bestStreak,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      isBreakHabit: isBreakHabit ?? this.isBreakHabit,
      quitDate: quitDate ?? this.quitDate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculates days since quit date for break habits.
  int get daysSinceQuit {
    if (!isBreakHabit || quitDate == null) return 0;
    return DateTime.now().difference(quitDate!).inDays;
  }
}
