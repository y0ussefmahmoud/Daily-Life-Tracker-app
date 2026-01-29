// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_level_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLevelModel _$UserLevelModelFromJson(Map<String, dynamic> json) =>
    UserLevelModel(
      currentLevel: (json['currentLevel'] as num).toInt(),
      levelTitle: json['levelTitle'] as String,
      currentXP: (json['currentXP'] as num).toInt(),
      xpForNextLevel: (json['xpForNextLevel'] as num).toInt(),
      totalXP: (json['totalXP'] as num).toInt(),
    );

Map<String, dynamic> _$UserLevelModelToJson(UserLevelModel instance) =>
    <String, dynamic>{
      'currentLevel': instance.currentLevel,
      'levelTitle': instance.levelTitle,
      'currentXP': instance.currentXP,
      'xpForNextLevel': instance.xpForNextLevel,
      'totalXP': instance.totalXP,
    };
