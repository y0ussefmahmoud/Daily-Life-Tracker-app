import 'package:daily_life_tracker/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class TestHelper {
  static Future<void> pumpApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
  }

  static Future<void> switchTheme(WidgetTester tester) async {
    // Navigate to profile screen
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    // Scroll to theme switch
    final themeSwitch = find.byType(Switch).first;
    await tester.scrollUntilVisible(themeSwitch, 100.0);
    await tester.pumpAndSettle();

    // Toggle theme
    await tester.tap(themeSwitch);
    await tester.pumpAndSettle();
  }

  static Future<void> navigateToTab(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await tester.pumpAndSettle();
  }
}

void initializeIntegrationTests() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}
