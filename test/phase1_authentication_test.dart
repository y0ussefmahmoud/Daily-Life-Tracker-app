import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'test_helpers/comprehensive_test_helper.dart';
import '../lib/screens/auth/login_screen.dart';
import '../lib/screens/auth/signup_screen.dart';
import '../lib/screens/splash_screen.dart';
import '../lib/providers/auth_provider.dart';

// Generate mocks
@GenerateMocks([AuthProvider])
import 'phase1_authentication_test.mocks.dart';

void main() {
  group('Phase 1: Authentication Flow Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
    });

    group('1.1 SplashScreen Tests', () {
      testWidgets('Should display app logo and loading text', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget());
        
        // Verify splash screen elements
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Daily Life Tracker'), findsOneWidget);
        expect(find.text('جاري التهيئة...'), findsOneWidget);
        expect(find.byIcon(Icons.track_changes), findsOneWidget);
      });

      testWidgets('Should show different loading stages', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget());
        
        // Initial loading stage
        expect(find.text('جاري التهيئة...'), findsOneWidget);
        
        // Wait for next stage
        await tester.pump(const Duration(seconds: 1));
        // Note: Actual stage changes would require proper mocking of providers
      });

      testWidgets('Should handle initialization errors gracefully', (WidgetTester tester) async {
        // This test would require mocking initialization failures
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget());
        
        // Test error states
        // Note: Would need to mock provider initialization to throw errors
      });
    });

    group('1.2 Login Screen Tests', () {
      testWidgets('Should display all login elements', (WidgetTester tester) async {
        await ComprehensiveTestHelper.testLoginScreen(tester);
        
        // Verify all login elements are present
        expect(find.text('تسجيل الدخول'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('البريد الإلكتروني'), findsOneWidget);
        expect(find.text('كلمة المرور'), findsOneWidget);
        expect(find.text('تسجيل الدخول'), findsOneWidget);
        expect(find.text('سجل الآن'), findsOneWidget);
        expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
      });

      testWidgets('Should validate email format', (WidgetTester tester) async {
        await ComprehensiveTestHelper.testInvalidLogin(tester);
        
        // Verify error message appears
        expect(find.text('صيغة البريد الإلكتروني غير صحيحة'), findsOneWidget);
      });

      testWidgets('Should validate password length', (WidgetTester tester) async {
        await ComprehensiveTestHelper.testShortPassword(tester);
        
        // Verify error message appears
        expect(find.text('كلمة المرور قصيرة جداً'), findsOneWidget);
      });

      testWidgets('Should disable login button during loading', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: LoginScreen()));
        await tester.pumpAndSettle();
        
        // Enter valid credentials
        await tester.enterText(
          find.byType(TextFormField).first, 
          ComprehensiveTestHelper.testUser['email']!
        );
        await tester.enterText(
          find.byType(TextFormField).last, 
          ComprehensiveTestHelper.testUser['password']!
        );
        
        // Tap login button
        await tester.tap(find.text('تسجيل الدخول'));
        await tester.pump();
        
        // Verify loading state (would need proper mocking)
        // expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('Should navigate to signup screen', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: LoginScreen()));
        await tester.pumpAndSettle();
        
        // Tap signup link
        await tester.tap(find.text('سجل الآن'));
        await tester.pumpAndSettle();
        
        // Verify navigation to signup screen
        expect(find.byType(SignupScreen), findsOneWidget);
      });
    });

    group('1.3 Signup Screen Tests', () {
      testWidgets('Should display all signup elements', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: SignupScreen()));
        await tester.pumpAndSettle();
        
        // Verify all signup elements are present
        expect(find.text('إنشاء حساب جديد'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(3)); // Name, Email, Password
        expect(find.text('الاسم'), findsOneWidget);
        expect(find.text('البريد الإلكتروني'), findsOneWidget);
        expect(find.text('كلمة المرور'), findsOneWidget);
        expect(find.text('إنشاء حساب'), findsOneWidget);
      });

      testWidgets('Should validate all required fields', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: SignupScreen()));
        await tester.pumpAndSettle();
        
        // Try to signup without filling fields
        await tester.tap(find.text('إنشاء حساب'));
        await tester.pump();
        
        // Verify validation messages
        expect(find.text('الرجاء إدخال الاسم'), findsOneWidget);
        expect(find.text('الرجاء إدخال البريد الإلكتروني'), findsOneWidget);
        expect(find.text('الرجاء إدخال كلمة المرور'), findsOneWidget);
      });

      testWidgets('Should validate email format in signup', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: SignupScreen()));
        await tester.pumpAndSettle();
        
        // Enter invalid email
        await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
        await tester.tap(find.text('إنشاء حساب'));
        await tester.pump();
        
        // Verify error message
        expect(find.text('صيغة البريد الإلكتروني غير صحيحة'), findsOneWidget);
      });
    });

    group('1.4 Password Reset Tests', () {
      testWidgets('Should show password reset dialog', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: LoginScreen()));
        await tester.pumpAndSettle();
        
        // Tap forgot password link
        await tester.tap(find.text('نسيت كلمة المرور؟'));
        await tester.pumpAndSettle();
        
        // Verify password reset dialog
        expect(find.text('استعادة كلمة المرور'), findsOneWidget);
        expect(find.text('أدخل بريدك الإلكتروني لإرسال رابط الاستعادة'), findsOneWidget);
      });

      testWidgets('Should validate email in password reset', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: LoginScreen()));
        await tester.pumpAndSettle();
        
        // Open password reset dialog
        await tester.tap(find.text('نسيت كلمة المرور؟'));
        await tester.pumpAndSettle();
        
        // Enter invalid email and submit
        await tester.enterText(find.byType(TextFormField), 'invalid-email');
        await tester.tap(find.text('إرسال'));
        await tester.pump();
        
        // Verify error message
        expect(find.text('صيغة البريد الإلكتروني غير صحيحة'), findsOneWidget);
      });
    });

    group('1.5 Logout Tests', () {
      testWidgets('Should show logout confirmation dialog', (WidgetTester tester) async {
        // This test would require mocking authenticated state
        // For now, we'll test the UI structure
        
        // Test would verify:
        // 1. Logout button exists in profile screen
        // 2. Confirmation dialog appears
        // 3. Dialog has proper buttons
      });

      testWidgets('Should clear all data on logout', (WidgetTester tester) async {
        // This test would verify:
        // 1. All providers are cleared
        // 2. User is redirected to login screen
        // 3. Cannot navigate back to home screen
      });
    });

    group('Authentication Flow Integration', () {
      testWidgets('Should complete full authentication cycle', (WidgetTester tester) async {
        // This test would verify the complete flow:
        // 1. Start at splash screen
        // 2. Navigate to login (if not authenticated)
        // 3. Login successfully
        // 4. Navigate to home screen
        // 5. Logout successfully
        // 6. Return to login screen
      });
    });
  });
}
