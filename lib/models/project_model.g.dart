// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as String?,
      name: json['name'] as String,
      progress: (json['progress'] as num).toDouble(),
      techStack: (json['tech_stack'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      weeklyHours: (json['weekly_hours'] as num).toInt(),
      status: $enumDecode(_$ProjectStatusEnumMap, json['status']),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      statusMessage: json['status_message'] as String?,
      weeklyFocus: json['weekly_focus'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((e) => Subtask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'progress': instance.progress,
      'tech_stack': instance.techStack,
      'weekly_hours': instance.weeklyHours,
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'deadline': instance.deadline?.toIso8601String(),
      'status_message': instance.statusMessage,
      'weekly_focus': instance.weeklyFocus,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'subtasks': instance.subtasks,
      'user_id': instance.userId,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.active: 'active',
  ProjectStatus.paused: 'paused',
  ProjectStatus.completed: 'completed',
};
