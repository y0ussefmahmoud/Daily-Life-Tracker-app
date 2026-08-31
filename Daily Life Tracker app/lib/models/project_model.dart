// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'subtask_model.dart';

enum ProjectStatus {
  active,
  paused,
  completed,
  inProgress,
}

class Project {
  String id;
  String name;
  double progress;
  List<String> techStack;
  int weeklyHours;
  ProjectStatus status;
  DateTime? deadline;
  String? statusMessage;
  String? weeklyFocus;
  DateTime? startDate;
  DateTime? endDate;
  List<SubtaskModel> subtasks;
  DateTime createdAt;
  final String category;
  final int totalHoursSpent;
  final int priority;
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
    List<SubtaskModel>? subtasks,
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
