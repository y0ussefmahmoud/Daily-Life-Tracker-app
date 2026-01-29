// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      badgeCount: (json['badgeCount'] as num).toInt(),
      streakDays: (json['streakDays'] as num).toInt(),
      points: (json['points'] as num).toInt(),
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'subtitle': instance.subtitle,
      'avatarUrl': instance.avatarUrl,
      'badgeCount': instance.badgeCount,
      'streakDays': instance.streakDays,
      'points': instance.points,
    };
