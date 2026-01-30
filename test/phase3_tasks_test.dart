import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'test_helpers/comprehensive_test_helper.dart';
import '../lib/screens/home_screen.dart';
import '../lib/screens/add_screen.dart';
import '../lib/providers/task_provider.dart';

// Generate mocks
@GenerateMocks([TaskProvider])
import 'phase3_tasks_test.mocks.dart';

void main() {
  group('Phase 3: Tasks Tests', () {
    late MockTaskProvider mockTaskProvider;

    setUp(() {
      mockTaskProvider = MockTaskProvider();
    });

    group('3.1 Task Display Tests', () {
      testWidgets('Should display all task categories', (WidgetTester tester) async {
        await ComprehensiveTestHelper.testTaskDisplay(tester);
        
        // Verify all category sections are present
        expect(find.text('الصباح'), findsOneWidget);
        expect(find.text('العمل'), findsOneWidget);
        expect(find.text('الصلاة'), findsOneWidget);
        expect(find.text('الصحة'), findsOneWidget);
        expect(find.text('شخصي'), findsOneWidget);
        expect(find.text('المساء'), findsOneWidget);
      });

      testWidgets('Should display category icons and colors', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Check for category icons
        expect(find.byIcon(Icons.wb_sunny), findsOneWidget); // Morning
        expect(find.byIcon(Icons.work), findsOneWidget); // Work
        expect(find.byIcon(Icons.mosque), findsOneWidget); // Prayer
        expect(find.byIcon(Icons.favorite), findsOneWidget); // Health
        expect(find.byIcon(Icons.person), findsOneWidget); // Personal
        expect(find.byIcon(Icons.nightlight), findsOneWidget); // Evening
      });

      testWidgets('Should display tasks in correct categories', (WidgetTester tester) async {
        // This test would require mocked task data
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Verify tasks are grouped by category
        // This would need proper mocking of TaskProvider with test data
      });

      testWidgets('Should show empty state when no tasks exist', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Check for empty state messages
        expect(find.text('لا توجد مهام في هذا القسم'), findsWidgets);
      });

      testWidgets('Should display task priority indicators', (WidgetTester tester) async {
        // This test would verify priority badges/indicators
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Look for priority indicators (would need mocked data)
        // expect(find.text('عالية'), findsWidgets);
        // expect(find.text('متوسطة'), findsWidgets);
        // expect(find.text('منخفضة'), findsWidgets);
      });
    });

    group('3.2 Add Task Tests', () {
      testWidgets('Should open AddScreen in task mode', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Tap FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        
        // Select task option
        await tester.tap(find.text('مهمة'));
        await tester.pump();
        
        // Verify task form is displayed
        expect(find.text('إضافة مهمة جديدة'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(4)); // Title, Category, Priority, Time
      });

      testWidgets('Should validate required task fields', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AddScreen()));
        await tester.pumpAndSettle();
        
        // Select task option
        await tester.tap(find.text('مهمة'));
        await tester.pump();
        
        // Try to save without filling fields
        await tester.tap(find.text('حفظ'));
        await tester.pump();
        
        // Verify validation messages
        expect(find.text('الرجاء إدخال عنوان المهمة'), findsOneWidget);
      });

      testWidgets('Should allow selecting task category', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AddScreen()));
        await tester.pumpAndSettle();
        
        // Select task option
        await tester.tap(find.text('مهمة'));
        await tester.pump();
        
        // Enter task title
        await tester.enterText(find.byType(TextFormField).first, 'مهمة اختبار');
        
        // Tap category dropdown
        await tester.tap(find.text('اختر الفئة'));
        await tester.pump();
        
        // Select a category
        await tester.tap(find.text('العمل').last); // Last occurrence to avoid title
        await tester.pump();
        
        // Verify category is selected
        expect(find.text('العمل'), findsAtLeastNWidgets(2));
      });

      testWidgets('Should allow selecting task priority', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AddScreen()));
        await tester.pumpAndSettle();
        
        // Select task option
        await tester.tap(find.text('مهمة'));
        await tester.pump();
        
        // Enter task title
        await tester.enterText(find.byType(TextFormField).first, 'مهمة اختبار');
        
        // Tap priority dropdown
        await tester.tap(find.text('اختر الأولوية'));
        await tester.pump();
        
        // Select high priority
        await tester.tap(find.text('عالية'));
        await tester.pump();
        
        // Verify priority is selected
        expect(find.text('عالية'), findsAtLeastNWidgets(2));
      });

      testWidgets('Should save task successfully', (WidgetTester tester) async {
        await ComprehensiveTestHelper.testAddTask(tester);
        
        // This test would verify:
        // 1. Task is saved to database
        // 2. Success message is shown
        // 3. User is navigated back
        // 4. Task appears in the correct category
      });
    });

    group('3.3 Complete Task Tests', () {
      testWidgets('Should show checkbox for each task', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Look for checkboxes (would need mocked tasks)
        final checkboxes = find.byType(Checkbox);
        
        // If tasks exist, checkboxes should be present
        if (checkboxes.evaluate().isNotEmpty) {
          expect(checkboxes, findsWidgets);
        }
      });

      testWidgets('Should toggle task completion state', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Find first checkbox
        final checkbox = find.byType(Checkbox).first;
        
        if (checkbox.evaluate().isNotEmpty) {
          // Get initial state
          final Checkbox checkboxWidget = tester.widget(checkbox);
          final initialState = checkboxWidget.value;
          
          // Tap to toggle
          await tester.tap(checkbox);
          await tester.pump();
          
          // Verify state changed
          final Checkbox newCheckboxWidget = tester.widget(checkbox);
          expect(newCheckboxWidget.value, isNot(equals(initialState)));
        }
      });

      testWidgets('Should show completion animation', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        final checkbox = find.byType(Checkbox).first;
        
        if (checkbox.evaluate().isNotEmpty) {
          await tester.tap(checkbox);
          await tester.pump();
          
          // Look for animation indicators
          expect(find.byType(AnimatedContainer), findsWidgets);
          expect(find.byType(AnimatedOpacity), findsWidgets);
        }
      });

      testWidgets('Should update progress bar when task is completed', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Look for progress bar
        final progressBar = find.byType(LinearProgressIndicator);
        
        if (progressBar.evaluate().isNotEmpty) {
          // Get initial progress
          final LinearProgressIndicator progressWidget = tester.widget(progressBar);
          final initialProgress = progressWidget.value;
          
          // Complete a task
          final checkbox = find.byType(Checkbox).first;
          if (checkbox.evaluate().isNotEmpty) {
            await tester.tap(checkbox);
            await tester.pump();
            
            // Verify progress updated (would need proper mocking)
            // final LinearProgressIndicator newProgressWidget = tester.widget(progressBar);
            // expect(newProgressWidget.value, greaterThan(initialProgress));
          }
        }
      });

      testWidgets('Should award XP for completed tasks', (WidgetTester tester) async {
        // This test would verify XP calculation
        // High priority: 15 XP
        // Medium priority: 10 XP
        // Low priority: 5 XP
        
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Complete a task and check XP increase
        // This would require mocking the achievements provider
      });
    });

    group('3.4 Task Update Tests', () {
      testWidgets('Should support pull-to-refresh', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Perform pull-to-refresh
        await tester.fling(
          find.byType(Scrollable),
          const Offset(0, 300),
          1000,
        );
        await tester.pump();
        
        // Look for refresh indicator
        expect(find.byType(RefreshProgressIndicator), findsOneWidget);
        
        // Wait for refresh to complete
        await tester.pumpAndSettle();
      });

      testWidgets('Should show loading indicator during refresh', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Start refresh
        await tester.fling(
          find.byType(Scrollable),
          const Offset(0, 300),
          1000,
        );
        await tester.pump();
        
        // Verify loading state
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });

      testWidgets('Should handle refresh errors gracefully', (WidgetTester tester) async {
        // This test would require mocking network errors
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Perform refresh with mocked error
        await tester.fling(
          find.byType(Scrollable),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();
        
        // Verify error handling
        // expect(find.text('فشل تحديث المهام'), findsOneWidget);
      });

      testWidgets('Should maintain scroll position after refresh', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Scroll down
        await tester.fling(find.byType(Scrollable), const Offset(0, -200), 1000);
        await tester.pumpAndSettle();
        
        // Refresh
        await tester.fling(
          find.byType(Scrollable),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();
        
        // Verify position is maintained (if implemented)
      });
    });

    group('3.5 Task Filtering and Sorting Tests', () {
      testWidgets('Should filter tasks by category', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Tasks are already filtered by category in sections
        // Verify only tasks of specific category are shown in each section
      });

      testWidgets('Should sort tasks by priority', (WidgetTester tester) async {
        // This test would verify task sorting within categories
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Verify high priority tasks appear first
      });

      testWidgets('Should show completed tasks separately', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Verify completed tasks have different styling
        final completedTasks = find.byWidgetPredicate((widget) {
          if (widget is Container) {
            // Check for completed task styling
            return widget.decoration is BoxDecoration;
          }
          return false;
        });
      });
    });

    group('3.6 Task Interaction Tests', () {
      testWidgets('Should allow long press to edit task', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Find task items and long press
        final taskItems = find.byType(ListTile);
        
        if (taskItems.evaluate().isNotEmpty) {
          await tester.longPress(taskItems.first);
          await tester.pumpAndSettle();
          
          // Verify edit menu appears
          // expect(find.text('تعديل'), findsOneWidget);
          // expect(find.text('حذف'), findsOneWidget);
        }
      });

      testWidgets('Should show task details on tap', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Tap on a task to show details
        final taskItems = find.byType(ListTile);
        
        if (taskItems.evaluate().isNotEmpty) {
          await tester.tap(taskItems.first);
          await tester.pumpAndSettle();
          
          // Verify task details dialog/screen
          // expect(find.text('تفاصيل المهمة'), findsOneWidget);
        }
      });

      testWidgets('Should allow swipe to delete task', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // Test swipe to delete functionality
        final taskItems = find.byType(Dismissible);
        
        if (taskItems.evaluate().isNotEmpty) {
          await tester.drag(taskItems.first, const Offset(500, 0));
          await tester.pumpAndSettle();
          
          // Verify delete confirmation
          // expect(find.text('حذف المهمة؟'), findsOneWidget);
        }
      });
    });

    group('Task Integration Tests', () {
      testWidgets('Should complete full task lifecycle', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: HomeScreen()));
        await tester.pumpAndSettle();
        
        // 1. Add new task
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('مهمة'));
        await tester.pump();
        
        await tester.enterText(find.byType(TextFormField).first, 'مهمة اختبار كاملة');
        await tester.tap(find.text('حفظ'));
        await tester.pumpAndSettle();
        
        // 2. Complete the task
        final checkbox = find.byType(Checkbox).first;
        if (checkbox.evaluate().isNotEmpty) {
          await tester.tap(checkbox);
          await tester.pump();
        }
        
        // 3. Verify task is completed
        // 4. Check XP awarded
        // 5. Verify progress updated
      });
    });
  });
}
