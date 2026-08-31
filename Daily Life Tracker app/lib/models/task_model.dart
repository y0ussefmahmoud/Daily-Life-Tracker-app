// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'package:flutter/material.dart';

/// Task priority levels for categorization.
enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

/// Task categorization for time-based organization.
enum TaskCategory {
  today,
  nextWeek,
  someday,
}

/// Actionable task model with categorization, priority levels, and completion status.
/// Supports time-based categorization (today, next_week, someday) and priority-based sorting.
class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final String category;
  final TaskPriority priority;
  final TaskCategory timeCategory;
  final int iconCodePoint;
  final String? reminderTimeString;
  final bool isRepeating;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.category = 'general',
    this.priority = TaskPriority.medium,
    this.timeCategory = TaskCategory.today,
    this.iconCodePoint = 0xE87C,
    this.reminderTimeString,
    this.isRepeating = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a TaskModel from a JSON map with safe fallbacks for null values.
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled Task',
      description: map['description'] as String?,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      isCompleted: map['is_completed'] as bool? ?? false,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      category: map['category'] as String? ?? 'general',
      priority: map['priority'] != null
          ? _parsePriority(map['priority'] as String)
          : TaskPriority.medium,
      timeCategory: map['time_category'] != null
          ? _parseTimeCategory(map['time_category'] as String)
          : TaskCategory.today,
      iconCodePoint: map['icon_code_point'] as int? ?? 0xE87C,
      reminderTimeString: map['reminder_time_string'] as String?,
      isRepeating: map['is_repeating'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts the TaskModel to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'category': category,
      'priority': priority.name,
      'time_category': timeCategory.name,
      'icon_code_point': iconCodePoint,
      'reminder_time_string': reminderTimeString,
      'is_repeating': isRepeating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of the TaskModel with updated fields.
  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    String? category,
    TaskPriority? priority,
    TaskCategory? timeCategory,
    int? iconCodePoint,
    String? reminderTimeString,
    bool? isRepeating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      timeCategory: timeCategory ?? this.timeCategory,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      reminderTimeString: reminderTimeString ?? this.reminderTimeString,
      isRepeating: isRepeating ?? this.isRepeating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Parses priority string to enum with safe fallback.
  static TaskPriority _parsePriority(String value) {
    return TaskPriority.values.firstWhere(
      (p) => p.name == value,
      orElse: () => TaskPriority.medium,
    );
  }

  /// Parses time category string to enum with safe fallback.
  static TaskCategory _parseTimeCategory(String value) {
    return TaskCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => TaskCategory.today,
    );
  }

  /// Returns the IconData for the task icon.
  IconData get icon => _getIconForCodePoint(iconCodePoint);

  /// Returns the reminder time as TimeOfDay.
  TimeOfDay? get reminderTime {
    if (reminderTimeString == null) return null;
    try {
      final parts = reminderTimeString!.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }
  /// Returns reminder time string from TimeOfDay.
  String? reminderTimeToString(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Returns IconData for a given code point.
  static IconData _getIconForCodePoint(int codePoint) {
    switch (codePoint) {
      case 0xe838: return Icons.star;
      case 0xe14a: return Icons.home;
      case 0xe85d: return Icons.work;
      case 0xe7fd: return Icons.school;
      case 0xe7f1: return Icons.fitness_center;
      case 0xe55b: return Icons.book;
      case 0xe87c: return Icons.sports_soccer;
      case 0xe54e: return Icons.code;
      case 0xe8b8: return Icons.music_note;
      case 0xe439: return Icons.palette;
      default: return Icons.star;
    }
  }
}
