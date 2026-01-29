import 'package:daily_life_tracker/screens/projects_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter.dart';
import 'package:provider/provider.dart';
import '../test_helpers/test_helpers.dart';
import 'package:daily_life_tracker/providers/project_provider.dart';

void main() {
  late ProjectProvider projectProvider;

  setUp(() {
    projectProvider = ProjectProvider();
  });

  Widget createProjectsScreen() {
    return ChangeNotifierProvider.value(
      value: projectProvider,
      child: const MaterialApp(
        home: ProjectsScreen(),
      ),
    );
  }

  testWidgets('ProjectsScreen displays all main components', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(createProjectsScreen());
    await tester.pumpAndSettle();

    // Verify main components are present
    expect(find.text('المشاريع'), findsOneWidget);
    expect(find.byType(MonthlyProgressWidget), findsOneWidget);
    expect(find.text('قيد التنفيذ'), findsOneWidget);
    expect(find.text('متوقف مؤقتاً'), findsOneWidget);
  });

  testWidgets('Displays active and paused projects', (WidgetTester tester) async {
    // Add test projects
    projectProvider.addProject(
      name: 'Test Project 1',
      status: 'active',
    );
    projectProvider.addProject(
      name: 'Test Project 2',
      status: 'paused',
    );

    await tester.pumpWidget(createProjectsScreen());
    await tester.pumpAndSettle();

    // Verify projects are displayed in correct sections
    expect(find.text('Test Project 1'), findsOneWidget);
    expect(find.text('Test Project 2'), findsOneWidget);
    expect(find.byType(ProjectCard), findsOneWidget);
    expect(find.byType(PausedProjectCard), findsOneWidget);
  });

  testWidgets('Can add a new project', (WidgetTester tester) async {
    await tester.pumpWidget(createProjectsScreen());
    await tester.pumpAndSettle();

    // Find and tap the add button
    final addButton = find.byIcon(Icons.add);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Verify the add project dialog is shown
    expect(find.text('إضافة مشروع جديد'), findsOneWidget);
    
    // Enter project name
    await tester.enterText(find.byType(TextField), 'New Test Project');
    
    // Tap save button
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    // Verify the project was added
    expect(find.text('New Test Project'), findsOneWidget);
  });

  testWidgets('Can delete a project', (WidgetTester tester) async {
    // Add a test project
    projectProvider.addProject(
      name: 'Project to delete',
      status: 'active',
    );

    await tester.pumpWidget(createProjectsScreen());
    await tester.pumpAndSettle();

    // Find and tap the more options button
    final moreButton = find.byIcon(Icons.more_vert);
    await tester.tap(moreButton);
    await tester.pumpAndSettle();

    // Tap delete option
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();

    // Confirm deletion
    await tester.tap(find.text('تأكيد'));
    await tester.pumpAndSettle();

    // Verify the project was deleted
    expect(find.text('Project to delete'), findsNothing);
  });

  testWidgets('Shows empty state when no projects exist', (WidgetTester tester) async {
    // Ensure no projects exist
    projectProvider.clearProjects();

    await tester.pumpWidget(createProjectsScreen());
    await tester.pumpAndSettle();

    // Verify empty state is shown
    expect(find.text('لا توجد مشاريع حالياً'), findsOneWidget);
    expect(find.text('انقر على + لإنشاء مشروع جديد'), findsOneWidget);
  });

  testWidgets('Can toggle project status', (WidgetTester tester) async {
    // Add a test project
    projectProvider.addProject(
      name: 'Toggle Test Project',
      status: 'active',
    );

    await tester.pumpWidget(createProjectsScreen());
    await tester.pumpAndSettle();

    // Find and tap the more options button
    final moreButton = find.byIcon(Icons.more_vert);
    await tester.tap(moreButton);
    await tester.pumpAndSettle();

    // Tap toggle status option
    await tester.tap(find.text('إيقاف مؤقت'));
    await tester.pumpAndSettle();

    // Verify the project is now in the paused section
    expect(find.byType(PausedProjectCard), findsOneWidget);
  });
}
