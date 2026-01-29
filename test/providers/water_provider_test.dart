import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daily_life_tracker/providers/water_provider.dart';
import 'package:daily_life_tracker/services/water_service.dart';

import 'water_provider_test.mocks.dart';

@GenerateMocks([WaterService])
void main() {
  group('WaterProvider Unit Tests', () {
    late WaterProvider waterProvider;
    late MockWaterService mockWaterService;

    setUp(() {
      mockWaterService = MockWaterService();
      waterProvider = WaterProvider();
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(waterProvider.currentIntakeMl, equals(0));
        expect(waterProvider.currentCups, equals(0));
        expect(waterProvider.targetCups, equals(8));
        expect(waterProvider.isLoading, isFalse);
        expect(waterProvider.error, isNull);
      });
    });

    group('Initialize', () {
      test('should initialize successfully with data', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 750);

        await waterProvider.initialize();

        expect(waterProvider.isLoading, isFalse);
        expect(waterProvider.error, isNull);
        expect(waterProvider.currentIntakeMl, equals(750));
        expect(waterProvider.currentCups, equals(3));
        expect(waterProvider.targetCups, equals(8));
        verify(mockWaterService.getWaterGoal()).called(1);
        verify(mockWaterService.getTodayWaterIntake()).called(1);
      });

      test('should initialize with zero intake', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 0);

        await waterProvider.initialize();

        expect(waterProvider.currentIntakeMl, equals(0));
        expect(waterProvider.currentCups, equals(0));
      });

      test('should handle initialize error', () async {
        when(mockWaterService.getWaterGoal()).thenThrow(PostgrestException('Database error'));

        await waterProvider.initialize();

        expect(waterProvider.isLoading, isFalse);
        expect(waterProvider.error, equals('Database error'));
        expect(waterProvider.currentIntakeMl, equals(0));
      });

      test('should handle general initialize error', () async {
        when(mockWaterService.getWaterGoal()).thenThrow(Exception('General error'));

        await waterProvider.initialize();

        expect(waterProvider.isLoading, isFalse);
        expect(waterProvider.error, equals('حدث خطأ غير متوقع'));
      });

      test('should set loading state during initialize', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return 2000;
        });
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 0);

        final future = waterProvider.initialize();

        expect(waterProvider.isLoading, isTrue);
        await future;
        expect(waterProvider.isLoading, isFalse);
      });

      test('should not initialize multiple times', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 500);

        await waterProvider.initialize();
        await waterProvider.initialize();

        verify(mockWaterService.getWaterGoal()).called(1);
        verify(mockWaterService.getTodayWaterIntake()).called(1);
      });
    });

    group('Add Cup', () {
      setUp(() {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 500);
      });

      test('should add cup successfully', () async {
        when(mockWaterService.logWaterIntake(250)).thenAnswer((_) async {});

        await waterProvider.initialize();
        await waterProvider.addCup();

        expect(waterProvider.currentIntakeMl, equals(750));
        expect(waterProvider.currentCups, equals(3));
        expect(waterProvider.error, isNull);
        verify(mockWaterService.logWaterIntake(250)).called(1);
      });

      test('should not add cup when goal is reached', () async {
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 2000);

        await waterProvider.initialize();
        final originalIntake = waterProvider.currentIntakeMl;
        
        await waterProvider.addCup();

        expect(waterProvider.currentIntakeMl, equals(originalIntake));
        verifyNever(mockWaterService.logWaterIntake(any));
      });

      test('should not add cup when goal is exceeded', () async {
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 1900);

        await waterProvider.initialize();
        await waterProvider.addCup();

        expect(waterProvider.currentIntakeMl, equals(2150));
        verify(mockWaterService.logWaterIntake(250)).called(1);
      });

      test('should handle add cup error', () async {
        when(mockWaterService.logWaterIntake(250))
            .thenThrow(PostgrestException('Log failed'));

        await waterProvider.initialize();
        final originalIntake = waterProvider.currentIntakeMl;
        
        await waterProvider.addCup();

        expect(waterProvider.currentIntakeMl, equals(originalIntake));
        expect(waterProvider.error, equals('Log failed'));
      });

      test('should handle general add cup error', () async {
        when(mockWaterService.logWaterIntake(250))
            .thenThrow(Exception('General error'));

        await waterProvider.initialize();
        final originalIntake = waterProvider.currentIntakeMl;
        
        await waterProvider.addCup();

        expect(waterProvider.currentIntakeMl, equals(originalIntake));
        expect(waterProvider.error, equals('حدث خطأ غير متوقع'));
      });

      test('should clear error on successful add cup', () async {
        when(mockWaterService.logWaterIntake(250))
            .thenThrow(PostgrestException('First error'))
            .thenAnswer((_) async {});

        await waterProvider.initialize();
        await waterProvider.addCup();
        expect(waterProvider.error, isNotNull);

        await waterProvider.addCup();
        expect(waterProvider.error, isNull);
      });
    });

    group('Get Progress', () {
      test('should calculate progress correctly', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 1000);

        await waterProvider.initialize();

        expect(waterProvider.getProgress(), equals(0.5));
      });

      test('should return 0 when goal is 0', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 0);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 1000);

        await waterProvider.initialize();

        expect(waterProvider.getProgress(), equals(0.0));
      });

      test('should return 1.0 when goal is exceeded', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 2500);

        await waterProvider.initialize();

        expect(waterProvider.getProgress(), equals(1.25));
      });

      test('should return 0 when intake is 0', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 0);

        await waterProvider.initialize();

        expect(waterProvider.getProgress(), equals(0.0));
      });
    });

    group('Refresh Water Data', () {
      test('should refresh water data successfully', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2500);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 1250);

        await waterProvider.refreshWaterData();

        expect(waterProvider.isLoading, isFalse);
        expect(waterProvider.error, isNull);
        expect(waterProvider.currentIntakeMl, equals(1250));
        expect(waterProvider.targetCups, equals(10));
        verify(mockWaterService.getWaterGoal()).called(1);
        verify(mockWaterService.getTodayWaterIntake()).called(1);
      });

      test('should handle refresh error', () async {
        when(mockWaterService.getWaterGoal()).thenThrow(PostgrestException('Refresh failed'));

        await waterProvider.refreshWaterData();

        expect(waterProvider.isLoading, isFalse);
        expect(waterProvider.error, equals('Refresh failed'));
      });

      test('should set loading state during refresh', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return 2000;
        });
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 0);

        final future = waterProvider.refreshWaterData();

        expect(waterProvider.isLoading, isTrue);
        await future;
        expect(waterProvider.isLoading, isFalse);
      });
    });

    group('Reset', () {
      test('should reset error state', () async {
        when(mockWaterService.getWaterGoal()).thenThrow(PostgrestException('Test error'));

        await waterProvider.initialize();
        expect(waterProvider.error, isNotNull);

        waterProvider.reset();
        expect(waterProvider.error, isNull);
      });

      test('should not reset intake data', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 750);

        await waterProvider.initialize();
        waterProvider.reset();

        expect(waterProvider.currentIntakeMl, equals(750));
        expect(waterProvider.currentCups, equals(3));
      });
    });

    group('Clear Error', () {
      test('should clear error message', () async {
        when(mockWaterService.getWaterGoal()).thenThrow(PostgrestException('Test error'));

        await waterProvider.initialize();
        expect(waterProvider.error, equals('Test error'));

        waterProvider.clearError();
        expect(waterProvider.error, isNull);
      });
    });

    group('Cup Calculations', () {
      test('should calculate current cups correctly', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 750);

        await waterProvider.initialize();

        expect(waterProvider.currentCups, equals(3));
      });

      test('should calculate target cups correctly for standard goal', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 0);

        await waterProvider.initialize();

        expect(waterProvider.targetCups, equals(8));
      });

      test('should calculate target cups correctly for custom goal', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 1750);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 0);

        await waterProvider.initialize();

        expect(waterProvider.targetCups, equals(7));
      });

      test('should handle partial cup correctly', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 600);

        await waterProvider.initialize();

        expect(waterProvider.currentCups, equals(2));
      });
    });

    group('Edge Cases', () {
      test('should handle very small goal', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 100);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 0);

        await waterProvider.initialize();

        expect(waterProvider.targetCups, equals(1));
        expect(waterProvider.getProgress(), equals(0.0));
      });

      test('should handle very large intake', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 5000);

        await waterProvider.initialize();

        expect(waterProvider.currentCups, equals(20));
        expect(waterProvider.getProgress(), equals(2.5));
      });

      test('should handle zero goal gracefully', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 0);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 1000);

        await waterProvider.initialize();

        expect(waterProvider.targetCups, equals(0));
        expect(waterProvider.getProgress(), equals(0.0));
      });
    });

    group('Notification Listeners', () {
      test('should notify listeners on initialize', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 500);

        var notificationCount = 0;
        waterProvider.addListener(() => notificationCount++);

        await waterProvider.initialize();

        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on add cup', () async {
        when(mockWaterService.getWaterGoal()).thenAnswer((_) async => 2000);
        when(mockWaterService.getTodayWaterIntake()).thenAnswer((_) async => 500);
        when(mockWaterService.logWaterIntake(250)).thenAnswer((_) async {});

        await waterProvider.initialize();

        var notificationCount = 0;
        waterProvider.addListener(() => notificationCount++);

        await waterProvider.addCup();

        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on error', () async {
        when(mockWaterService.logWaterIntake(250))
            .thenThrow(PostgrestException('Error'));

        await waterProvider.initialize();

        var notificationCount = 0;
        waterProvider.addListener(() => notificationCount++);

        await waterProvider.addCup();

        expect(notificationCount, greaterThan(0));
      });
    });
  });
}
