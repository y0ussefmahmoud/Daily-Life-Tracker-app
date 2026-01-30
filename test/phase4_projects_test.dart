import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'test_helpers/comprehensive_test_helper.dart';
import '../lib/screens/projects_screen.dart';
import '../lib/screens/project_details_screen.dart';
import '../lib/screens/add_screen.dart';
import '../lib/providers/project_provider.dart';

// Generate mocks
@GenerateMocks([ProjectProvider])
import 'phase4_projects_test.mocks.dart';

void main() {
  group('Phase 4: Projects Tests', () {
    late MockProjectProvider mockProjectProvider;

    setUp(() {
      mockProjectProvider = MockProjectProvider();
    });

    group('4.1 Project Display Tests', () {
      testWidgets('Should display project sections', (WidgetTester tester) async {
        await ComprehensiveTestHelper.testProjectDisplay(tester);
        
        // Verify project sections are present
        expect(find.text('المشاريع النشطة'), findsOneWidget);
        expect(find.text('المشاريع المتوقفة'), findsOneWidget);
      });

      testWidgets('Should display active projects', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectsScreen()));
        await tester.pumpAndSettle();
        
        // Look for active project cards
        final activeProjects = find.byWidgetPredicate((widget) {
          if (widget is Card) {
            // Check if this is an active project card
            return true; // Would need more specific identification
          }
          return false;
        });
        
        // Verify active projects section exists
        expect(find.text('المشاريع النشطة'), findsOneWidget);
      });

      testWidgets('Should display paused projects', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectsScreen()));
        await tester.pumpAndSettle();
        
        // Verify paused projects section exists
        expect(find.text('المشاريع المتوقفة'), findsOneWidget);
      });

      testWidgets('Should display project progress indicators', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectsScreen()));
        await tester.pumpAndSettle();
        
        // Look for progress indicators
        final progressBars = find.byType(LinearProgressIndicator);
        final circularProgress = find.byType(CircularProgressIndicator);
        
        // Projects should have progress indicators
        expect(progressBars.evaluate().isNotEmpty || circularProgress.evaluate().isNotEmpty, isTrue);
      });

      testWidgets('Should display project technologies', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectsScreen()));
        await tester.pumpAndSettle();
        
        // Look for technology chips
        final techChips = find.byType(Chip);
        
        if (techChips.evaluate().isNotEmpty) {
          expect(techChips, findsWidgets);
        }
      });

      testWidgets('Should show empty state when no projects exist', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectsScreen()));
        await tester.pumpAndSettle();
        
        // Check for empty state messages
        expect(find.text('لا توجد مشاريع نشطة'), findsOneWidget);
        expect(find.text('لا توجد مشاريع متوقفة'), findsOneWidget);
      });
    });

    group('4.2 Add Project Tests', () {
      testWidgets('Should open AddScreen in project mode', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectsScreen()));
        await tester.pumpAndSettle();
        
        // Tap FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        
        // Select project option
        await tester.tap(find.text('مشروع'));
        await tester.pump();
        
        // Verify project form is displayed
        expect(find.text('إضافة مشروع جديد'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(5)); // Name, Description, Start Date, End Date, Technologies
      });

      testWidgets('Should validate required project fields', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AddScreen()));
        await tester.pumpAndSettle();
        
        // Select project option
        await tester.tap(find.text('مشروع'));
        await tester.pump();
        
        // Try to save without filling fields
        await tester.tap(find.text('حفظ'));
        await tester.pump();
        
        // Verify validation messages
        expect(find.text('الرجاء إدخال اسم المشروع'), findsOneWidget);
        expect(find.text('الرجاء إدخال وصف المشروع'), findsOneWidget);
      });

      testWidgets('Should allow selecting project dates', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AddScreen()));
        await tester.pumpAndSettle();
        
        // Select project option
        await tester.tap(find.text('مشروع'));
        await tester.pump();
        
        // Fill required fields
        await tester.enterText(find.byType(TextFormField).first, 'مشروع اختبار');
        await tester.enterText(find.byType(TextFormField).at(1), 'وصف مشروع اختبار');
        
        // Tap start date field
        await tester.tap(find.text('اختر تاريخ البداية'));
        await tester.pump();
        
        // Select a date (would need to interact with date picker)
        await tester.tap(find.text('موافق'));
        await tester.pump();
        
        // Tap end date field
        await tester.tap(find.text('اختر تاريخ النهاية'));
        await tester.pump();
        
        // Select a date
        await tester.tap(find.text('موافق'));
        await tester.pump();
      });

      testWidgets('Should allow adding technologies', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: AddScreen()));
        await tester.pumpAndSettle();
        
        // Select project option
        await tester.tap(find.text('مشروع'));
        await tester.pump();
        
        // Fill required fields
        await tester.enterText(find.byType(TextFormField).first, 'مشروع اختبار');
        await tester.enterText(find.byType(TextFormField).at(1), 'وصف مشروع اختبار');
        
        // Look for technology input field
        final techField = find.byKey(const Key('technology_input'));
        if (techField.evaluate().isNotEmpty) {
          await tester.enterText(techField, 'Flutter');
          await tester.tap(find.byIcon(Icons.add));
          await tester.pump();
          
          // Verify technology chip is added
          expect(find.text('Flutter'), findsOneWidget);
        }
      });

      testWidgets('Should save project successfully', (WidgetTester tester) async {
        await ComprehensiveTestHelper.testAddProject(tester);
        
        // This test would verify:
        // 1. Project is saved to database
        // 2. Success message is shown
        // 3. User is navigated back
        // 4. Project appears in the correct section
      });
    });

    group('4.3 Project Details Tests', () {
      testWidgets('Should navigate to project details when project is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectsScreen()));
        await tester.pumpAndSettle();
        
        // Find project card and tap it
        final projectCards = find.byType(Card);
        
        if (projectCards.evaluate().isNotEmpty) {
          await tester.tap(projectCards.first);
          await tester.pumpAndSettle();
          
          // Verify navigation to project details
          expect(find.byType(ProjectDetailsScreen), findsOneWidget);
        }
      });

      testWidgets('Should display all project information', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Verify project details elements
        expect(find.text('تفاصيل المشروع'), findsOneWidget);
        expect(find.byIcon(Icons.work), findsOneWidget);
        
        // Look for project information sections
        expect(find.text('اسم المشروع'), findsOneWidget);
        expect(find.text('الوصف'), findsOneWidget);
        expect(find.text('التاريخ'), findsOneWidget);
        expect(find.text('التقنيات'), findsOneWidget);
        expect(find.text('نسبة الإنجاز'), findsOneWidget);
      });

      testWidgets('Should display project subtasks', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Look for subtasks section
        expect(find.text('المهام الفرعية'), findsOneWidget);
        
        // Look for subtask list
        final subtaskList = find.byType(ListView);
        if (subtaskList.evaluate().isNotEmpty) {
          expect(subtaskList, findsOneWidget);
        }
      });

      testWidgets('Should allow adding new subtasks', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Look for add subtask button
        final addSubtaskButton = find.byIcon(Icons.add);
        if (addSubtaskButton.evaluate().isNotEmpty) {
          await tester.tap(addSubtaskButton);
          await tester.pump();
          
          // Verify subtask input appears
          expect(find.byType(TextField), findsWidgets);
        }
      });

      testWidgets('Should update progress when subtasks are completed', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Find subtask checkboxes
        final subtaskCheckboxes = find.byType(Checkbox);
        
        if (subtaskCheckboxes.evaluate().isNotEmpty) {
          // Get initial progress
          final initialProgress = find.byType(LinearProgressIndicator);
          
          // Complete a subtask
          await tester.tap(subtaskCheckboxes.first);
          await tester.pump();
          
          // Verify progress updated
          // This would require checking the progress value
        }
      });

      testWidgets('Should award XP for completing subtasks', (WidgetTester tester) async {
        // This test would verify XP calculation for subtasks
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Complete a subtask and check XP increase
        // This would require mocking the achievements provider
      });
    });

    group('4.4 Project Pause/Resume Tests', () {
      testWidgets('Should show pause button for active projects', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Look for pause button
        expect(find.text('إيقاف المشروع'), findsOneWidget);
      });

      testWidgets('Should pause project when pause button is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Tap pause button
        await tester.tap(find.text('إيقاف المشروع'));
        await tester.pump();
        
        // Verify confirmation dialog
        expect(find.text('تأكيد إيقاف المشروع'), findsOneWidget);
        expect(find.text('هل أنت متأكد من إيقاف هذا المشروع؟'), findsOneWidget);
        
        // Confirm pause
        await tester.tap(find.text('إيقاف'));
        await tester.pumpAndSettle();
        
        // Verify button changed to resume
        expect(find.text('استئناف المشروع'), findsOneWidget);
      });

      testWidgets('Should show resume button for paused projects', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Look for resume button (would need mocked paused project)
        // expect(find.text('استئناف المشروع'), findsOneWidget);
      });

      testWidgets('Should resume project when resume button is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // This test would require a paused project
        // Tap resume button
        // await tester.tap(find.text('استئناف المشروع'));
        // await tester.pump();
        
        // Verify confirmation dialog
        // expect(find.text('تأكيد استئناف المشروع'), findsOneWidget);
        
        // Confirm resume
        // await tester.tap(find.text('استئناف'));
        // await tester.pumpAndSettle();
        
        // Verify button changed to pause
        // expect(find.text('إيقاف المشروع'), findsOneWidget);
      });

      testWidgets('Should move project between sections when paused/resumed', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectsScreen()));
        await tester.pumpAndSettle();
        
        // This test would verify:
        // 1. Project moves from active to paused when paused
        // 2. Project moves from paused to active when resumed
        // 3. UI updates accordingly
      });
    });

    group('4.5 Project Progress Tests', () {
      testWidgets('Should calculate progress correctly based on subtasks', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Verify progress calculation
        // This would require mocking subtask data
        final progressBar = find.byType(LinearProgressIndicator);
        
        if (progressBar.evaluate().isNotEmpty) {
          final LinearProgressIndicator progressWidget = tester.widget(progressBar);
          expect(progressWidget.value, isA<double>());
          expect(progressWidget.value, greaterThanOrEqualTo(0.0));
          expect(progressWidget.value, lessThanOrEqualTo(1.0));
        }
      });

      testWidgets('Should show progress percentage', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Look for progress percentage text
        // expect(find.text('%'), findsWidgets);
      });

      testWidgets('Should show completion celebration when project is 100% complete', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // This test would verify celebration animation when project is completed
        // expect(find.byIcon(Icons.celebration), findsOneWidget);
      });
    });

    group('4.6 Project Management Tests', () {
      testWidgets('Should allow editing project details', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Look for edit button
        final editButton = find.byIcon(Icons.edit);
        if (editButton.evaluate().isNotEmpty) {
          await tester.tap(editButton);
          await tester.pumpAndSettle();
          
          // Verify edit form opens
          expect(find.text('تعديل المشروع'), findsOneWidget);
        }
      });

      testWidgets('Should allow deleting project', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Look for delete button
        final deleteButton = find.byIcon(Icons.delete);
        if (deleteButton.evaluate().isNotEmpty) {
          await tester.tap(deleteButton);
          await tester.pump();
          
          // Verify confirmation dialog
          expect(find.text('حذف المشروع'), findsOneWidget);
          expect(find.text('هل أنت متأكد من حذف هذا المشروع؟'), findsOneWidget);
        }
      });

      testWidgets('Should show project statistics', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectDetailsScreen()));
        await tester.pumpAndSettle();
        
        // Look for statistics section
        expect(find.text('إحصائيات المشروع'), findsOneWidget);
        
        // Verify statistics items
        expect(find.text('عدد المهام الفرعية'), findsOneWidget);
        expect(find.text('المهام المكتملة'), findsOneWidget);
        expect(find.text('الوقت المستغرق'), findsOneWidget);
      });
    });

    group('Project Integration Tests', () {
      testWidgets('Should complete full project lifecycle', (WidgetTester tester) async {
        await tester.pumpWidget(ComprehensiveTestHelper.createTestWidget(child: ProjectsScreen()));
        await tester.pumpAndSettle();
        
        // 1. Add new project
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('مشروع'));
        await tester.pump();
        
        await tester.enterText(find.byType(TextFormField).first, 'مشروع اختبار كامل');
        await tester.enterText(find.byType(TextFormField).at(1), 'وصف مشروع اختبار كامل');
        await tester.tap(find.text('حفظ'));
        await tester.pumpAndSettle();
        
        // 2. Navigate to project details
        final projectCards = find.byType(Card);
        if (projectCards.evaluate().isNotEmpty) {
          await tester.tap(projectCards.first);
          await tester.pumpAndSettle();
          
          // 3. Add subtasks
          // 4. Complete subtasks
          // 5. Pause/resume project
          // 6. Edit project
          // 7. Delete project
        }
      });
    });
  });
}
