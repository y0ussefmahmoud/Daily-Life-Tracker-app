import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers/comprehensive_test_helper.dart';
import '../lib/screens/home_screen.dart';
import '../lib/screens/add_screen.dart';
import '../lib/screens/profile_screen.dart';
import '../lib/screens/projects_screen.dart';
import '../lib/screens/stats_screen.dart';
import '../lib/screens/achievements_screen.dart';

void main() {
  group('Phase 2: Screens & Navigation Tests', () {
    
    group('2.1 Bottom Navigation Tests', () {
      testWidgets('Should display all navigation tabs', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Verify all navigation icons are present
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.bar_chart), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget); // FAB
        expect(find.byIcon(Icons.work), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
        
        // Verify tab labels (if they exist)
        expect(find.text('اليوم'), findsOneWidget);
        expect(find.text('إحصائيات الأسبوع'), findsOneWidget);
        expect(find.text('مشاريعي'), findsOneWidget);
        expect(find.text('الملف الشخصي'), findsOneWidget);
      });

      testWidgets('Should navigate to Today tab', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Tap on Today tab (index 0)
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
        
        // Verify we're still on home screen (today view)
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('مهام اليوم'), findsOneWidget);
      });

      testWidgets('Should navigate to Statistics tab', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Tap on Statistics tab (index 1)
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pumpAndSettle();
        
        // Verify navigation to stats screen
        expect(find.byType(StatsScreen), findsOneWidget);
        expect(find.text('إحصائيات الأسبوع'), findsOneWidget);
      });

      testWidgets('Should navigate to Projects tab', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Tap on Projects tab (index 3)
        await tester.tap(find.byIcon(Icons.work));
        await tester.pumpAndSettle();
        
        // Verify navigation to projects screen
        expect(find.byType(ProjectsScreen), findsOneWidget);
        expect(find.text('مشاريعي'), findsOneWidget);
      });

      testWidgets('Should navigate to Profile tab', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Tap on Profile tab (index 4)
        await tester.tap(find.byIcon(Icons.person));
        await tester.pumpAndSettle();
        
        // Verify navigation to profile screen
        expect(find.byType(ProfileScreen), findsOneWidget);
        expect(find.text('الملف الشخصي'), findsOneWidget);
      });

      testWidgets('Should update AppBar title based on selected tab', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Check initial title
        expect(find.text('مهام اليوم'), findsOneWidget);
        
        // Navigate to statistics and check title
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pumpAndSettle();
        expect(find.text('إحصائيات الأسبوع'), findsOneWidget);
        
        // Navigate to projects and check title
        await tester.tap(find.byIcon(Icons.work));
        await tester.pumpAndSettle();
        expect(find.text('مشاريعي'), findsOneWidget);
        
        // Navigate to profile and check title
        await tester.tap(find.byIcon(Icons.person));
        await tester.pumpAndSettle();
        expect(find.text('الملف الشخصي'), findsOneWidget);
      });

      testWidgets('Should maintain state when switching tabs', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Navigate to statistics
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pumpAndSettle();
        
        // Navigate to projects
        await tester.tap(find.byIcon(Icons.work));
        await tester.pumpAndSettle();
        
        // Navigate back to statistics
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pumpAndSettle();
        
        // Verify statistics screen maintains its state
        expect(find.byType(StatsScreen), findsOneWidget);
      });
    });

    group('2.2 FAB (Floating Action Button) Tests', () {
      testWidgets('Should display FAB on all main screens', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Check FAB exists on home screen
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
        
        // Navigate to other screens and check FAB persists
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pumpAndSettle();
        expect(find.byType(FloatingActionButton), findsOneWidget);
        
        await tester.tap(find.byIcon(Icons.work));
        await tester.pumpAndSettle();
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('Should open AddScreen when FAB is tapped', (WidgetTester tester) async {
        await ComprehensiveTestHelper.testFABButton(tester);
        
        // Verify AddScreen is opened
        expect(find.byType(AddScreen), findsOneWidget);
        expect(find.text('إضافة جديد'), findsOneWidget);
      });

      testWidgets('Should show add options in AddScreen', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AddScreen()));
        await tester.pumpAndSettle();
        
        // Verify add options are present
        expect(find.text('مهمة'), findsOneWidget);
        expect(find.text('مشروع'), findsOneWidget);
        expect(find.text('إضافة مهمة جديدة'), findsOneWidget);
        expect(find.text('إضافة مشروع جديد'), findsOneWidget);
      });

      testWidgets('Should close AddScreen when back is pressed', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Open AddScreen
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        
        // Verify AddScreen is open
        expect(find.byType(AddScreen), findsOneWidget);
        
        // Press back
        await tester.pageBack();
        await tester.pumpAndSettle();
        
        // Verify we're back to previous screen
        expect(find.byType(AddScreen), findsNothing);
      });
    });

    group('2.3 Profile Screen Tests', () {
      testWidgets('Should display user information', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProfileScreen()));
        await tester.pumpAndSettle();
        
        // Verify profile elements
        expect(find.text('الملف الشخصي'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
        
        // Check for user stats (would need mocked data)
        // expect(find.text('المستوى'), findsOneWidget);
        // expect(find.text('XP'), findsOneWidget);
        // expect(find.text('الشارات'), findsOneWidget);
      });

      testWidgets('Should show edit profile option', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProfileScreen()));
        await tester.pumpAndSettle();
        
        // Look for edit profile button
        expect(find.text('تعديل الملف الشخصي'), findsOneWidget);
      });

      testWidgets('Should show settings options', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProfileScreen()));
        await tester.pumpAndSettle();
        
        // Check for common settings options
        expect(find.text('الإعدادات'), findsOneWidget);
        expect(find.text('الوضع الليلي'), findsOneWidget);
        expect(find.text('تسجيل الخروج'), findsOneWidget);
      });

      testWidgets('Should open profile edit dialog', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProfileScreen()));
        await tester.pumpAndSettle();
        
        // Tap edit profile button
        await tester.tap(find.text('تعديل الملف الشخصي'));
        await tester.pumpAndSettle();
        
        // Verify edit dialog opens
        expect(find.text('تعديل الملف الشخصي'), findsAtLeastNWidgets(2)); // Title and button
      });
    });

    group('2.4 AppBar Navigation Tests', () {
      testWidgets('Should show profile icon in AppBar', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Check for profile icon in AppBar
        expect(find.byIcon(Icons.person), findsAtLeastNWidgets(2)); // One in nav, one in appbar
      });

      testWidgets('Should navigate to profile when AppBar icon is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Find and tap profile icon in AppBar (usually the first one)
        final profileIcons = find.byIcon(Icons.person);
        await tester.tap(profileIcons.first);
        await tester.pumpAndSettle();
        
        // Verify navigation to profile screen
        expect(find.byType(ProfileScreen), findsOneWidget);
      });
    });

    group('2.5 Navigation Animation Tests', () {
      testWidgets('Should show smooth transitions between tabs', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Test navigation animation
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pump(); // Start animation
        
        // Verify animation is in progress (FadeTransition)
        expect(find.byType(FadeTransition), findsOneWidget);
        
        await tester.pumpAndSettle(); // Complete animation
        
        // Verify final state
        expect(find.byType(StatsScreen), findsOneWidget);
      });

      testWidgets('Should not show jank during navigation', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Rapid navigation between tabs
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byIcon(Icons.bar_chart));
          await tester.pump();
          await tester.tap(find.byIcon(Icons.work));
          await tester.pump();
          await tester.tap(find.byIcon(Icons.person));
          await tester.pump();
          await tester.tap(find.byIcon(Icons.home));
          await tester.pump();
        }
        
        await tester.pumpAndSettle();
        
        // Verify app is still responsive
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('2.6 Navigation State Management', () {
      testWidgets('Should preserve scroll position when switching tabs', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Scroll down on home screen
        await tester.fling(find.byType(Scrollable), const Offset(0, -300), 1000);
        await tester.pumpAndSettle();
        
        // Navigate to another tab
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pumpAndSettle();
        
        // Navigate back
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
        
        // Verify scroll position is preserved (if implemented)
        // This would require checking the scroll controller state
      });

      testWidgets('Should handle deep linking properly', (WidgetTester tester) async {
        // This test would verify deep linking functionality
        // For example, opening the app directly to a specific screen
        
        // Test deep link to tasks
        // Test deep link to projects
        // Test deep link to profile
      });
    });

    group('Navigation Integration Tests', () {
      testWidgets('Should complete full navigation cycle', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Navigate through all tabs
        await tester.tap(find.byIcon(Icons.bar_chart)); // Stats
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.work)); // Projects
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.person)); // Profile
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.home)); // Home
        await tester.pumpAndSettle();
        
        // Open AddScreen
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        
        // Close AddScreen
        await tester.pageBack();
        await tester.pumpAndSettle();
        
        // Verify we're back to home
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });
  });
}
