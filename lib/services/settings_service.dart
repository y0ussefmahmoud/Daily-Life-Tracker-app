import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/settings_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class SettingsService {
  final SupabaseClient _supabase = SupabaseService.client;
  final AuthService _authService = AuthService();

  Future<SettingsModel> fetchSettings() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return SettingsModel.initial();
      }

      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .limit(1);

      if (response is List && response.isNotEmpty) {
        final settingsData = response.first as Map<String, dynamic>;
        return SettingsModel.fromJson(settingsData);
      }

      return SettingsModel.initial();
    } on PostgrestException catch (e) {
      print('Error fetching settings: $e');
      return SettingsModel.initial();
    } catch (e) {
      print('Unexpected error fetching settings: $e');
      return SettingsModel.initial();
    }
  }

  Future<String> createSettings(SettingsModel settings) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('user_settings')
          .insert({
            'user_id': userId,
            'prayer_notifications_enabled': settings.prayerNotificationsEnabled,
            'project_reminders_enabled': settings.projectRemindersEnabled,
            'water_tracker_notifications_enabled': settings.waterTrackerNotificationsEnabled,
            'dark_mode_enabled': settings.darkModeEnabled,
            'theme_color': settings.themeColor,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } on PostgrestException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateSettings(SettingsModel settings) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Check if settings exist for this user
      final existingSettings = await _supabase
          .from('user_settings')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      if (existingSettings is List && existingSettings.isEmpty) {
        // Create new settings if they don't exist
        await createSettings(settings);
      } else {
        // Update existing settings - only send mutable fields
        await _supabase
            .from('user_settings')
            .update({
              'prayer_notifications_enabled': settings.prayerNotificationsEnabled,
              'project_reminders_enabled': settings.projectRemindersEnabled,
              'water_tracker_notifications_enabled': settings.waterTrackerNotificationsEnabled,
              'dark_mode_enabled': settings.darkModeEnabled,
              'theme_color': settings.themeColor,
            })
            .eq('user_id', userId);
      }
    } on PostgrestException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateField(String field, dynamic value) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Check if settings exist for this user
      final existingSettings = await _supabase
          .from('user_settings')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      if (existingSettings is List && existingSettings.isEmpty) {
        // Create default settings first, then update the specific field
        final defaultSettings = SettingsModel.initial();
        await createSettings(defaultSettings);
      }

      // Update the specific field
      await _supabase
          .from('user_settings')
          .update({field: value})
          .eq('user_id', userId);
    } on PostgrestException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
