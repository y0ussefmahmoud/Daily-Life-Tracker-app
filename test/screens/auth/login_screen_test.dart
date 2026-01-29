import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:daily_life_tracker/providers/auth_provider.dart';
import 'package:daily_life_tracker/screens/auth/login_screen.dart';
import 'package:daily_life_tracker/screens/auth/signup_screen.dart';
import 'package:daily_life_tracker/screens/splash_screen.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
    });

    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider<AuthProvider>(
        create: (_) => mockAuthProvider,
        child: MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('should display all UI elements correctly', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.text('البريد الإلكتروني'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
      expect(find.text('ليس لديك حساب؟'), findsOneWidget);
      expect(find.text('سجل الآن'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should validate empty email field', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), '');
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pump();

      expect(find.text('الرجاء إدخال البريد الإلكتروني'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pump();

      expect(find.text('الرجاء إدخال بريد إلكتروني صحيح'), findsOneWidget);
    });

    testWidgets('should validate empty password field', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), '');
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pump();

      expect(find.text('الرجاء إدخال كلمة المرور'), findsOneWidget);
    });

    testWidgets('should validate short password', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), '123');
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pump();

      expect(find.text('يجب أن تكون كلمة المرور 6 أحرف على الأقل'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('should show loading state', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(true);
      when(mockAuthProvider.error).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('تسجيل الدخول'), findsNothing);
    });

    testWidgets('should display error message', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn('فشل تسجيل الدخول');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('فشل تسجيل الدخول'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should navigate to signup screen', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('سجل الآن'));
      await tester.pumpAndSettle();

      expect(find.byType(SignupScreen), findsOneWidget);
    });

    testWidgets('should handle successful login', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);
      when(mockAuthProvider.signInWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pump();

      verify(mockAuthProvider.signInWithEmail(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    testWidgets('should handle failed login', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);
      when(mockAuthProvider.signInWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pump();

      verify(mockAuthProvider.signInWithEmail(
        email: 'test@example.com',
        password: 'wrongpassword',
      )).called(1);
    });

    testWidgets('should handle password reset', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);
      when(mockAuthProvider.resetPassword(any)).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.tap(find.text('نسيت كلمة المرور؟'));
      await tester.pump();

      verify(mockAuthProvider.resetPassword('test@example.com')).called(1);
    });

    testWidgets('should show error when trying to reset password with empty email', 
        (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('نسيت كلمة المرور؟'));
      await tester.pump();

      expect(find.text('الرجاء إدخال البريد الإلكتروني أولاً'), findsOneWidget);
    });

    testWidgets('should disable login button when loading', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(true);
      when(mockAuthProvider.error).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should enable login button when not loading', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should submit form on password field submit', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);
      when(mockAuthProvider.signInWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      verify(mockAuthProvider.signInWithEmail(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });
  });

  group('LoginScreen Integration Tests', () {
    testWidgets('should handle complete login flow', (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);
      when(mockAuthProvider.signInWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider,
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('should handle login failure with error display', (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.error).thenReturn(null);
      when(mockAuthProvider.signInWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => false);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider,
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}
