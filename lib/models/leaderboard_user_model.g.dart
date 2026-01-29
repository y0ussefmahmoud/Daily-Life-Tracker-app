// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardUserModel _$LeaderboardUserModelFromJson(
        Map<String, dynamic> json) =>
    LeaderboardUserModel(
      rank: (json['rank'] as num).toInt(),
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      xp: (json['xp'] as num).toInt(),
      isCurrentUser: json['isCurrentUser'] as bool,
      badge: json['badge'] as String?,
    );

Map<String, dynamic> _$LeaderboardUserModelToJson(
        LeaderboardUserModel instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'xp': instance.xp,
      'isCurrentUser': instance.isCurrentUser,
      'badge': instance.badge,
    };
