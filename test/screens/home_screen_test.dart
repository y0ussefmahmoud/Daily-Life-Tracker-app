import 'package:daily_life_tracker/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../test_helpers/test_helpers.dart';
import 'package:daily_life_tracker/providers/task_provider.dart';
import 'package:daily_life_tracker/providers/water_provider.dart';

void main() {
  late TaskProvider taskProvider;
  late WaterProvider waterProvider;

  setUp(() {
    taskProvider = TaskProvider();
    waterProvider = WaterProvider();
  });

  Widget createHomeScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => taskProvider),
        ChangeNotifierProvider(create: (_) => waterProvider),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen displays all main components', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // Verify main components are present
    expect(find.byType(ProfileHeader), findsOneWidget);
    expect(find.byType(ProgressBarWidget), findsOneWidget);
    expect(find.text('المهام اليومية'), findsOneWidget);
    expect(find.byType(WaterTracker), findsOneWidget);
    expect(find.byType(DailySummaryCard), findsOneWidget);
  });

  testWidgets('Task sections are displayed', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // Verify all task sections are present
    expect(find.text('الصباح'), findsOneWidget);
    expect(find.text('العمل'), findsOneWidget);
    expect(find.text('الصلاة'), findsOneWidget);
    expect(find.text('الصحة'), findsOneWidget);
    expect(find.text('شخصي'), findsOneWidget);
    expect(find.text('المساء'), findsOneWidget);
  });

  testWidgets('Task completion toggles correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // Find the first task checkbox and tap it
    final firstCheckbox = find.byType(Checkbox).first;
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    // Verify the task was marked as completed
    expect(tester.widget<Checkbox>(firstCheckbox).value, isTrue);
  });

  testWidgets('Water tracker increments correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // Find and tap the add water button
    final addWaterButton = find.byIcon(Icons.add);
    await tester.tap(addWaterButton);
    await tester.pumpAndSettle();

    // Verify water count increased
    expect(waterProvider.waterIntake, equals(1));
  });

  testWidgets('Pull to refresh works', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // Find the list view and drag down to refresh
    final listView = find.byType(RefreshIndicator);
    await tester.drag(listView, const Offset(0, 300));
    await tester.pumpAndSettle();

    // Verify the refresh indicator is shown
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
  });
}
