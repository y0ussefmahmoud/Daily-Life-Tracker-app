class SettingsModel {
  final bool prayerNotificationsEnabled;
  final bool projectRemindersEnabled;
  final bool waterTrackerNotificationsEnabled;
  final bool darkModeEnabled;
  final String themeColor;
  final bool soundEnabled;
  final String language;

  const SettingsModel({
    this.prayerNotificationsEnabled = true,
    this.projectRemindersEnabled = true,
    this.waterTrackerNotificationsEnabled = true,
    this.darkModeEnabled = false,
    this.themeColor = 'blue',
    this.soundEnabled = true,
    this.language = 'ar',
  });

  SettingsModel copyWith({
    bool? prayerNotificationsEnabled,
    bool? projectRemindersEnabled,
    bool? waterTrackerNotificationsEnabled,
    bool? darkModeEnabled,
    String? themeColor,
    bool? soundEnabled,
    String? language,
  }) {
    return SettingsModel(
      prayerNotificationsEnabled: prayerNotificationsEnabled ?? this.prayerNotificationsEnabled,
      projectRemindersEnabled: projectRemindersEnabled ?? this.projectRemindersEnabled,
      waterTrackerNotificationsEnabled: waterTrackerNotificationsEnabled ?? this.waterTrackerNotificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      themeColor: themeColor ?? this.themeColor,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      language: language ?? this.language,
    );
  }

  static SettingsModel initial() => const SettingsModel();
}
