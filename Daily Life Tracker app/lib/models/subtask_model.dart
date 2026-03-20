import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'subtask_model.g.dart';

enum SubtaskPriority {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low;

  String getPriorityLabel() {
    switch (this) {
      case SubtaskPriority.high:
        return 'عالي';
      case SubtaskPriority.medium:
        return 'متوسط';
      case SubtaskPriority.low:
        return 'منخفض';
    }
  }

  Color getPriorityColor() {
    switch (this) {
      case SubtaskPriority.high:
        return Colors.red;
      case SubtaskPriority.medium:
        return Colors.yellow;
      case SubtaskPriority.low:
        return Colors.blue;
    }
  }
}

@HiveType(typeId: 2)
class Subtask {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  bool isCompleted;
  
  @HiveField(3)
  SubtaskPriority priority;
  
  @HiveField(4)
  String projectId;
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  DateTime? completedAt;
  
  @HiveField(7)
  int? timeSpentMinutes;

  Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.priority,
    required this.projectId,
    DateTime? createdAt,
    this.completedAt,
    this.timeSpentMinutes,
  }) : createdAt = createdAt ?? DateTime.now();

  Subtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    SubtaskPriority? priority,
    String? projectId,
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
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
    );
  }
}
