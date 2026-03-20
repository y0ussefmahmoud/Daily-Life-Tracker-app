import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/settings_model.dart';
import '../services/local_database_service.dart';

class SettingsProvider extends ChangeNotifier {
  final LocalDatabaseService _db = LocalDatabaseService();
  bool _isDatabaseInitialized = false;
  
  SettingsModel _settings = SettingsModel.initial();
  bool _isLoading = false;
  String? _error;
  
  SettingsProvider() {
    _initializeSettings();
  }
  
  Future<void> _initializeSettings() async {
    try {
      await loadSettings();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
      // Keep default settings if initialization fails
    }
  }
  
  SettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get prayerNotificationsEnabled => _settings.prayerNotificationsEnabled;
  bool get projectRemindersEnabled => _settings.projectRemindersEnabled;
  bool get waterTrackerNotificationsEnabled => _settings.waterTrackerNotificationsEnabled;
  bool get darkModeEnabled => _settings.darkModeEnabled;
  String get themeColor => _settings.themeColor;
  
  // New settings for profile screen
  bool get isDarkMode => _settings.darkModeEnabled;
  bool get profileNotificationsEnabled => _settings.prayerNotificationsEnabled;
  bool get soundEnabled => _settings.soundEnabled;
  String get currentLanguage => _settings.language;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Initialize database if not already initialized with timeout
      if (!_isDatabaseInitialized) {
        await _db.initialize().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw Exception('Database initialization timeout');
          },
        );
        _isDatabaseInitialized = true;
      }
      
      // Load settings from local database with timeout
      final prayerNotificationsResult = await _db.getSetting('prayer_notifications_enabled').timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      final projectRemindersResult = await _db.getSetting('project_reminders_enabled').timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      final waterNotificationsResult = await _db.getSetting('water_tracker_notifications_enabled').timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      final darkModeResult = await _db.getSetting('dark_mode_enabled').timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      final themeColorResult = await _db.getSetting('theme_color').timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      
      final prayerNotifications = prayerNotificationsResult ?? true;
      final projectReminders = projectRemindersResult ?? true;
      final waterNotifications = waterNotificationsResult ?? true;
      final darkMode = darkModeResult ?? false;
      final themeColor = themeColorResult ?? 'blue';
      
      _settings = SettingsModel(
        prayerNotificationsEnabled: prayerNotifications as bool,
        projectRemindersEnabled: projectReminders as bool,
        waterTrackerNotificationsEnabled: waterNotifications as bool,
        darkModeEnabled: darkMode as bool,
        themeColor: themeColor as String,
      );
    } catch (e) {
      _error = 'Failed to load settings: $e';
      debugPrint('Settings load error: $e');
      // Keep default settings on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePrayerNotifications(bool enabled) async {
    await _updateSetting('prayer_notifications_enabled', enabled);
    _settings = _settings.copyWith(prayerNotificationsEnabled: enabled);
    notifyListeners();
  }

  Future<void> updateProjectReminders(bool enabled) async {
    await _updateSetting('project_reminders_enabled', enabled);
    _settings = _settings.copyWith(projectRemindersEnabled: enabled);
    notifyListeners();
  }

  Future<void> updateWaterTrackerNotifications(bool enabled) async {
    await _updateSetting('water_tracker_notifications_enabled', enabled);
    _settings = _settings.copyWith(waterTrackerNotificationsEnabled: enabled);
    notifyListeners();
  }

  Future<void> updateDarkMode(bool enabled) async {
    await _updateSetting('dark_mode_enabled', enabled);
    _settings = _settings.copyWith(darkModeEnabled: enabled);
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    await _updateSetting('language', language);
    _settings = _settings.copyWith(language: language);
    notifyListeners();
  }

  Locale get locale {
    switch (_settings.language) {
      case 'ar':
        return const Locale('ar');
      case 'en':
        return const Locale('en');
      default:
        return const Locale('ar');
    }
  }

  Future<void> toggleLanguage() async {
    final newLanguage = _settings.language == 'ar' ? 'en' : 'ar';
    await updateLanguage(newLanguage);
  }

  // Add missing methods for compatibility
  void togglePrayerNotifications(bool enabled) {
    updatePrayerNotifications(enabled);
  }

  void toggleProjectReminders(bool enabled) {
    updateProjectReminders(enabled);
  }

  void setNotificationsEnabled(bool enabled) {
    updateWaterTrackerNotifications(enabled);
  }

  void setArabicEnabled(bool enabled) {
    _updateSetting('arabic_enabled', enabled);
    notifyListeners();
  }

  bool get notificationsEnabled => _settings.waterTrackerNotificationsEnabled;
  bool get isArabicEnabled => true; // Default to Arabic

  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      if (!_isDatabaseInitialized) {
        _error = 'Database not initialized';
        notifyListeners();
        return;
      }
      
      await _db.setSetting(key, value);
      _error = null;
    } catch (e) {
      _error = 'Failed to update setting: $e';
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void setDatabaseInitialized() {
    _isDatabaseInitialized = true;
  }
  
  // New methods for profile screen
  Future<void> toggleDarkMode() async {
    try {
      final newDarkMode = !_settings.darkModeEnabled;
      await _updateSetting('dark_mode_enabled', newDarkMode);
      _settings = _settings.copyWith(darkModeEnabled: newDarkMode);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle dark mode: $e';
      notifyListeners();
    }
  }
  
  Future<void> toggleNotifications() async {
    try {
      final newNotifications = !_settings.prayerNotificationsEnabled;
      await _updateSetting('prayer_notifications_enabled', newNotifications);
      _settings = _settings.copyWith(prayerNotificationsEnabled: newNotifications);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle notifications: $e';
      notifyListeners();
    }
  }
  
  Future<void> toggleSound() async {
    try {
      final newSound = !_settings.soundEnabled;
      await _updateSetting('sound_enabled', newSound);
      _settings = _settings.copyWith(soundEnabled: newSound);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle sound: $e';
      notifyListeners();
    }
  }
  
  Future<void> changeLanguage(String language) async {
    try {
      await _updateSetting('language', language);
      _settings = _settings.copyWith(language: language);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to change language: $e';
      notifyListeners();
    }
  }
}
