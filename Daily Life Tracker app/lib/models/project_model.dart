import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../utils/constants.dart';
import 'subtask_model.dart';

part 'project_model.g.dart';

enum ProjectStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  paused,
  @HiveField(2)
  completed,
  @HiveField(3)
  inProgress,
}

@HiveType(typeId: 1)
class Project {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  double progress;
  
  @HiveField(3)
  List<String> techStack;
  
  @HiveField(4)
  int weeklyHours;
  
  @HiveField(5)
  ProjectStatus status;
  
  @HiveField(6)
  DateTime? deadline;
  
  @HiveField(7)
  String? statusMessage;
  
  @HiveField(8)
  String? weeklyFocus;
  
  @HiveField(9)
  DateTime? startDate;
  
  @HiveField(10)
  DateTime? endDate;
  
  @HiveField(11)
  List<Subtask> subtasks;
  
  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  final String category;

  @HiveField(14)
  final int totalHoursSpent;

  @HiveField(15)
  final int priority;

  @HiveField(16)
  final String? description;

  Project({
    required this.id,
    required this.name,
    required this.progress,
    required this.techStack,
    required this.weeklyHours,
    required this.status,
    this.deadline,
    this.statusMessage,
    this.weeklyFocus,
    this.startDate,
    this.endDate,
    this.subtasks = const [],
    DateTime? createdAt,
    required this.category,
    required this.totalHoursSpent,
    required this.priority,
    this.description,
  }) : createdAt = createdAt ?? DateTime.now();

  Project copyWith({
    String? id,
    String? name,
    double? progress,
    List<String>? techStack,
    int? weeklyHours,
    ProjectStatus? status,
    DateTime? deadline,
    String? statusMessage,
    String? weeklyFocus,
    DateTime? startDate,
    DateTime? endDate,
    List<Subtask>? subtasks,
    DateTime? createdAt,
    String? category,
    int? totalHoursSpent,
    int? priority,
    String? description,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      progress: progress ?? this.progress,
      techStack: techStack ?? this.techStack,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      statusMessage: statusMessage ?? this.statusMessage,
      weeklyFocus: weeklyFocus ?? this.weeklyFocus,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      totalHoursSpent: totalHoursSpent ?? this.totalHoursSpent,
      priority: priority ?? this.priority,
      description: description ?? this.description,
    );
  }

  Color getProgressColor() {
    if (progress > 0.6) {
      return AppColors.primaryColor;
    } else if (progress < 0.4) {
      return AppColors.warningColor;
    } else {
      return AppColors.successColor;
    }
  }

  bool get isCompleted => status == ProjectStatus.completed;

  String get statusText {
    switch (status) {
      case ProjectStatus.active:
        return 'نشط';
      case ProjectStatus.paused:
        return 'متوقف';
      case ProjectStatus.completed:
        return 'مكتمل';
      case ProjectStatus.inProgress:
        return 'قيد التنفيذ';
    }
  }
}
