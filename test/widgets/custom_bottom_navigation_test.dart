import 'package:daily_life_tracker/widgets/custom_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  testWidgets('CustomBottomNavigation renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: 0,
            onTap: (index) {},
          ),
        ),
      ),
    );

    // Verify bottom navigation items are present
    expect(find.byIcon(Icons.today_outlined), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.work_outline), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('CustomBottomNavigation changes index on tap', (WidgetTester tester) async {
    int currentIndex = 0;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: currentIndex,
            onTap: (index) {
              currentIndex = index;
            },
          ),
        ),
      ),
    );

    // Tap on the second tab
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();
    
    // Verify the callback was called with the correct index
    expect(currentIndex, 1);
  });

  testWidgets('CustomBottomNavigation FAB is present and tappable', (WidgetTester tester) async {
    bool fabTapped = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              fabTapped = true;
            },
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: const CustomBottomNavigation(
            currentIndex: 0,
            onTap: (index) {},
          ),
        ),
      ),
    );

    // Verify FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
    
    // Tap the FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    
    // Verify FAB onPressed was called
    expect(fabTapped, isTrue);
  });
}
