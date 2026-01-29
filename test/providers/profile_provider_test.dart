import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daily_life_tracker/providers/profile_provider.dart';
import 'package:daily_life_tracker/providers/achievements_provider.dart';
import 'package:daily_life_tracker/services/auth_service.dart';
import 'package:daily_life_tracker/services/supabase_service.dart';
import 'package:daily_life_tracker/models/user_profile_model.dart';

import 'profile_provider_test.mocks.dart';

@GenerateMocks([
  AuthService,
  SupabaseClient,
  SupabaseService,
  User,
  AchievementsProvider,
  UserLevel,
  BadgeModel,
  PostgrestResponse,
  PostgrestTransformBuilder,
])
void main() {
  group('ProfileProvider Unit Tests', () {
    late ProfileProvider profileProvider;
    late MockAuthService mockAuthService;
    late MockSupabaseClient mockSupabaseClient;
    late MockAchievementsProvider mockAchievementsProvider;
    late MockUser mockUser;

    setUp(() {
      mockAuthService = MockAuthService();
      mockSupabaseClient = MockSupabaseClient();
      mockAchievementsProvider = MockAchievementsProvider();
      mockUser = MockUser();
      
      profileProvider = ProfileProvider(
        authService: mockAuthService,
        supabaseClient: mockSupabaseClient,
      );
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(profileProvider.profile, isNull);
        expect(profileProvider.isLoading, isFalse);
        expect(profileProvider.error, isNull);
      });
    });

    group('Load Profile', () {
      test('should load profile successfully', () async {
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user123');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUser.userMetadata).thenReturn({
          'name': 'Test User',
          'avatar_url': 'https://example.com/avatar.jpg',
        });
        
        final mockUserLevel = MockUserLevel();
        when(mockUserLevel.totalXP).thenReturn(100);
        when(mockAchievementsProvider.userLevel).thenReturn(mockUserLevel);
        when(mockAchievementsProvider.earnedBadges).thenReturn([]);
        
        when(mockSupabaseClient.from(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq(any, any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order(any, ascending: any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(30)).thenReturn(MockPostgrestTransformBuilder());

        await profileProvider.loadProfile(mockAchievementsProvider);

        expect(profileProvider.isLoading, isFalse);
        expect(profileProvider.error, isNull);
        expect(profileProvider.profile, isNotNull);
        expect(profileProvider.profile!.id, equals('user123'));
        expect(profileProvider.profile!.name, equals('Test User'));
        expect(profileProvider.profile!.subtitle, equals('test@example.com'));
        expect(profileProvider.profile!.avatarUrl, equals('https://example.com/avatar.jpg'));
        expect(profileProvider.profile!.badgeCount, equals(0));
        expect(profileProvider.profile!.points, equals(100));
      });

      test('should handle unauthenticated user', () async {
        when(mockAuthService.currentUser).thenReturn(null);

        await profileProvider.loadProfile(mockAchievementsProvider);

        expect(profileProvider.isLoading, isFalse);
        expect(profileProvider.error, equals('User not authenticated'));
        expect(profileProvider.profile, isNull);
      });

      test('should handle missing user metadata', () async {
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user123');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUser.userMetadata).thenReturn(null);
        
        final mockUserLevel = MockUserLevel();
        when(mockUserLevel.totalXP).thenReturn(0);
        when(mockAchievementsProvider.userLevel).thenReturn(mockUserLevel);
        when(mockAchievementsProvider.earnedBadges).thenReturn([]);

        when(mockSupabaseClient.from(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq(any, any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order(any, ascending: any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(30)).thenReturn(MockPostgrestTransformBuilder());

        await profileProvider.loadProfile(mockAchievementsProvider);

        expect(profileProvider.profile, isNotNull);
        expect(profileProvider.profile!.name, equals('مستخدم'));
        expect(profileProvider.profile!.subtitle, equals('test@example.com'));
        expect(profileProvider.profile!.avatarUrl, isNull);
      });

      test('should set loading state during load', () async {
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user123');
        
        final completer = Completer<void>();
        when(mockAchievementsProvider.userLevel).thenReturn(null);
        when(mockAchievementsProvider.earnedBadges).thenReturn([]);
        
        when(mockSupabaseClient.from(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq(any, any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order(any, ascending: any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(30)).thenAnswer((_) async {
          await completer.future;
          return MockPostgrestTransformBuilder();
        });

        final future = profileProvider.loadProfile(mockAchievementsProvider);

        expect(profileProvider.isLoading, isTrue);
        
        completer.complete();
        await future;
        
        expect(profileProvider.isLoading, isFalse);
      });

      test('should handle load profile error', () async {
        when(mockAuthService.currentUser).thenThrow(Exception('Auth error'));

        await profileProvider.loadProfile(mockAchievementsProvider);

        expect(profileProvider.isLoading, isFalse);
        expect(profileProvider.error, isNotNull);
        expect(profileProvider.profile, isNull);
      });
    });

    group('Update Profile', () {
      setUp(() {
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user123');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUser.userMetadata).thenReturn({'name': 'Test User'});
        
        final mockUserLevel = MockUserLevel();
        when(mockUserLevel.totalXP).thenReturn(0);
        when(mockAchievementsProvider.userLevel).thenReturn(mockUserLevel);
        when(mockAchievementsProvider.earnedBadges).thenReturn([]);
        
        when(mockSupabaseClient.from(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq(any, any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order(any, ascending: any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(30)).thenReturn(MockPostgrestTransformBuilder());
      });

      test('should update profile name successfully', () async {
        when(mockAuthService.updateProfile(
          userId: anyNamed('userId'),
          updates: anyNamed('updates'),
        )).thenAnswer((_) async {});

        await profileProvider.loadProfile(mockAchievementsProvider);
        
        await profileProvider.updateProfile(name: 'Updated Name');

        expect(profileProvider.profile!.name, equals('Updated Name'));
        verify(mockAuthService.updateProfile(
          userId: 'user123',
          updates: {'name': 'Updated Name'},
        )).called(1);
      });

      test('should update profile avatar successfully', () async {
        when(mockAuthService.updateProfile(
          userId: anyNamed('userId'),
          updates: anyNamed('updates'),
        )).thenAnswer((_) async {});

        await profileProvider.loadProfile(mockAchievementsProvider);
        
        await profileProvider.updateProfile(avatarUrl: 'https://new-avatar.jpg');

        expect(profileProvider.profile!.avatarUrl, equals('https://new-avatar.jpg'));
        verify(mockAuthService.updateProfile(
          userId: 'user123',
          updates: {'avatar_url': 'https://new-avatar.jpg'},
        )).called(1);
      });

      test('should update profile subtitle successfully', () async {
        when(mockAuthService.updateProfile(
          userId: anyNamed('userId'),
          updates: anyNamed('updates'),
        )).thenAnswer((_) async {});

        await profileProvider.loadProfile(mockAchievementsProvider);
        
        await profileProvider.updateProfile(subtitle: 'new@example.com');

        expect(profileProvider.profile!.subtitle, equals('new@example.com'));
        verify(mockAuthService.updateProfile(
          userId: 'user123',
          updates: {},
        )).called(1);
      });

      test('should handle update profile error', () async {
        when(mockAuthService.updateProfile(
          userId: anyNamed('userId'),
          updates: anyNamed('updates'),
        )).thenThrow(Exception('Update failed'));

        await profileProvider.loadProfile(mockAchievementsProvider);
        final originalName = profileProvider.profile!.name;
        
        await profileProvider.updateProfile(name: 'Updated Name');

        expect(profileProvider.profile!.name, equals(originalName));
        expect(profileProvider.error, isNotNull);
      });

      test('should not update profile when profile is null', () async {
        await profileProvider.updateProfile(name: 'Updated Name');

        verifyNever(mockAuthService.updateProfile(
          userId: anyNamed('userId'),
          updates: anyNamed('updates'),
        ));
      });
    });

    group('Calculate Streak Days', () {
      test('should calculate streak days correctly', () async {
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user123');
        
        final today = DateTime.now();
        final yesterday = today.subtract(Duration(days: 1));
        final dayBefore = today.subtract(Duration(days: 2));
        
        final mockData = [
          {'date': today.toIso8601String(), 'completed_tasks_count': 5},
          {'date': yesterday.toIso8601String(), 'completed_tasks_count': 3},
          {'date': dayBefore.toIso8601String(), 'completed_tasks_count': 4},
        ];
        
        when(mockSupabaseClient.from('daily_stats')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(30)).thenAnswer((_) async => mockData);

        final streakDays = await profileProvider.calculateStreakDays();

        expect(streakDays, equals(3));
      });

      test('should handle broken streak', () async {
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user123');
        
        final today = DateTime.now();
        final twoDaysAgo = today.subtract(Duration(days: 2));
        
        final mockData = [
          {'date': today.toIso8601String(), 'completed_tasks_count': 5},
          {'date': twoDaysAgo.toIso8601String(), 'completed_tasks_count': 3},
        ];
        
        when(mockSupabaseClient.from('daily_stats')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(30)).thenAnswer((_) async => mockData);

        final streakDays = await profileProvider.calculateStreakDays();

        expect(streakDays, equals(1));
      });

      test('should handle zero completed tasks', () async {
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user123');
        
        final today = DateTime.now();
        final yesterday = today.subtract(Duration(days: 1));
        
        final mockData = [
          {'date': today.toIso8601String(), 'completed_tasks_count': 0},
          {'date': yesterday.toIso8601String(), 'completed_tasks_count': 3},
        ];
        
        when(mockSupabaseClient.from('daily_stats')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(30)).thenAnswer((_) async => mockData);

        final streakDays = await profileProvider.calculateStreakDays();

        expect(streakDays, equals(0));
      });

      test('should handle empty data', () async {
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user123');
        
        when(mockSupabaseClient.from('daily_stats')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(30)).thenAnswer((_) async => []);

        final streakDays = await profileProvider.calculateStreakDays();

        expect(streakDays, equals(0));
      });

      test('should handle unauthenticated user for streak calculation', () async {
        when(mockAuthService.currentUser).thenReturn(null);

        final streakDays = await profileProvider.calculateStreakDays();

        expect(streakDays, equals(0));
      });

      test('should handle database error in streak calculation', () async {
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user123');
        
        when(mockSupabaseClient.from('daily_stats')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(30)).thenThrow(PostgrestException('Database error'));

        final streakDays = await profileProvider.calculateStreakDays();

        expect(streakDays, equals(0));
      });
    });

    group('Date Helper Methods', () {
      test('should identify same day correctly', () {
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2024, 1, 15, 15, 45);
        
        expect(profileProvider._isSameDay(date1, date2), isTrue);
      });

      test('should identify different days correctly', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        
        expect(profileProvider._isSameDay(date1, date2), isFalse);
      });

      test('should identify previous day correctly', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);
        
        expect(profileProvider._isPreviousDay(date1, date2), isTrue);
      });

      test('should identify non-previous day correctly', () {
        final date1 = DateTime(2024, 1, 13);
        final date2 = DateTime(2024, 1, 16);
        
        expect(profileProvider._isPreviousDay(date1, date2), isFalse);
      });
    });

    group('Integration with Achievements Provider', () {
      test('should integrate with achievements provider correctly', () async {
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user123');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUser.userMetadata).thenReturn({'name': 'Test User'});
        
        final mockUserLevel = MockUserLevel();
        when(mockUserLevel.totalXP).thenReturn(250);
        when(mockAchievementsProvider.userLevel).thenReturn(mockUserLevel);
        
        final mockBadge = MockBadgeModel();
        when(mockAchievementsProvider.earnedBadges).thenReturn([mockBadge, mockBadge]);
        
        when(mockSupabaseClient.from(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq(any, any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123')).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order(any, ascending: any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(any)).thenReturn(MockPostgrestTransformBuilder());
        when(mockSupabaseClient.from('daily_stats').select('date, completed_tasks_count').eq('user_id', 'user123').order('date', ascending: false).limit(30)).thenReturn(MockPostgrestTransformBuilder());

        await profileProvider.loadProfile(mockAchievementsProvider);

        expect(profileProvider.profile!.badgeCount, equals(2));
        expect(profileProvider.profile!.points, equals(250));
      });
    });
  });
}
