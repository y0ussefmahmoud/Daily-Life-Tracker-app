import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:daily_life_tracker/providers/settings_provider.dart';
import 'package:daily_life_tracker/services/settings_service.dart';
import 'package:daily_life_tracker/services/auth_service.dart';
import 'package:daily_life_tracker/models/settings_model.dart';

import 'settings_provider_test.mocks.dart';

@GenerateMocks([SettingsService, AuthService])
void main() {
  group('SettingsProvider Unit Tests', () {
    late SettingsProvider settingsProvider;
    late MockSettingsService mockSettingsService;
    late MockAuthService mockAuthService;

    setUp(() {
      mockSettingsService = MockSettingsService();
      mockAuthService = MockAuthService();
      settingsProvider = SettingsProvider(
        settingsService: mockSettingsService,
        authService: mockAuthService,
      );
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(settingsProvider.isLoading, isFalse);
        expect(settingsProvider.prayerNotificationsEnabled, isFalse);
        expect(settingsProvider.projectRemindersEnabled, isFalse);
        expect(settingsProvider.waterTrackerNotificationsEnabled, isFalse);
        expect(settingsProvider.darkModeEnabled, isFalse);
        expect(settingsProvider.themeColor, equals('blue'));
      });
    });

    group('Load Settings', () {
      test('should load settings successfully', () async {
        final testSettings = SettingsModel(
          prayerNotificationsEnabled: true,
          projectRemindersEnabled: true,
          waterTrackerNotificationsEnabled: false,
          darkModeEnabled: true,
          themeColor: 'green',
        );
        
        when(mockSettingsService.fetchSettings()).thenAnswer((_) async => testSettings);

        await settingsProvider.loadSettings();

        expect(settingsProvider.isLoading, isFalse);
        expect(settingsProvider.prayerNotificationsEnabled, isTrue);
        expect(settingsProvider.projectRemindersEnabled, isTrue);
        expect(settingsProvider.waterTrackerNotificationsEnabled, isFalse);
        expect(settingsProvider.darkModeEnabled, isTrue);
        expect(settingsProvider.themeColor, equals('green'));
        verify(mockSettingsService.fetchSettings()).called(1);
      });

      test('should handle load settings error', () async {
        when(mockSettingsService.fetchSettings()).thenThrow(Exception('Load failed'));

        await settingsProvider.loadSettings();

        expect(settingsProvider.isLoading, isFalse);
        expect(settingsProvider.prayerNotificationsEnabled, isFalse);
        expect(settingsProvider.projectRemindersEnabled, isFalse);
        expect(settingsProvider.waterTrackerNotificationsEnabled, isFalse);
        expect(settingsProvider.darkModeEnabled, isFalse);
        expect(settingsProvider.themeColor, equals('blue'));
      });

      test('should set loading state during load', () async {
        when(mockSettingsService.fetchSettings()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return SettingsModel.initial();
        });

        final future = settingsProvider.loadSettings();

        expect(settingsProvider.isLoading, isTrue);
        await future;
        expect(settingsProvider.isLoading, isFalse);
      });

      test('should handle concurrent load requests', () async {
        final testSettings1 = SettingsModel(
          prayerNotificationsEnabled: true,
          projectRemindersEnabled: false,
          waterTrackerNotificationsEnabled: false,
          darkModeEnabled: false,
          themeColor: 'blue',
        );
        
        final testSettings2 = SettingsModel(
          prayerNotificationsEnabled: false,
          projectRemindersEnabled: true,
          waterTrackerNotificationsEnabled: true,
          darkModeEnabled: true,
          themeColor: 'green',
        );

        when(mockSettingsService.fetchSettings()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 50));
          return testSettings1;
        }).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 25));
          return testSettings2;
        });

        final future1 = settingsProvider.loadSettings();
        final future2 = settingsProvider.loadSettings();

        await Future.wait([future1, future2]);

        expect(settingsProvider.prayerNotificationsEnabled, isFalse);
        expect(settingsProvider.projectRemindersEnabled, isTrue);
        expect(settingsProvider.waterTrackerNotificationsEnabled, isTrue);
        expect(settingsProvider.darkModeEnabled, isTrue);
        expect(settingsProvider.themeColor, equals('green'));
      });
    });

    group('Toggle Prayer Notifications', () {
      test('should toggle prayer notifications successfully', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        expect(settingsProvider.prayerNotificationsEnabled, isFalse);

        await settingsProvider.togglePrayerNotifications();

        expect(settingsProvider.prayerNotificationsEnabled, isTrue);
        verify(mockSettingsService.updateSettings(any)).called(1);
      });

      test('should revert on prayer notifications toggle error', () async {
        when(mockSettingsService.updateSettings(any)).thenThrow(Exception('Update failed'));

        expect(settingsProvider.prayerNotificationsEnabled, isFalse);

        await settingsProvider.togglePrayerNotifications();

        expect(settingsProvider.prayerNotificationsEnabled, isFalse);
        verify(mockSettingsService.updateSettings(any)).called(1);
      });

      test('should toggle from true to false', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        await settingsProvider.togglePrayerNotifications();
        expect(settingsProvider.prayerNotificationsEnabled, isTrue);

        await settingsProvider.togglePrayerNotifications();
        expect(settingsProvider.prayerNotificationsEnabled, isFalse);

        verify(mockSettingsService.updateSettings(any)).called(2);
      });
    });

    group('Toggle Project Reminders', () {
      test('should toggle project reminders successfully', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        expect(settingsProvider.projectRemindersEnabled, isFalse);

        await settingsProvider.toggleProjectReminders();

        expect(settingsProvider.projectRemindersEnabled, isTrue);
        verify(mockSettingsService.updateSettings(any)).called(1);
      });

      test('should revert on project reminders toggle error', () async {
        when(mockSettingsService.updateSettings(any)).thenThrow(Exception('Update failed'));

        expect(settingsProvider.projectRemindersEnabled, isFalse);

        await settingsProvider.toggleProjectReminders();

        expect(settingsProvider.projectRemindersEnabled, isFalse);
        verify(mockSettingsService.updateSettings(any)).called(1);
      });

      test('should toggle from true to false', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        await settingsProvider.toggleProjectReminders();
        expect(settingsProvider.projectRemindersEnabled, isTrue);

        await settingsProvider.toggleProjectReminders();
        expect(settingsProvider.projectRemindersEnabled, isFalse);

        verify(mockSettingsService.updateSettings(any)).called(2);
      });
    });

    group('Toggle Water Notifications', () {
      test('should toggle water notifications successfully', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        expect(settingsProvider.waterTrackerNotificationsEnabled, isFalse);

        await settingsProvider.toggleWaterNotifications();

        expect(settingsProvider.waterTrackerNotificationsEnabled, isTrue);
        verify(mockSettingsService.updateSettings(any)).called(1);
      });

      test('should revert on water notifications toggle error', () async {
        when(mockSettingsService.updateSettings(any)).thenThrow(Exception('Update failed'));

        expect(settingsProvider.waterTrackerNotificationsEnabled, isFalse);

        await settingsProvider.toggleWaterNotifications();

        expect(settingsProvider.waterTrackerNotificationsEnabled, isFalse);
        verify(mockSettingsService.updateSettings(any)).called(1);
      });

      test('should toggle from true to false', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        await settingsProvider.toggleWaterNotifications();
        expect(settingsProvider.waterTrackerNotificationsEnabled, isTrue);

        await settingsProvider.toggleWaterNotifications();
        expect(settingsProvider.waterTrackerNotificationsEnabled, isFalse);

        verify(mockSettingsService.updateSettings(any)).called(2);
      });
    });

    group('Toggle Dark Mode', () {
      test('should toggle dark mode successfully', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        expect(settingsProvider.darkModeEnabled, isFalse);

        await settingsProvider.toggleDarkMode();

        expect(settingsProvider.darkModeEnabled, isTrue);
        verify(mockSettingsService.updateSettings(any)).called(1);
      });

      test('should revert on dark mode toggle error', () async {
        when(mockSettingsService.updateSettings(any)).thenThrow(Exception('Update failed'));

        expect(settingsProvider.darkModeEnabled, isFalse);

        await settingsProvider.toggleDarkMode();

        expect(settingsProvider.darkModeEnabled, isFalse);
        verify(mockSettingsService.updateSettings(any)).called(1);
      });

      test('should toggle from true to false', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        await settingsProvider.toggleDarkMode();
        expect(settingsProvider.darkModeEnabled, isTrue);

        await settingsProvider.toggleDarkMode();
        expect(settingsProvider.darkModeEnabled, isFalse);

        verify(mockSettingsService.updateSettings(any)).called(2);
      });
    });

    group('Update Theme', () {
      test('should update theme successfully', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        expect(settingsProvider.themeColor, equals('blue'));

        await settingsProvider.updateTheme('green');

        expect(settingsProvider.themeColor, equals('green'));
        verify(mockSettingsService.updateSettings(any)).called(1);
      });

      test('should revert on theme update error', () async {
        when(mockSettingsService.updateSettings(any)).thenThrow(Exception('Update failed'));

        expect(settingsProvider.themeColor, equals('blue'));

        await settingsProvider.updateTheme('green');

        expect(settingsProvider.themeColor, equals('blue'));
        verify(mockSettingsService.updateSettings(any)).called(1);
      });

      test('should handle multiple theme updates', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        await settingsProvider.updateTheme('green');
        expect(settingsProvider.themeColor, equals('green'));

        await settingsProvider.updateTheme('red');
        expect(settingsProvider.themeColor, equals('red'));

        await settingsProvider.updateTheme('blue');
        expect(settingsProvider.themeColor, equals('blue'));

        verify(mockSettingsService.updateSettings(any)).called(3);
      });

      test('should handle empty theme color', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        await settingsProvider.updateTheme('');

        expect(settingsProvider.themeColor, equals(''));
        verify(mockSettingsService.updateSettings(any)).called(1);
      });
    });

    group('Clear Settings', () {
      test('should clear settings to initial state', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        await settingsProvider.togglePrayerNotifications();
        await settingsProvider.toggleDarkMode();
        await settingsProvider.updateTheme('green');

        expect(settingsProvider.prayerNotificationsEnabled, isTrue);
        expect(settingsProvider.darkModeEnabled, isTrue);
        expect(settingsProvider.themeColor, equals('green'));

        settingsProvider.clearSettings();

        expect(settingsProvider.prayerNotificationsEnabled, isFalse);
        expect(settingsProvider.projectRemindersEnabled, isFalse);
        expect(settingsProvider.waterTrackerNotificationsEnabled, isFalse);
        expect(settingsProvider.darkModeEnabled, isFalse);
        expect(settingsProvider.themeColor, equals('blue'));
        expect(settingsProvider.isLoading, isFalse);
      });

      test('should cancel in-flight requests when clearing', () async {
        final completer = Completer<SettingsModel>();
        when(mockSettingsService.fetchSettings()).thenAnswer((_) => completer.future);

        final loadFuture = settingsProvider.loadSettings();
        expect(settingsProvider.isLoading, isTrue);

        settingsProvider.clearSettings();

        expect(settingsProvider.isLoading, isFalse);
        expect(settingsProvider.prayerNotificationsEnabled, isFalse);

        completer.complete(SettingsModel(
          prayerNotificationsEnabled: true,
          projectRemindersEnabled: true,
          waterTrackerNotificationsEnabled: true,
          darkModeEnabled: true,
          themeColor: 'green',
        ));

        await loadFuture;

        expect(settingsProvider.prayerNotificationsEnabled, isFalse);
      });
    });

    group('Settings Model Integration', () {
      test('should maintain settings consistency', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        await settingsProvider.togglePrayerNotifications();
        await settingsProvider.toggleProjectReminders();
        await settingsProvider.toggleWaterNotifications();
        await settingsProvider.toggleDarkMode();
        await settingsProvider.updateTheme('purple');

        final settings = settingsProvider.settings;
        expect(settings.prayerNotificationsEnabled, isTrue);
        expect(settings.projectRemindersEnabled, isTrue);
        expect(settings.waterTrackerNotificationsEnabled, isTrue);
        expect(settings.darkModeEnabled, isTrue);
        expect(settings.themeColor, equals('purple'));
      });

      test('should handle settings copyWith correctly', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        await settingsProvider.togglePrayerNotifications();
        
        final originalSettings = settingsProvider.settings;
        await settingsProvider.toggleDarkMode();
        
        final newSettings = settingsProvider.settings;
        
        expect(newSettings.prayerNotificationsEnabled, 
               equals(originalSettings.prayerNotificationsEnabled));
        expect(newSettings.darkModeEnabled, 
               isNot(equals(originalSettings.darkModeEnabled)));
        expect(newSettings.projectRemindersEnabled, 
               equals(originalSettings.projectRemindersEnabled));
        expect(newSettings.waterTrackerNotificationsEnabled, 
               equals(originalSettings.waterTrackerNotificationsEnabled));
        expect(newSettings.themeColor, 
               equals(originalSettings.themeColor));
      });
    });

    group('Error Handling', () {
      test('should handle multiple consecutive errors', () async {
        when(mockSettingsService.updateSettings(any)).thenThrow(Exception('Error 1'));

        await settingsProvider.togglePrayerNotifications();
        expect(settingsProvider.prayerNotificationsEnabled, isFalse);

        when(mockSettingsService.updateSettings(any)).thenThrow(Exception('Error 2'));

        await settingsProvider.toggleDarkMode();
        expect(settingsProvider.darkModeEnabled, isFalse);

        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        await settingsProvider.togglePrayerNotifications();
        expect(settingsProvider.prayerNotificationsEnabled, isTrue);
      });

      test('should handle partial update failures', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        await settingsProvider.togglePrayerNotifications();
        expect(settingsProvider.prayerNotificationsEnabled, isTrue);

        when(mockSettingsService.updateSettings(any)).thenThrow(Exception('Update failed'));

        await settingsProvider.toggleProjectReminders();
        expect(settingsProvider.projectRemindersEnabled, isFalse);
        expect(settingsProvider.prayerNotificationsEnabled, isTrue);
      });
    });

    group('Notification Listeners', () {
      test('should notify listeners on settings change', () async {
        when(mockSettingsService.updateSettings(any)).thenAnswer((_) async {});

        var notificationCount = 0;
        settingsProvider.addListener(() => notificationCount++);

        await settingsProvider.togglePrayerNotifications();

        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on error revert', () async {
        when(mockSettingsService.updateSettings(any)).thenThrow(Exception('Error'));

        var notificationCount = 0;
        settingsProvider.addListener(() => notificationCount++);

        await settingsProvider.togglePrayerNotifications();

        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on clear settings', () {
        var notificationCount = 0;
        settingsProvider.addListener(() => notificationCount++);

        settingsProvider.clearSettings();

        expect(notificationCount, equals(1));
      });
    });
  });
}
