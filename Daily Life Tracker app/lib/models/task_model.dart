// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'subtask_model.dart';

part 'task_model.g.dart';

enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  int iconCodePoint;
  
  @HiveField(3)
  bool isCompleted;
  
  @HiveField(4)
  String category;
  
  @HiveField(5)
  String? reminderTimeString;
  
  @HiveField(6)
  bool isRepeating;
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    this.isCompleted = false,
    required this.category,
    this.reminderTimeString,
    this.isRepeating = false,
    required this.createdAt,
    this.priority = TaskPriority.medium,
  });

  Task copyWith({
    String? id,
    String? title,
    int? iconCodePoint,
    bool? isCompleted,
    String? category,
    String? reminderTimeString,
    bool? isRepeating,
    DateTime? createdAt,
    TaskPriority? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      reminderTimeString: reminderTimeString ?? this.reminderTimeString,
      isRepeating: isRepeating ?? this.isRepeating,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
    );
  }

  IconData get icon {
    const Map<int, IconData> iconMap = {
      0xe838: Icons.star,
      0xe14a: Icons.home,
      0xe85d: Icons.work,
      0xe7fd: Icons.school,
      0xe7f1: Icons.fitness_center,
      0xe55b: Icons.book,
      0xe87c: Icons.sports_soccer,
      0xe54e: Icons.code,
      0xe8b8: Icons.music_note,
      0xe439: Icons.palette,
    };
    return iconMap[iconCodePoint] ?? Icons.star;
  }

  TimeOfDay? get reminderTime {
    if (reminderTimeString == null) return null;
    try {
      final parts = reminderTimeString!.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  set reminderTime(TimeOfDay? time) {
    if (time == null) {
      reminderTimeString = null;
    } else {
      reminderTimeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
