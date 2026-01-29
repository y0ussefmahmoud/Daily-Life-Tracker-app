import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'subtask_model.dart';

part 'task_model.g.dart';

@JsonSerializable()
class Task {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  final String title;
  @JsonKey(fromJson: _iconDataFromJson, toJson: _iconDataToJson)
  final IconData icon;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  final String category;
  @JsonKey(name: 'reminder_time', fromJson: _timeOfDayFromJson, toJson: _timeOfDayToJson)
  final TimeOfDay? reminderTime;
  @JsonKey(name: 'is_repeating')
  final bool isRepeating;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(defaultValue: TaskPriority.medium)
  final TaskPriority? priority;

  const Task({
    this.id,
    this.userId,
    required this.title,
    required this.icon,
    required this.isCompleted,
    required this.category,
    this.reminderTime,
    this.isRepeating = false,
    this.createdAt,
    this.priority,
  });

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    IconData? icon,
    bool? isCompleted,
    String? category,
    TimeOfDay? reminderTime,
    bool? isRepeating,
    DateTime? createdAt,
    TaskPriority? priority,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      reminderTime: reminderTime ?? this.reminderTime,
      isRepeating: isRepeating ?? this.isRepeating,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  static IconData _iconDataFromJson(dynamic iconCodePoint) {
    final codePoint = iconCodePoint is int
        ? iconCodePoint
        : int.parse(iconCodePoint as String);
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  static String _iconDataToJson(IconData icon) {
    return icon.codePoint.toString();
  }

  static TimeOfDay? _timeOfDayFromJson(String? timeString) {
    if (timeString == null) return null;
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String? _timeOfDayToJson(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
