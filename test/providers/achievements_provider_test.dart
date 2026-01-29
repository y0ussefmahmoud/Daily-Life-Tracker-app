import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:daily_life_tracker/providers/achievements_provider.dart';
import 'package:daily_life_tracker/services/achievements_service.dart';
import 'package:daily_life_tracker/models/badge_model.dart';
import 'package:daily_life_tracker/models/user_level_model.dart';
import 'package:daily_life_tracker/models/leaderboard_user_model.dart';

import 'achievements_provider_test.mocks.dart';

@GenerateMocks([AchievementsService, UserLevelModel, BadgeModel, LeaderboardUserModel])
void main() {
  group('AchievementsProvider Unit Tests', () {
    late AchievementsProvider achievementsProvider;
    late MockAchievementsService mockAchievementsService;

    setUp(() {
      mockAchievementsService = MockAchievementsService();
      achievementsProvider = AchievementsProvider();
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(achievementsProvider.userLevel, isNull);
        expect(achievementsProvider.earnedBadges, isEmpty);
        expect(achievementsProvider.lockedBadges, isEmpty);
        expect(achievementsProvider.allBadges, isEmpty);
        expect(achievementsProvider.leaderboard, isEmpty);
        expect(achievementsProvider.earnedBadgeCount, equals(0));
        expect(achievementsProvider.isLoading, isFalse);
        expect(achievementsProvider.currentLevelPoints, equals(0));
        expect(achievementsProvider.error, isNull);
      });
    });

    group('Load Achievements Data', () {
      test('should load achievements data successfully', () async {
        final mockUserLevel = MockUserLevel();
        when(mockUserLevel.currentXP).thenReturn(100);
        when(mockUserLevel.totalXP).thenReturn(250);
        
        final mockBadge1 = MockBadgeModel();
        when(mockBadge1.isEarned).thenReturn(true);
        when(mockBadge1.id).thenReturn('badge1');
        
        final mockBadge2 = MockBadgeModel();
        when(mockBadge2.isEarned).thenReturn(false);
        when(mockBadge2.id).thenReturn('badge2');
        
        final mockLeaderboardUser = MockLeaderboardUserModel();
        
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => mockUserLevel);
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => [mockBadge1, mockBadge2]);
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => [mockLeaderboardUser]);

        await achievementsProvider.loadAchievementsData();

        expect(achievementsProvider.isLoading, isFalse);
        expect(achievementsProvider.error, isNull);
        expect(achievementsProvider.userLevel, equals(mockUserLevel));
        expect(achievementsProvider.earnedBadges.length, equals(1));
        expect(achievementsProvider.lockedBadges.length, equals(1));
        expect(achievementsProvider.allBadges.length, equals(2));
        expect(achievementsProvider.leaderboard.length, equals(1));
        expect(achievementsProvider.earnedBadgeCount, equals(1));
        expect(achievementsProvider.currentLevelPoints, equals(100));
        
        verify(mockAchievementsService.fetchUserLevel()).called(1);
        verify(mockAchievementsService.fetchUserBadges()).called(1);
        verify(mockAchievementsService.fetchLeaderboard()).called(1);
      });

      test('should handle load achievements data error', () async {
        when(mockAchievementsService.fetchUserLevel()).thenThrow(Exception('Load failed'));

        await achievementsProvider.loadAchievementsData();

        expect(achievementsProvider.isLoading, isFalse);
        expect(achievementsProvider.error, isNotNull);
        expect(achievementsProvider.userLevel, isNull);
      });

      test('should set loading state during load', () async {
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return MockUserLevel();
        });
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => []);
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => []);

        final future = achievementsProvider.loadAchievementsData();

        expect(achievementsProvider.isLoading, isTrue);
        await future;
        expect(achievementsProvider.isLoading, isFalse);
      });

      test('should handle empty data', () async {
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => null);
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => []);
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => []);

        await achievementsProvider.loadAchievementsData();

        expect(achievementsProvider.userLevel, isNull);
        expect(achievementsProvider.earnedBadges, isEmpty);
        expect(achievementsProvider.lockedBadges, isEmpty);
        expect(achievementsProvider.leaderboard, isEmpty);
        expect(achievementsProvider.earnedBadgeCount, equals(0));
        expect(achievementsProvider.currentLevelPoints, equals(0));
      });
    });

    group('Earn Badge', () {
      setUp(() {
        final mockBadge = MockBadgeModel();
        when(mockBadge.isEarned).thenReturn(false);
        when(mockBadge.id).thenReturn('test-badge');
        when(mockBadge.copyWith(
          isEarned: anyNamed('isEarned'),
          progress: anyNamed('progress'),
          earnedDate: anyNamed('earnedDate'),
        )).thenReturn(mockBadge);
        
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => [mockBadge]);
        when(mockAchievementsService.earnBadge(any)).thenAnswer((_) async {});
        when(mockAchievementsService.addXP(any)).thenAnswer((_) async {});
        when(mockAchievementsService.checkBadgeProgress()).thenAnswer((_) async {});
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => MockUserLevel());
      });

      test('should earn badge successfully', () async {
        await achievementsProvider.loadAchievementsData();
        
        await achievementsProvider.earnBadge('test-badge');

        verify(mockAchievementsService.earnBadge('test-badge')).called(1);
        verify(mockAchievementsService.addXP(50)).called(1);
        verify(mockAchievementsService.checkBadgeProgress()).called(1);
        verify(mockAchievementsService.fetchUserLevel()).called(1);
      });

      test('should not earn already earned badge', () async {
        final mockBadge = MockBadgeModel();
        when(mockBadge.isEarned).thenReturn(true);
        when(mockBadge.id).thenReturn('earned-badge');
        
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => [mockBadge]);
        when(mockAchievementsService.earnBadge(any)).thenAnswer((_) async {});

        await achievementsProvider.loadAchievementsData();
        await achievementsProvider.earnBadge('earned-badge');

        verify(mockAchievementsService.earnBadge('earned-badge')).called(1);
        verifyNever(mockAchievementsService.addXP(any));
      });

      test('should handle earn badge error', () async {
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => []);
        when(mockAchievementsService.earnBadge(any)).thenThrow(Exception('Earn failed'));

        await achievementsProvider.loadAchievementsData();
        await achievementsProvider.earnBadge('non-existent');

        expect(achievementsProvider.error, isNotNull);
      });

      test('should handle non-existent badge', () async {
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => []);
        when(mockAchievementsService.earnBadge(any)).thenAnswer((_) async {});

        await achievementsProvider.loadAchievementsData();
        await achievementsProvider.earnBadge('non-existent');

        verify(mockAchievementsService.earnBadge('non-existent')).called(1);
        verifyNever(mockAchievementsService.addXP(any));
      });
    });

    group('Add XP', () {
      test('should add XP successfully', () async {
        when(mockAchievementsService.addXP(any)).thenAnswer((_) async {});
        when(mockAchievementsService.checkBadgeProgress()).thenAnswer((_) async {});
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => MockUserLevel());

        await achievementsProvider.addXP(25);

        verify(mockAchievementsService.addXP(25)).called(1);
        verify(mockAchievementsService.checkBadgeProgress()).called(1);
        verify(mockAchievementsService.fetchUserLevel()).called(1);
      });

      test('should handle add XP error', () async {
        when(mockAchievementsService.addXP(any)).thenThrow(Exception('Add XP failed'));

        await achievementsProvider.addXP(25);

        expect(achievementsProvider.error, isNotNull);
      });

      test('should handle check badge progress error', () async {
        when(mockAchievementsService.addXP(any)).thenAnswer((_) async {});
        when(mockAchievementsService.checkBadgeProgress()).thenThrow(Exception('Check progress failed'));

        await achievementsProvider.addXP(25);

        expect(achievementsProvider.error, isNotNull);
      });

      test('should handle fetch user level error', () async {
        when(mockAchievementsService.addXP(any)).thenAnswer((_) async {});
        when(mockAchievementsService.checkBadgeProgress()).thenAnswer((_) async {});
        when(mockAchievementsService.fetchUserLevel()).thenThrow(Exception('Fetch level failed'));

        await achievementsProvider.addXP(25);

        expect(achievementsProvider.error, isNotNull);
      });
    });

    group('Refresh Leaderboard', () {
      test('should refresh leaderboard successfully', () async {
        final mockLeaderboardUser = MockLeaderboardUserModel();
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => [mockLeaderboardUser]);

        await achievementsProvider.refreshLeaderboard();

        expect(achievementsProvider.leaderboard.length, equals(1));
        verify(mockAchievementsService.fetchLeaderboard()).called(1);
      });

      test('should handle refresh leaderboard error', () async {
        when(mockAchievementsService.fetchLeaderboard()).thenThrow(Exception('Refresh failed'));

        await achievementsProvider.refreshLeaderboard();

        expect(achievementsProvider.error, isNotNull);
      });

      test('should handle empty leaderboard', () async {
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => []);

        await achievementsProvider.refreshLeaderboard();

        expect(achievementsProvider.leaderboard, isEmpty);
      });
    });

    group('Badge Filtering', () {
      test('should filter earned badges correctly', () async {
        final earnedBadge = MockBadgeModel();
        when(earnedBadge.isEarned).thenReturn(true);
        when(earnedBadge.id).thenReturn('earned');
        
        final lockedBadge = MockBadgeModel();
        when(lockedBadge.isEarned).thenReturn(false);
        when(lockedBadge.id).thenReturn('locked');
        
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => MockUserLevel());
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => [earnedBadge, lockedBadge]);
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => []);

        await achievementsProvider.loadAchievementsData();

        expect(achievementsProvider.earnedBadges.length, equals(1));
        expect(achievementsProvider.earnedBadges[0].id, equals('earned'));
        expect(achievementsProvider.lockedBadges.length, equals(1));
        expect(achievementsProvider.lockedBadges[0].id, equals('locked'));
        expect(achievementsProvider.allBadges.length, equals(2));
      });

      test('should handle all earned badges', () async {
        final earnedBadge1 = MockBadgeModel();
        when(earnedBadge1.isEarned).thenReturn(true);
        when(earnedBadge1.id).thenReturn('earned1');
        
        final earnedBadge2 = MockBadgeModel();
        when(earnedBadge2.isEarned).thenReturn(true);
        when(earnedBadge2.id).thenReturn('earned2');
        
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => MockUserLevel());
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => [earnedBadge1, earnedBadge2]);
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => []);

        await achievementsProvider.loadAchievementsData();

        expect(achievementsProvider.earnedBadges.length, equals(2));
        expect(achievementsProvider.lockedBadges, isEmpty);
        expect(achievementsProvider.earnedBadgeCount, equals(2));
      });

      test('should handle all locked badges', () async {
        final lockedBadge1 = MockBadgeModel();
        when(lockedBadge1.isEarned).thenReturn(false);
        when(lockedBadge1.id).thenReturn('locked1');
        
        final lockedBadge2 = MockBadgeModel();
        when(lockedBadge2.isEarned).thenReturn(false);
        when(lockedBadge2.id).thenReturn('locked2');
        
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => MockUserLevel());
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => [lockedBadge1, lockedBadge2]);
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => []);

        await achievementsProvider.loadAchievementsData();

        expect(achievementsProvider.earnedBadges, isEmpty);
        expect(achievementsProvider.lockedBadges.length, equals(2));
        expect(achievementsProvider.earnedBadgeCount, equals(0));
      });
    });

    group('Getters', () {
      test('should return correct current level points when user level is null', () {
        expect(achievementsProvider.currentLevelPoints, equals(0));
      });

      test('should return correct current level points when user level exists', () async {
        final mockUserLevel = MockUserLevel();
        when(mockUserLevel.currentXP).thenReturn(150);
        
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => mockUserLevel);
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => []);
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => []);

        await achievementsProvider.loadAchievementsData();

        expect(achievementsProvider.currentLevelPoints, equals(150));
      });

      test('should return badges getter for compatibility', () async {
        final mockBadge = MockBadgeModel();
        when(mockBadge.isEarned).thenReturn(true);
        
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => MockUserLevel());
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => [mockBadge]);
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => []);

        await achievementsProvider.loadAchievementsData();

        expect(achievementsProvider.badges.length, equals(1));
        expect(achievementsProvider.badges, equals(achievementsProvider.allBadges));
      });
    });

    group('Notification Listeners', () {
      test('should notify listeners on load achievements data', () async {
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => MockUserLevel());
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => []);
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => []);

        var notificationCount = 0;
        achievementsProvider.addListener(() => notificationCount++);

        await achievementsProvider.loadAchievementsData();

        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on earn badge', () async {
        final mockBadge = MockBadgeModel();
        when(mockBadge.isEarned).thenReturn(false);
        when(mockBadge.id).thenReturn('test-badge');
        when(mockBadge.copyWith(
          isEarned: anyNamed('isEarned'),
          progress: anyNamed('progress'),
          earnedDate: anyNamed('earnedDate'),
        )).thenReturn(mockBadge);
        
        when(mockAchievementsService.fetchUserBadges()).thenAnswer((_) async => [mockBadge]);
        when(mockAchievementsService.earnBadge(any)).thenAnswer((_) async {});
        when(mockAchievementsService.addXP(any)).thenAnswer((_) async {});
        when(mockAchievementsService.checkBadgeProgress()).thenAnswer((_) async {});
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => MockUserLevel());

        await achievementsProvider.loadAchievementsData();

        var notificationCount = 0;
        achievementsProvider.addListener(() => notificationCount++);

        await achievementsProvider.earnBadge('test-badge');

        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on add XP', () async {
        when(mockAchievementsService.addXP(any)).thenAnswer((_) async {});
        when(mockAchievementsService.checkBadgeProgress()).thenAnswer((_) async {});
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => MockUserLevel());

        var notificationCount = 0;
        achievementsProvider.addListener(() => notificationCount++);

        await achievementsProvider.addXP(25);

        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on refresh leaderboard', () async {
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => []);

        var notificationCount = 0;
        achievementsProvider.addListener(() => notificationCount++);

        await achievementsProvider.refreshLeaderboard();

        expect(notificationCount, greaterThan(0));
      });
    });

    group('Error Handling', () {
      test('should handle multiple consecutive errors', () async {
        when(mockAchievementsService.fetchUserLevel()).thenThrow(Exception('Error 1'));

        await achievementsProvider.loadAchievementsData();
        expect(achievementsProvider.error, isNotNull);

        when(mockAchievementsService.addXP(any)).thenThrow(Exception('Error 2'));

        await achievementsProvider.addXP(25);
        expect(achievementsProvider.error, isNotNull);
      });

      test('should handle partial success scenarios', () async {
        when(mockAchievementsService.fetchUserLevel()).thenAnswer((_) async => MockUserLevel());
        when(mockAchievementsService.fetchUserBadges()).thenThrow(Exception('Badge error'));
        when(mockAchievementsService.fetchLeaderboard()).thenAnswer((_) async => []);

        await achievementsProvider.loadAchievementsData();

        expect(achievementsProvider.userLevel, isNotNull);
        expect(achievementsProvider.leaderboard, isEmpty);
        expect(achievementsProvider.error, isNotNull);
      });
    });
  });
}
