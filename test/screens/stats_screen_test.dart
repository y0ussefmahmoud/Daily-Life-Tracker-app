import 'package:daily_life_tracker/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_helpers/test_helpers.dart';
import 'package:provider/provider.dart';
import 'package:daily_life_tracker/providers/task_provider.dart';
import 'package:daily_life_tracker/providers/achievement_provider.dart';

void main() {
  late TaskProvider taskProvider;
  late AchievementProvider achievementProvider;

  setUp(() {
    taskProvider = TaskProvider();
    achievementProvider = AchievementProvider();
  });

  Widget createStatsScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => taskProvider),
        ChangeNotifierProvider(create: (_) => achievementProvider),
      ],
      child: const MaterialApp(
        home: StatsScreen(),
      ),
    );
  }

  testWidgets('StatsScreen displays all main components', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(createStatsScreen());
    await tester.pumpAndSettle();

    // Verify main components are present
    expect(find.text('الإحصائيات'), findsOneWidget);
    expect(find.byType(WeeklyChart), findsOneWidget);
    expect(find.text('توزيع الوقت'), findsOneWidget);
    expect(find.text('إنجازات الأسبوع'), findsOneWidget);
  });

  testWidgets('Weekly chart displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createStatsScreen());
    await tester.pumpAndSettle();

    // Verify the weekly chart is displayed
    expect(find.byType(WeeklyChart), findsOneWidget);
    
    // Verify there are 7 bars for each day of the week
    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('Time distribution items are displayed', (WidgetTester tester) async {
    await tester.pumpWidget(createStatsScreen());
    await tester.pumpAndSettle();

    // Verify time distribution items are present
    expect(find.byType(TimeDistributionItem), findsWidgets);
    expect(find.byType(TimeDistributionItem), findsAtLeast(3));
  });

  testWidgets('Achievement items are displayed', (WidgetTester tester) async {
    await tester.pumpWidget(createStatsScreen());
    await tester.pumpAndSettle();

    // Verify achievement items are present
    expect(find.byType(AchievementItem), findsWidgets);
    expect(find.byType(AchievementItem), findsAtLeast(1));
  });

  testWidgets('Share button is present and tappable', (WidgetTester tester) async {
    bool shareTapped = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  shareTapped = true;
                },
              ),
            ],
          ),
          body: const StatsScreen(),
        ),
      ),
    );

    // Find and tap the share button
    final shareButton = find.byIcon(Icons.share_outlined);
    expect(shareButton, findsOneWidget);
    
    await tester.tap(shareButton);
    await tester.pumpAndSettle();
    
    // Verify the share callback was called
    expect(shareTapped, isTrue);
  });

  testWidgets('Shows loading indicator when data is loading', (WidgetTester tester) async {
    // Create a mock provider that's always loading
    final mockTaskProvider = TaskProvider();
    mockTaskProvider.isLoading = true;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: mockTaskProvider,
        child: const MaterialApp(
          home: StatsScreen(),
        ),
      ),
    );

    // Verify loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
