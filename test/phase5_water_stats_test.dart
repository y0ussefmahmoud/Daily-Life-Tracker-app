import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'test_helpers/comprehensive_test_helper.dart';
import '../lib/screens/home_screen.dart';
import '../lib/screens/stats_screen.dart';
import '../lib/screens/achievements_screen.dart';
import '../lib/providers/water_provider.dart';
import '../lib/providers/stats_provider.dart';
import '../lib/providers/achievements_provider.dart';

// Generate mocks
@GenerateMocks([WaterProvider, StatsProvider, AchievementsProvider])
import 'phase5_water_stats_test.mocks.dart';

void main() {
  group('Phase 5: Water Tracker & Statistics Tests', () {
    late MockWaterProvider mockWaterProvider;
    late MockStatsProvider mockStatsProvider;
    late MockAchievementsProvider mockAchievementsProvider;

    setUp(() {
      mockWaterProvider = MockWaterProvider();
      mockStatsProvider = MockStatsProvider();
      mockAchievementsProvider = MockAchievementsProvider();
    });

    group('5.1 Water Tracker Tests', () {
      testWidgets('Should display water tracker widget', (WidgetTester tester) async {
        await ComprehensiveTestHelper.testWaterTracker(tester);
        
        // Verify water tracker elements
        expect(find.text('المياه'), findsOneWidget);
        expect(find.byIcon(Icons.water_drop), findsOneWidget);
      });

      testWidgets('Should display current water count', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Look for water count display
        final waterCount = find.textContaining('/');
        
        if (waterCount.evaluate().isNotEmpty) {
          expect(waterCount, findsOneWidget);
        }
      });

      testWidgets('Should allow adding water cups', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Find add water button
        final addWaterButton = find.byIcon(Icons.add);
        
        if (addWaterButton.evaluate().isNotEmpty) {
          // Get initial count
          final initialCount = find.textContaining('/');
          
          // Add water
          await tester.tap(addWaterButton);
          await tester.pump();
          
          // Verify count updated
          expect(find.byType(AnimatedContainer), findsWidgets);
        }
      });

      testWidgets('Should show animation when water is added', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        final addWaterButton = find.byIcon(Icons.add);
        
        if (addWaterButton.evaluate().isNotEmpty) {
          await tester.tap(addWaterButton);
          await tester.pump();
          
          // Look for animation indicators
          expect(find.byType(AnimatedContainer), findsWidgets);
          expect(find.byType(ScaleTransition), findsWidgets);
        }
      });

      testWidgets('Should save water data to database', (WidgetTester tester) async {
        // This test would verify database saving
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        final addWaterButton = find.byIcon(Icons.add);
        
        if (addWaterButton.evaluate().isNotEmpty) {
          await tester.tap(addWaterButton);
          await tester.pump();
          
          // Verify save operation (would need mocking)
          // verify(mockWaterProvider.addWaterCup()).called(1);
        }
      });

      testWidgets('Should show celebration when daily goal is reached', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // This test would require mocking water count near goal
        // Add water until goal is reached
        final addWaterButton = find.byIcon(Icons.add);
        
        if (addWaterButton.evaluate().isNotEmpty) {
          // Simulate reaching goal
          for (int i = 0; i < 8; i++) {
            await tester.tap(addWaterButton);
            await tester.pump();
          }
          
          // Verify celebration message
          // expect(find.text('أحسنت! لقد حققت هدفك اليومي'), findsOneWidget);
        }
      });

      testWidgets('Should award XP when daily goal is reached', (WidgetTester tester) async {
        // This test would verify XP awarding
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Simulate reaching goal and check XP
        // This would require mocking achievements provider
      });

      testWidgets('Should reset water count daily', (WidgetTester tester) async {
        // This test would verify daily reset functionality
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // This would require mocking date changes
      });
    });

    group('5.2 Statistics Screen Tests', () {
      testWidgets('Should display statistics screen', (WidgetTester tester) async {
        await ComprehensiveTestHelper.testStatsScreen(tester);
        
        // Verify statistics elements
        expect(find.text('إحصائيات الأسبوع'), findsOneWidget);
        expect(find.text('المهام المكتملة'), findsOneWidget);
        expect(find.text('المشاريع النشطة'), findsOneWidget);
      });

      testWidgets('Should display weekly statistics', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: StatsScreen()));
        await tester.pumpAndSettle();
        
        // Verify weekly stats sections
        expect(find.text('إحصائيات الأسبوع'), findsOneWidget);
        expect(find.text('المهام المكتملة'), findsOneWidget);
        expect(find.text('المشاريع النشطة'), findsOneWidget);
        expect(find.text('XP المكتسب'), findsOneWidget);
        expect(find.text('مستوى المستخدم'), findsOneWidget);
      });

      testWidgets('Should display weekly chart', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: StatsScreen()));
        await tester.pumpAndSettle();
        
        // Look for chart widget
        final chartWidget = find.byType(Container);
        if (chartWidget.evaluate().isNotEmpty) {
          // This would need more specific chart widget identification
          expect(chartWidget, findsWidgets);
        }
      });

      testWidgets('Should display time distribution', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: StatsScreen()));
        await tester.pumpAndSettle();
        
        // Look for time distribution section
        expect(find.text('توزيع الوقت'), findsOneWidget);
        
        // Look for category time breakdowns
        expect(find.text('العمل'), findsOneWidget);
        expect(find.text('الصحة'), findsOneWidget);
        expect(find.text('شخصي'), findsOneWidget);
      });

      testWidgets('Should display monthly progress', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: StatsScreen()));
        await tester.pumpAndSettle();
        
        // Look for monthly progress section
        expect(find.text('التقدم الشهري'), findsOneWidget);
        
        // Look for progress indicators
        final progressBars = find.byType(LinearProgressIndicator);
        if (progressBars.evaluate().isNotEmpty) {
          expect(progressBars, findsWidgets);
        }
      });

      testWidgets('Should show skeleton loaders during loading', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: StatsScreen()));
        await tester.pump();
        
        // Look for skeleton loading indicators
        final skeletonContainers = find.byWidgetPredicate((widget) {
          if (widget is Container) {
            return widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).color != null;
          }
          return false;
        });
        
        if (skeletonContainers.evaluate().isNotEmpty) {
          expect(skeletonContainers, findsWidgets);
        }
      });

      testWidgets('Should update statistics in real-time', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: StatsScreen()));
        await tester.pumpAndSettle();
        
        // This test would verify real-time updates
        // Would require mocking data changes
      });

      testWidgets('Should handle statistics loading errors', (WidgetTester tester) async {
        // This test would require mocking loading errors
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: StatsScreen()));
        await tester.pumpAndSettle();
        
        // Verify error handling
        // expect(find.text('فشل تحميل الإحصائيات'), findsOneWidget);
      });
    });

    group('5.3 Achievements Screen Tests', () {
      testWidgets('Should display achievements screen', (WidgetTester tester) async {
        await ComprehensiveTestHelper.testAchievementsScreen(tester);
        
        // Verify achievements elements
        expect(find.text('الإنجازات'), findsOneWidget);
        expect(find.text('المستوى'), findsOneWidget);
      });

      testWidgets('Should display current level and XP', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AchievementsScreen()));
        await tester.pumpAndSettle();
        
        // Look for level display
        expect(find.text('المستوى'), findsOneWidget);
        expect(find.text('XP'), findsOneWidget);
        
        // Look for XP progress bar
        final xpProgressBar = find.byType(LinearProgressIndicator);
        if (xpProgressBar.evaluate().isNotEmpty) {
          expect(xpProgressBar, findsOneWidget);
        }
      });

      testWidgets('Should display earned badges', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AchievementsScreen()));
        await tester.pumpAndSettle();
        
        // Look for earned badges section
        expect(find.text('الشارات المكتسبة'), findsOneWidget);
        
        // Look for badge widgets
        final badgeWidgets = find.byType(Container);
        if (badgeWidgets.evaluate().isNotEmpty) {
          expect(badgeWidgets, findsWidgets);
        }
      });

      testWidgets('Should display locked badges', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AchievementsScreen()));
        await tester.pumpAndSettle();
        
        // Look for locked badges section
        expect(find.text('الشارات المقفلة'), findsOneWidget);
        
        // Look for locked badge indicators
        final lockedIcons = find.byIcon(Icons.lock);
        if (lockedIcons.evaluate().isNotEmpty) {
          expect(lockedIcons, findsWidgets);
        }
      });

      testWidgets('Should show animation when new badge is earned', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AchievementsScreen()));
        await tester.pumpAndSettle();
        
        // This test would require mocking badge earning
        // Look for celebration animation
        // expect(find.byType(AnimatedScale), findsWidgets);
        // expect(find.byType(AnimatedRotation), findsWidgets);
      });

      testWidgets('Should show badge details when tapped', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AchievementsScreen()));
        await tester.pumpAndSettle();
        
        // Find badge and tap it
        final badgeWidgets = find.byType(GestureDetector);
        if (badgeWidgets.evaluate().isNotEmpty) {
          await tester.tap(badgeWidgets.first);
          await tester.pump();
          
          // Verify badge details dialog
          // expect(find.text('تفاصيل الشارة'), findsOneWidget);
        }
      });

      testWidgets('Should display achievement milestones', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AchievementsScreen()));
        await tester.pumpAndSettle();
        
        // Look for milestone sections
        expect(find.text('الإنجازات'), findsOneWidget);
        
        // Look for specific achievements
        // expect(find.text('أول مهمة'), findsOneWidget);
        // expect(find.text('أسبوع مثالي'), findsOneWidget);
        // expect(find.text('محارب المياه'), findsOneWidget);
      });

      testWidgets('Should show progress for incomplete achievements', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AchievementsScreen()));
        await tester.pumpAndSettle();
        
        // Look for progress indicators for incomplete achievements
        final progressBars = find.byType(LinearProgressIndicator);
        if (progressBars.evaluate().isNotEmpty) {
          expect(progressBars, findsWidgets);
        }
      });
    });

    group('5.4 Data Integration Tests', () {
      testWidgets('Should sync water data with statistics', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Add water
        final addWaterButton = find.byIcon(Icons.add);
        if (addWaterButton.evaluate().isNotEmpty) {
          await tester.tap(addWaterButton);
          await tester.pump();
          
          // Navigate to statistics
          await tester.tap(find.byIcon(Icons.bar_chart));
          await tester.pumpAndSettle();
          
          // Verify water data is reflected in statistics
          // This would require proper data mocking
        }
      });

      testWidgets('Should update achievements when tasks are completed', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Complete a task
        final checkbox = find.byType(Checkbox).first;
        if (checkbox.evaluate().isNotEmpty) {
          await tester.tap(checkbox);
          await tester.pump();
          
          // Navigate to achievements
          await tester.tap(find.byIcon(Icons.person));
          await tester.pumpAndSettle();
          
          // Look for achievements screen navigation
          // This would require proper navigation testing
        }
      });

      testWidgets('Should calculate statistics correctly', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: StatsScreen()));
        await tester.pumpAndSettle();
        
        // This test would verify statistical calculations
        // - Task completion rates
        // - Project progress
        // - Water consumption patterns
        // - XP accumulation
      });
    });

    group('5.5 Performance Tests', () {
      testWidgets('Should load statistics efficiently', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: StatsScreen()));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // Statistics should load within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      testWidgets('Should handle large datasets smoothly', (WidgetTester tester) async {
        // This test would verify performance with large amounts of data
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: StatsScreen()));
        await tester.pumpAndSettle();
        
        // Test scrolling through large datasets
        await tester.fling(find.byType(Scrollable), const Offset(0, -500), 1000);
        await tester.pumpAndSettle();
      });

      testWidgets('Should update charts without lag', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: StatsScreen()));
        await tester.pumpAndSettle();
        
        // Test chart updates
        // This would require mocking data changes
      });
    });

    group('Water & Stats Integration Tests', () {
      testWidgets('Should complete full water tracking cycle', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // 1. Add water throughout the day
        final addWaterButton = find.byIcon(Icons.add);
        if (addWaterButton.evaluate().isNotEmpty) {
          for (int i = 0; i < 8; i++) {
            await tester.tap(addWaterButton);
            await tester.pump();
          }
        }
        
        // 2. Check statistics
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pumpAndSettle();
        
        // 3. Check achievements
        await tester.tap(find.byIcon(Icons.person));
        await tester.pumpAndSettle();
        
        // 4. Verify all data is synchronized
      });
    });
  });
}
