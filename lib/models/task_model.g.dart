// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      icon: Task._iconDataFromJson(json['icon']),
      isCompleted: json['is_completed'] as bool,
      category: json['category'] as String,
      reminderTime: Task._timeOfDayFromJson(json['reminder_time'] as String?),
      isRepeating: json['is_repeating'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      priority: $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']) ??
          TaskPriority.medium,
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'icon': Task._iconDataToJson(instance.icon),
      'is_completed': instance.isCompleted,
      'category': instance.category,
      'reminder_time': Task._timeOfDayToJson(instance.reminderTime),
      'is_repeating': instance.isRepeating,
      'created_at': instance.createdAt?.toIso8601String(),
      'priority': _$TaskPriorityEnumMap[instance.priority],
    };

const _$TaskPriorityEnumMap = {
  TaskPriority.high: 'high',
  TaskPriority.medium: 'medium',
  TaskPriority.low: 'low',
};
