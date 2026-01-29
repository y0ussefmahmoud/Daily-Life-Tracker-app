// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeModel _$BadgeModelFromJson(Map<String, dynamic> json) => BadgeModel(
      userId: json['userId'] as String?,
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String?,
      icon: BadgeModel._iconDataFromJson((json['icon'] as num).toInt()),
      isEarned: json['isEarned'] as bool,
      progress: (json['progress'] as num).toDouble(),
      earnedDate: json['earnedDate'] == null
          ? null
          : DateTime.parse(json['earnedDate'] as String),
      category: $enumDecode(_$BadgeCategoryEnumMap, json['category']),
      color: BadgeModel._colorFromJson((json['color'] as num).toInt()),
    );

Map<String, dynamic> _$BadgeModelToJson(BadgeModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'icon': BadgeModel._iconDataToJson(instance.icon),
      'isEarned': instance.isEarned,
      'progress': instance.progress,
      'earnedDate': instance.earnedDate?.toIso8601String(),
      'category': _$BadgeCategoryEnumMap[instance.category]!,
      'color': BadgeModel._colorToJson(instance.color),
    };

const _$BadgeCategoryEnumMap = {
  BadgeCategory.prayer: 'prayer',
  BadgeCategory.projects: 'projects',
  BadgeCategory.health: 'health',
  BadgeCategory.social: 'social',
  BadgeCategory.productivity: 'productivity',
  BadgeCategory.learning: 'learning',
};
