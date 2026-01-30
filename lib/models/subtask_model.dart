import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subtask_model.g.dart';

enum TaskPriority {
  @JsonValue('high')
  high,
  @JsonValue('medium')
  medium,
  @JsonValue('low')
  low;

  String getPriorityLabel() {
    switch (this) {
      case TaskPriority.high:
        return 'عالي';
      case TaskPriority.medium:
        return 'متوسط';
      case TaskPriority.low:
        return 'منخفض';
    }
  }

  Color getPriorityColor() {
    switch (this) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.yellow;
      case TaskPriority.low:
        return Colors.blue;
    }
  }
}

@JsonSerializable()
class Subtask {
  @JsonKey(name: 'id')
  /// Subtask ID - null for local subtasks not yet synced
  final String? id;
  final String title;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  final TaskPriority priority;
  @JsonKey(name: 'project_id')
  final String projectId;
  @JsonKey(name: 'user_id')
  /// User ID - null for local subtasks not yet synced
  final String? userId;
  @JsonKey(name: 'created_at')
  /// Creation timestamp - null for local subtasks not yet synced
  final DateTime? createdAt;
  @JsonKey(name: 'completed_at')
  /// Completion timestamp - null if not completed
  final DateTime? completedAt;
  @JsonKey(name: 'time_spent_minutes')
  /// Time spent in minutes - null if not tracked
  final int? timeSpentMinutes;

  Subtask({
    this.id,
    required this.title,
    required this.isCompleted,
    required this.priority,
    required this.projectId,
    this.userId,
    this.createdAt,
    this.completedAt,
    this.timeSpentMinutes,
  });

  Subtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    TaskPriority? priority,
    String? projectId,
    String? userId,
    DateTime? createdAt,
    DateTime? completedAt,
    int? timeSpentMinutes,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
    );
  }

  factory Subtask.fromJson(Map<String, dynamic> json) => _$SubtaskFromJson(json);
  Map<String, dynamic> toJson() => _$SubtaskToJson(this);
}
