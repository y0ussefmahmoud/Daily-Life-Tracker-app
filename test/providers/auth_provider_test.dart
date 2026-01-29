import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:daily_life_tracker/providers/auth_provider.dart';
import 'package:daily_life_tracker/services/auth_service.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([AuthService, User, AuthStateChange])
void main() {
  group('AuthProvider Unit Tests', () {
    late AuthProvider authProvider;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      authProvider = AuthProvider(
        authService: mockAuthService,
      );
    });

    group('Initialization', () {
      test('should initialize correctly with authenticated user', () async {
        final mockUser = MockUser();
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockAuthService.getUserProfile()).thenAnswer((_) async => {
          'id': 'user123',
          'name': 'Test User',
          'email': 'test@example.com',
        });
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));

        await authProvider.initialize();

        expect(authProvider.isInitialized, isTrue);
        expect(authProvider.user, equals(mockUser));
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNull);
      });

      test('should initialize correctly with no user', () async {
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));

        await authProvider.initialize();

        expect(authProvider.isInitialized, isTrue);
        expect(authProvider.user, isNull);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNull);
      });

      test('should handle initialization error', () async {
        when(mockAuthService.currentUser).thenThrow(Exception('Initialization failed'));
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));

        expect(() async => await authProvider.initialize(), throwsException);
        expect(authProvider.error, isNotNull);
      });

      test('should not initialize multiple times', () async {
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));

        await authProvider.initialize();
        await authProvider.initialize();

        verify(mockAuthService.onAuthStateChange).called(1);
      });
    });

    group('Sign In with Email', () {
      setUp(() {
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));
      });

      test('should sign in successfully', () async {
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async {});

        final result = await authProvider.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, isTrue);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNull);
        verify(mockAuthService.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('should handle sign in failure', () async {
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(AuthException('Invalid credentials'));

        final result = await authProvider.signInWithEmail(
          email: 'test@example.com',
          password: 'wrongpassword',
        );

        expect(result, isFalse);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNotNull);
      });

      test('should handle general exception during sign in', () async {
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception('Network error'));

        final result = await authProvider.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, isFalse);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNotNull);
      });

      test('should set loading state during sign in', () async {
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });

        final future = authProvider.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(authProvider.isLoading, isTrue);
        await future;
        expect(authProvider.isLoading, isFalse);
      });
    });

    group('Sign Up with Email', () {
      setUp(() {
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));
      });

      test('should sign up successfully', () async {
        when(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
        )).thenAnswer((_) async {});

        final result = await authProvider.signUpWithEmail(
          email: 'newuser@example.com',
          password: 'password123',
          name: 'New User',
        );

        expect(result, isTrue);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNull);
        verify(mockAuthService.signUpWithEmail(
          email: 'newuser@example.com',
          password: 'password123',
          name: 'New User',
        )).called(1);
      });

      test('should handle sign up failure', () async {
        when(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
        )).thenThrow(AuthException('Email already exists'));

        final result = await authProvider.signUpWithEmail(
          email: 'existing@example.com',
          password: 'password123',
          name: 'Existing User',
        );

        expect(result, isFalse);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNotNull);
      });

      test('should handle sign up without name', () async {
        when(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
        )).thenAnswer((_) async {});

        final result = await authProvider.signUpWithEmail(
          email: 'noname@example.com',
          password: 'password123',
        );

        expect(result, isTrue);
        verify(mockAuthService.signUpWithEmail(
          email: 'noname@example.com',
          password: 'password123',
          name: isNull,
        )).called(1);
      });
    });

    group('Sign Out', () {
      setUp(() {
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));
      });

      test('should sign out successfully', () async {
        final mockUser = MockUser();
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockAuthService.signOut()).thenAnswer((_) async {});

        await authProvider.initialize();
        await authProvider.signOut();

        expect(authProvider.user, isNull);
        expect(authProvider.userProfile, isNull);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isLoading, isFalse);
        verify(mockAuthService.signOut()).called(1);
      });

      test('should handle sign out error', () async {
        when(mockAuthService.signOut()).thenThrow(Exception('Sign out failed'));

        await authProvider.signOut();

        expect(authProvider.error, isNotNull);
        expect(authProvider.isLoading, isFalse);
      });
    });

    group('Update Profile', () {
      setUp(() {
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));
      });

      test('should update profile successfully', () async {
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('user123');
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockAuthService.updateProfile(
          userId: anyNamed('userId'),
          updates: anyNamed('updates'),
        )).thenAnswer((_) async {});
        when(mockAuthService.getUserProfile()).thenAnswer((_) async => {
          'id': 'user123',
          'name': 'Updated Name',
          'email': 'test@example.com',
        });

        await authProvider.initialize();
        final result = await authProvider.updateProfile({
          'name': 'Updated Name',
        });

        expect(result, isTrue);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNull);
        expect(authProvider.userProfile?['name'], equals('Updated Name'));
        verify(mockAuthService.updateProfile(
          userId: 'user123',
          updates: {'name': 'Updated Name'},
        )).called(1);
      });

      test('should handle update profile failure', () async {
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('user123');
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockAuthService.updateProfile(
          userId: anyNamed('userId'),
          updates: anyNamed('updates'),
        )).thenThrow(Exception('Update failed'));

        await authProvider.initialize();
        final result = await authProvider.updateProfile({
          'name': 'Updated Name',
        });

        expect(result, isFalse);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNotNull);
      });

      test('should return false when user is not authenticated', () async {
        when(mockAuthService.currentUser).thenReturn(null);

        final result = await authProvider.updateProfile({
          'name': 'Updated Name',
        });

        expect(result, isFalse);
        verifyNever(mockAuthService.updateProfile(
          userId: anyNamed('userId'),
          updates: anyNamed('updates'),
        ));
      });
    });

    group('Reset Password', () {
      setUp(() {
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));
      });

      test('should reset password successfully', () async {
        when(mockAuthService.resetPassword(any)).thenAnswer((_) async {});

        final result = await authProvider.resetPassword('test@example.com');

        expect(result, isTrue);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNull);
        verify(mockAuthService.resetPassword('test@example.com')).called(1);
      });

      test('should handle reset password failure', () async {
        when(mockAuthService.resetPassword(any))
            .thenThrow(Exception('Reset failed'));

        final result = await authProvider.resetPassword('test@example.com');

        expect(result, isFalse);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNotNull);
      });
    });

    group('Clear Error', () {
      test('should clear error message', () async {
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(AuthException('Test error'));

        await authProvider.signInWithEmail(
          email: 'test@example.com',
          password: 'wrongpassword',
        );

        expect(authProvider.error, isNotNull);

        authProvider.clearError();

        expect(authProvider.error, isNull);
      });
    });

    group('Auth State Changes', () {
      test('should handle user login event', () async {
        final mockUser = MockUser();
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.fromIterable([
            AuthStateChange(AuthChangeEvent.signedIn, mockUser),
          ]));
        when(mockAuthService.getUserProfile()).thenAnswer((_) async => {
          'id': 'user123',
          'name': 'Test User',
          'email': 'test@example.com',
        });

        await authProvider.initialize();
        await Future.delayed(Duration(milliseconds: 100));

        expect(authProvider.user, equals(mockUser));
        expect(authProvider.isAuthenticated, isTrue);
      });

      test('should handle user logout event', () async {
        final mockUser = MockUser();
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.fromIterable([
            AuthStateChange(AuthChangeEvent.signedOut, null),
          ]));

        await authProvider.initialize();
        await Future.delayed(Duration(milliseconds: 100));

        expect(authProvider.user, isNull);
        expect(authProvider.userProfile, isNull);
        expect(authProvider.isAuthenticated, isFalse);
      });

      test('should handle auth state change error', () async {
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.error(Exception('Auth state error')));

        await authProvider.initialize();
        await Future.delayed(Duration(milliseconds: 100));

        expect(authProvider.error, isNotNull);
      });
    });

    group('Load User Profile', () {
      test('should load user profile successfully', () async {
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('user123');
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));
        when(mockAuthService.getUserProfile()).thenAnswer((_) async => {
          'id': 'user123',
          'name': 'Test User',
          'email': 'test@example.com',
        });

        await authProvider.initialize();

        expect(authProvider.userProfile, isNotNull);
        expect(authProvider.userProfile!['name'], equals('Test User'));
        expect(authProvider.userProfile!['email'], equals('test@example.com'));
      });

      test('should handle user profile loading error', () async {
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('user123');
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockAuthService.onAuthStateChange).thenAnswer((_) => 
          Stream.value(MockAuthStateChange()));
        when(mockAuthService.getUserProfile()).thenThrow(Exception('Profile load failed'));

        await authProvider.initialize();

        expect(authProvider.error, isNotNull);
      });
    });

    group('Getters', () {
      test('should return correct initial state', () {
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNull);
        expect(authProvider.user, isNull);
        expect(authProvider.userProfile, isNull);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isInitialized, isFalse);
      });
    });
  });
}
