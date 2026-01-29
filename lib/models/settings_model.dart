import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings_model.g.dart';

@JsonSerializable()
class SettingsModel {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'prayer_notifications_enabled')
  final bool prayerNotificationsEnabled;
  @JsonKey(name: 'project_reminders_enabled')
  final bool projectRemindersEnabled;
  @JsonKey(name: 'water_tracker_notifications_enabled')
  final bool waterTrackerNotificationsEnabled;
  @JsonKey(name: 'dark_mode_enabled')
  final bool darkModeEnabled;
  @JsonKey(name: 'theme_color')
  final String themeColor;

  const SettingsModel({
    this.id,
    this.userId,
    this.createdAt,
    required this.prayerNotificationsEnabled,
    required this.projectRemindersEnabled,
    required this.waterTrackerNotificationsEnabled,
    required this.darkModeEnabled,
    required this.themeColor,
  });

  SettingsModel copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    bool? prayerNotificationsEnabled,
    bool? projectRemindersEnabled,
    bool? waterTrackerNotificationsEnabled,
    bool? darkModeEnabled,
    String? themeColor,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      prayerNotificationsEnabled: prayerNotificationsEnabled ?? this.prayerNotificationsEnabled,
      projectRemindersEnabled: projectRemindersEnabled ?? this.projectRemindersEnabled,
      waterTrackerNotificationsEnabled: waterTrackerNotificationsEnabled ?? this.waterTrackerNotificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      themeColor: themeColor ?? this.themeColor,
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) => _$SettingsModelFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsModelToJson(this);

  factory SettingsModel.initial() {
    return const SettingsModel(
      prayerNotificationsEnabled: false,
      projectRemindersEnabled: false,
      waterTrackerNotificationsEnabled: false,
      darkModeEnabled: false,
      themeColor: 'blue',
    );
  }
}
