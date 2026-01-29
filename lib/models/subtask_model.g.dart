// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subtask _$SubtaskFromJson(Map<String, dynamic> json) => Subtask(
      id: json['id'] as String?,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool,
      priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
      projectId: json['project_id'] as String,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      timeSpentMinutes: (json['time_spent_minutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SubtaskToJson(Subtask instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'is_completed': instance.isCompleted,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'project_id': instance.projectId,
      'user_id': instance.userId,
      'created_at': instance.createdAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'time_spent_minutes': instance.timeSpentMinutes,
    };

const _$TaskPriorityEnumMap = {
  TaskPriority.high: 'high',
  TaskPriority.medium: 'medium',
  TaskPriority.low: 'low',
};
