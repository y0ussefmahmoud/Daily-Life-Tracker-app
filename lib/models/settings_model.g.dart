// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) =>
    SettingsModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      prayerNotificationsEnabled: json['prayer_notifications_enabled'] as bool,
      projectRemindersEnabled: json['project_reminders_enabled'] as bool,
      waterTrackerNotificationsEnabled:
          json['water_tracker_notifications_enabled'] as bool,
      darkModeEnabled: json['dark_mode_enabled'] as bool,
      themeColor: json['theme_color'] as String,
    );

Map<String, dynamic> _$SettingsModelToJson(SettingsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'created_at': instance.createdAt?.toIso8601String(),
      'prayer_notifications_enabled': instance.prayerNotificationsEnabled,
      'project_reminders_enabled': instance.projectRemindersEnabled,
      'water_tracker_notifications_enabled':
          instance.waterTrackerNotificationsEnabled,
      'dark_mode_enabled': instance.darkModeEnabled,
      'theme_color': instance.themeColor,
    };
