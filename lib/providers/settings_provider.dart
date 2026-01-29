import 'package:flutter/foundation.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  final AuthService _authService;
  
  SettingsProvider({
    SettingsService? settingsService,
    AuthService? authService,
  }) : _settingsService = settingsService ?? SettingsService(),
       _authService = authService ?? AuthService();
  SettingsModel _settings = SettingsModel.initial();
  bool _isLoading = false;
  int _loadRequestId = 0;
  
  SettingsModel get settings => _settings;
  bool get isLoading => _isLoading;

  bool get prayerNotificationsEnabled => _settings.prayerNotificationsEnabled;
  bool get projectRemindersEnabled => _settings.projectRemindersEnabled;
  bool get waterTrackerNotificationsEnabled => _settings.waterTrackerNotificationsEnabled;
  bool get darkModeEnabled => _settings.darkModeEnabled;
  String get themeColor => _settings.themeColor;

  Future<void> loadSettings() async {
    final currentRequestId = ++_loadRequestId;
    final currentUserId = _authService.currentUser?.id;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final fetchedSettings = await _settingsService.fetchSettings();
      
      // Verify this request is still valid and user hasn't changed
      if (currentRequestId != _loadRequestId || 
          currentUserId != _authService.currentUser?.id) {
        // User logged out during fetch or new request started, discard results
        return;
      }
      
      _settings = fetchedSettings;
    } catch (e) {
      print('Error loading settings: $e');
      // Only apply error state if this request is still valid
      if (currentRequestId == _loadRequestId) {
        _settings = SettingsModel.initial();
      }
    }
    
    // Only update loading state if this is the current request
    if (currentRequestId == _loadRequestId) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePrayerNotifications() async {
    final originalValue = _settings.prayerNotificationsEnabled;
    _settings = _settings.copyWith(
      prayerNotificationsEnabled: !_settings.prayerNotificationsEnabled,
    );
    notifyListeners();
    
    try {
      await _settingsService.updateSettings(_settings);
    } catch (e) {
      print('Error updating prayer notifications: $e');
      // Revert on error
      _settings = _settings.copyWith(prayerNotificationsEnabled: originalValue);
      notifyListeners();
    }
  }

  Future<void> toggleProjectReminders() async {
    final originalValue = _settings.projectRemindersEnabled;
    _settings = _settings.copyWith(
      projectRemindersEnabled: !_settings.projectRemindersEnabled,
    );
    notifyListeners();
    
    try {
      await _settingsService.updateSettings(_settings);
    } catch (e) {
      print('Error updating project reminders: $e');
      // Revert on error
      _settings = _settings.copyWith(projectRemindersEnabled: originalValue);
      notifyListeners();
    }
  }

  Future<void> toggleWaterNotifications() async {
    final originalValue = _settings.waterTrackerNotificationsEnabled;
    _settings = _settings.copyWith(
      waterTrackerNotificationsEnabled: !_settings.waterTrackerNotificationsEnabled,
    );
    notifyListeners();
    
    try {
      await _settingsService.updateSettings(_settings);
    } catch (e) {
      print('Error updating water notifications: $e');
      // Revert on error
      _settings = _settings.copyWith(waterTrackerNotificationsEnabled: originalValue);
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    final originalValue = _settings.darkModeEnabled;
    _settings = _settings.copyWith(
      darkModeEnabled: !_settings.darkModeEnabled,
    );
    notifyListeners();
    
    try {
      await _settingsService.updateSettings(_settings);
    } catch (e) {
      print('Error updating dark mode: $e');
      // Revert on error
      _settings = _settings.copyWith(darkModeEnabled: originalValue);
      notifyListeners();
    }
  }

  Future<void> updateTheme(String color) async {
    final originalValue = _settings.themeColor;
    _settings = _settings.copyWith(themeColor: color);
    notifyListeners();
    
    try {
      await _settingsService.updateSettings(_settings);
    } catch (e) {
      print('Error updating theme: $e');
      // Revert on error
      _settings = _settings.copyWith(themeColor: originalValue);
      notifyListeners();
    }
  }

  void clearSettings() {
    // Cancel any in-flight requests by incrementing request ID
    _loadRequestId++;
    _settings = SettingsModel.initial();
    notifyListeners();
  }
}
