// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'package:flutter/material.dart';

/// Subtask priority levels for categorization.
enum SubtaskPriority {
  high,
  medium,
  low,
}

/// Isolated subtask item model for task breakdown.
/// Supports time tracking and priority-based organization.
class SubtaskModel {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final SubtaskPriority priority;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? timeSpentMinutes;

  SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.priority = SubtaskPriority.medium,
    required this.createdAt,
    this.completedAt,
    this.timeSpentMinutes,
  });

  /// Creates a SubtaskModel from a JSON map with safe fallbacks for null values.
  factory SubtaskModel.fromMap(Map<String, dynamic> map) {
    return SubtaskModel(
      id: map['id'] as String? ?? '',
      taskId: map['task_id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled Subtask',
      isCompleted: map['is_completed'] as bool? ?? false,
      priority: map['priority'] != null
          ? _parsePriority(map['priority'] as String)
          : SubtaskPriority.medium,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      timeSpentMinutes: map['time_spent_minutes'] as int?,
    );
  }

  /// Converts the SubtaskModel to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'is_completed': isCompleted,
      'priority': priority.name,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'time_spent_minutes': timeSpentMinutes,
    };
  }

  /// Creates a copy of the SubtaskModel with updated fields.
  SubtaskModel copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    SubtaskPriority? priority,
    DateTime? createdAt,
    DateTime? completedAt,
    int? timeSpentMinutes,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
    );
  }

  /// Parses priority string to enum with safe fallback.
  static SubtaskPriority _parsePriority(String value) {
    return SubtaskPriority.values.firstWhere(
      (p) => p.name == value,
      orElse: () => SubtaskPriority.medium,
    );
  }

  /// Returns the priority label.
  String get priorityLabel {
    switch (priority) {
      case SubtaskPriority.high:
        return 'High';
      case SubtaskPriority.medium:
        return 'Medium';
      case SubtaskPriority.low:
        return 'Low';
    }
  }

  /// Returns the priority color.
  Color get priorityColor {
    switch (priority) {
      case SubtaskPriority.high:
        return Colors.red;
      case SubtaskPriority.medium:
        return Colors.orange;
      case SubtaskPriority.low:
        return Colors.blue;
    }
  }
}
