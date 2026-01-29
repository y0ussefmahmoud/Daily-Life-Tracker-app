import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:daily_life_tracker/providers/auth_provider.dart';
import 'package:daily_life_tracker/screens/auth/signup_screen.dart';
import 'package:daily_life_tracker/screens/splash_screen.dart';

import 'signup_screen_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  group('SignupScreen Widget Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
    });

    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider<AuthProvider>(
        create: (_) => mockAuthProvider,
        child: MaterialApp(
          home: SignupScreen(),
        ),
      );
    }

    testWidgets('should display all UI elements correctly', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('إنشاء حساب جديد'), findsOneWidget);
      expect(find.text('الاسم'), findsOneWidget);
      expect(find.text('البريد الإلكتروني'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.text('تأكيد كلمة المرور'), findsOneWidget);
      expect(find.text('إنشاء حساب'), findsOneWidget);
      expect(find.text('لديك حساب بالفعل؟ تسجيل الدخول'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsWidgets);
    });

    testWidgets('should validate empty name field', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), '');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pump();

      expect(find.text('الرجاء إدخال الاسم'), findsOneWidget);
    });

    testWidgets('should validate empty email field', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), '');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pump();

      expect(find.text('الرجاء إدخال البريد الإلكتروني'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pump();

      expect(find.text('الرجاء إدخال بريد إلكتروني صحيح'), findsOneWidget);
    });

    testWidgets('should validate empty password field', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), '');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pump();

      expect(find.text('الرجاء إدخال كلمة المرور'), findsOneWidget);
    });

    testWidgets('should validate short password', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), '123');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pump();

      expect(find.text('يجب أن تكون كلمة المرور 6 أحرف على الأقل'), findsOneWidget);
    });

    testWidgets('should validate password mismatch', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'different123');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pump();

      expect(find.text('كلمات المرور غير متطابقة'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final passwordVisibilityIcon = find.byIcon(Icons.visibility_off).first;
      expect(passwordVisibilityIcon, findsOneWidget);

      await tester.tap(passwordVisibilityIcon);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should toggle confirm password visibility', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final confirmVisibilityIcon = find.byIcon(Icons.visibility_off).last;
      expect(confirmVisibilityIcon, findsOneWidget);

      await tester.tap(confirmVisibilityIcon);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsNWidgets(2));
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should show loading state', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('إنشاء حساب'), findsNothing);
    });

    testWidgets('should handle successful signup', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.signUpWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pump();

      verify(mockAuthProvider.signUpWithEmail(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      )).called(1);
    });

    testWidgets('should handle failed signup', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.signUpWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'existing@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pump();

      verify(mockAuthProvider.signUpWithEmail(
        email: 'existing@example.com',
        password: 'password123',
        name: 'Test User',
      )).called(1);
    });

    testWidgets('should navigate back to login screen', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('لديك حساب بالفعل؟ تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(find.byType(SignupScreen), findsNothing);
    });

    testWidgets('should disable signup button when loading', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should enable signup button when not loading', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should trim whitespace from email and name', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.signUpWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), '  Test User  ');
      await tester.enterText(find.byKey(const Key('email_field')), '  test@example.com  ');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pump();

      verify(mockAuthProvider.signUpWithEmail(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      )).called(1);
    });

    testWidgets('should handle form validation correctly', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('إنشاء حساب'));
      await tester.pump();

      expect(find.text('الرجاء إدخال الاسم'), findsOneWidget);
      expect(find.text('الرجاء إدخال البريد الإلكتروني'), findsOneWidget);
      expect(find.text('الرجاء إدخال كلمة المرور'), findsOneWidget);
    });
  });

  group('SignupScreen Integration Tests', () {
    testWidgets('should handle complete signup flow', (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.signUpWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider,
          child: MaterialApp(
            home: SignupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'New User');
      await tester.enterText(find.byKey(const Key('email_field')), 'newuser@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pumpAndSettle();

      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('should handle signup failure with error display', (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.signUpWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => false);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider,
          child: MaterialApp(
            home: SignupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'Existing User');
      await tester.enterText(find.byKey(const Key('email_field')), 'existing@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pumpAndSettle();

      expect(find.byType(SignupScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('should handle password strength validation', (WidgetTester tester) async {
      final mockAuthProvider = MockAuthProvider();
      when(mockAuthProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider,
          child: MaterialApp(
            home: SignupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), '123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), '123');
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pump();

      expect(find.text('يجب أن تكون كلمة المرور 6 أحرف على الأقل'), findsOneWidget);
      verifyNever(mockAuthProvider.signUpWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      ));
    });
  });
}
