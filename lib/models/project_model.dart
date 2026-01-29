import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../utils/constants.dart';
import 'subtask_model.dart';

part 'project_model.g.dart';

enum ProjectStatus {
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('completed')
  completed,
}

@JsonSerializable()
class Project {
  @JsonKey(name: 'id')
  final String? id;
  final String name;
  final double progress;
  @JsonKey(name: 'tech_stack')
  final List<String> techStack;
  @JsonKey(name: 'weekly_hours')
  final int weeklyHours;
  final ProjectStatus status;
  final DateTime? deadline;
  @JsonKey(name: 'status_message')
  final String? statusMessage;
  @JsonKey(name: 'weekly_focus')
  final String? weeklyFocus;
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @JsonKey(name: 'subtasks')
  final List<Subtask> subtasks;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const Project({
    this.id,
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
    this.userId,
    this.createdAt,
  });

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
    String? userId,
    DateTime? createdAt,
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
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  Color getProgressColor() {
    if (progress > 0.6) {
      return AppColors.primaryColor;
    } else if (progress < 0.4) {
      return AppColors.warningColor;
    } else {
      return AppColors.successColor;
    }
  }

  String get statusText {
    switch (status) {
      case ProjectStatus.active:
        return 'نشط';
      case ProjectStatus.paused:
        return 'متوقف';
      case ProjectStatus.completed:
        return 'مكتمل';
    }
  }
}
