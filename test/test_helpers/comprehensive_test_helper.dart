import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../lib/providers/auth_provider.dart';
import '../../lib/providers/task_provider.dart';
import '../../lib/providers/project_provider.dart';
import '../../lib/providers/water_provider.dart';
import '../../lib/providers/stats_provider.dart';
import '../../lib/providers/achievements_provider.dart';
import '../../lib/providers/settings_provider.dart';
import '../../lib/providers/profile_provider.dart';
import '../../lib/providers/subtask_provider.dart';
import '../../lib/screens/splash_screen.dart';
import '../../lib/screens/home_screen.dart';
import '../../lib/screens/auth/login_screen.dart';
import '../../lib/screens/auth/signup_screen.dart';
import '../../lib/screens/add_screen.dart';
import '../../lib/screens/profile_screen.dart';
import '../../lib/screens/projects_screen.dart';
import '../../lib/screens/stats_screen.dart';
import '../../lib/screens/achievements_screen.dart';
import '../../lib/main.dart';

/// Comprehensive Test Helper for Daily Life Tracker App
/// Provides utilities and test data for all testing phases
class ComprehensiveTestHelper {
  
  // Test Data
  static const Map<String, dynamic> testUser = {
    'email': 'test@example.com',
    'password': 'test123456',
    'name': 'Test User',
  };
  
  static const Map<String, dynamic> invalidUser = {
    'email': 'invalid-email',
    'password': '123',
    'name': '',
  };
  
  static const List<Map<String, dynamic>> testTasks = [
    {
      'title': 'مهمة اختبار صباحية',
      'category': 'morning',
      'priority': 'high',
      'is_completed': false,
    },
    {
      'title': 'مهمة اختبار عمل',
      'category': 'work',
      'priority': 'medium',
      'is_completed': false,
    },
    {
      'title': 'مهمة اختبار صحة',
      'category': 'health',
      'priority': 'low',
      'is_completed': true,
    },
  ];
  
  static const List<Map<String, dynamic>> testProjects = [
    {
      'name': 'مشروع اختبار 1',
      'description': 'وصف مشروع الاختبار الأول',
      'start_date': '2024-01-01',
      'end_date': '2024-12-31',
      'technologies': ['Flutter', 'Dart', 'Supabase'],
      'is_paused': false,
    },
    {
      'name': 'مشروع اختبار 2',
      'description': 'وصف مشروع الاختبار الثاني',
      'start_date': '2024-06-01',
      'end_date': '2024-12-31',
      'technologies': ['React', 'Node.js'],
      'is_paused': true,
    },
  ];

  /// Create test widget with all providers
  static Widget createTestWidget({Widget? child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SubTaskProvider()),
        ChangeNotifierProxyProvider<AchievementsProvider, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, achievementsProvider, taskProvider) {
            taskProvider!.setAchievementsProvider(achievementsProvider);
            return taskProvider;
          },
        ),
        ChangeNotifierProxyProvider<AchievementsProvider, ProjectProvider>(
          create: (_) => ProjectProvider(),
          update: (_, achievementsProvider, projectProvider) {
            projectProvider!.setAchievementsProvider(achievementsProvider);
            return projectProvider;
          },
        ),
        ChangeNotifierProxyProvider4<TaskProvider, ProjectProvider, WaterProvider, AchievementsProvider, StatsProvider>(
          create: (_) => StatsProvider(),
          update: (_, taskProvider, projectProvider, waterProvider, achievementsProvider, statsProvider) {
            statsProvider!.setProviders(
              taskProvider,
              projectProvider,
              waterProvider,
              achievementsProvider,
            );
            return statsProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        home: child ?? const SplashScreen(),
      ),
    );
  }

  // Phase 1: Authentication Tests
  static Future<void> testSplashScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    
    // Check if splash screen is displayed
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Daily Life Tracker'), findsOneWidget);
    expect(find.text('جاري التهيئة...'), findsOneWidget);
    
    // Wait for initialization
    await tester.pumpAndSettle();
  }
  
  static Future<void> testLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: LoginScreen()));
    await tester.pumpAndSettle();
    
    // Check login screen elements
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
    expect(find.text('سجل الآن'), findsOneWidget);
  }
  
  static Future<void> testInvalidLogin(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: LoginScreen()));
    await tester.pumpAndSettle();
    
    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();
    
    // Check for error message
    expect(find.text('صيغة البريد الإلكتروني غير صحيحة'), findsOneWidget);
  }
  
  static Future<void> testShortPassword(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: LoginScreen()));
    await tester.pumpAndSettle();
    
    // Enter valid email but short password
    await tester.enterText(find.byType(TextFormField).first, testUser['email']!);
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();
    
    // Check for error message
    expect(find.text('كلمة المرور قصيرة جداً'), findsOneWidget);
  }

  // Phase 2: Navigation Tests
  static Future<void> testBottomNavigation(WidgetTester tester) async {
    // Mock authenticated user
    await tester.pumpWidget(createTestWidget(child: HomeScreen()));
    await tester.pumpAndSettle();
    
    // Test navigation to different tabs
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    expect(find.byIcon(Icons.work), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    
    // Test tab switching
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();
    
    await tester.tap(find.byIcon(Icons.work));
    await tester.pumpAndSettle();
    
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
  }
  
  static Future<void> testFABButton(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: HomeScreen()));
    await tester.pumpAndSettle();
    
    // Check if FAB exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    
    // Test FAB tap
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    
    expect(find.byType(AddScreen), findsOneWidget);
  }

  // Phase 3: Task Tests
  static Future<void> testTaskDisplay(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: HomeScreen()));
    await tester.pumpAndSettle();
    
    // Check for task categories
    expect(find.text('الصباح'), findsOneWidget);
    expect(find.text('العمل'), findsOneWidget);
    expect(find.text('الصحة'), findsOneWidget);
    expect(find.text('شخصي'), findsOneWidget);
    expect(find.text('المساء'), findsOneWidget);
  }
  
  static Future<void> testAddTask(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: AddScreen()));
    await tester.pumpAndSettle();
    
    // Select task option
    await tester.tap(find.text('مهمة'));
    await tester.pump();
    
    // Fill task form
    await tester.enterText(find.byType(TextFormField).first, 'مهمة اختبار جديدة');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();
    
    // Verify task was added (this would need proper mocking)
  }
  
  static Future<void> testCompleteTask(WidgetTester tester) async {
    // This would require pre-populated test data
    await tester.pumpWidget(createTestWidget(child: HomeScreen()));
    await tester.pumpAndSettle();
    
    // Find and tap checkbox
    final checkboxFinder = find.byType(Checkbox);
    if (checkboxFinder.evaluate().isNotEmpty) {
      await tester.tap(checkboxFinder.first);
      await tester.pump();
      
      // Verify task completion animation and XP update
    }
  }

  // Phase 4: Project Tests
  static Future<void> testProjectDisplay(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: ProjectsScreen()));
    await tester.pumpAndSettle();
    
    // Check for project sections
    expect(find.text('المشاريع النشطة'), findsOneWidget);
    expect(find.text('المشاريع المتوقفة'), findsOneWidget);
  }
  
  static Future<void> testAddProject(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: AddScreen()));
    await tester.pumpAndSettle();
    
    // Select project option
    await tester.tap(find.text('مشروع'));
    await tester.pump();
    
    // Fill project form
    await tester.enterText(find.byType(TextFormField).first, 'مشروع اختبار جديد');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();
  }

  // Phase 5: Water Tracker and Statistics Tests
  static Future<void> testWaterTracker(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: HomeScreen()));
    await tester.pumpAndSettle();
    
    // Check water tracker widget
    expect(find.text('المياه'), findsOneWidget);
    expect(find.byIcon(Icons.water_drop), findsOneWidget);
    
    // Test adding water
    final addWaterButton = find.byIcon(Icons.add);
    if (addWaterButton.evaluate().isNotEmpty) {
      await tester.tap(addWaterButton);
      await tester.pump();
      
      // Verify water count update
    }
  }
  
  static Future<void> testStatsScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: StatsScreen()));
    await tester.pumpAndSettle();
    
    // Check statistics elements
    expect(find.text('إحصائيات الأسبوع'), findsOneWidget);
    expect(find.text('المهام المكتملة'), findsOneWidget);
    expect(find.text('المشاريع النشطة'), findsOneWidget);
  }
  
  static Future<void> testAchievementsScreen(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: AchievementsScreen()));
    await tester.pumpAndSettle();
    
    // Check achievements elements
    expect(find.text('الإنجازات'), findsOneWidget);
    expect(find.text('المستوى'), findsOneWidget);
  }

  // Phase 6: Theme Tests
  static Future<void> testDarkModeToggle(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: ProfileScreen()));
    await tester.pumpAndSettle();
    
    // Find dark mode toggle
    final darkModeSwitch = find.byType(Switch);
    if (darkModeSwitch.evaluate().isNotEmpty) {
      await tester.tap(darkModeSwitch);
      await tester.pump();
      
      // Verify theme change
    }
  }

  // Phase 7: Error Handling Tests
  static Future<void> testNetworkError(WidgetTester tester) async {
    // This would require mocking network failures
    await tester.pumpWidget(createTestWidget(child: LoginScreen()));
    await tester.pumpAndSettle();
    
    // Simulate network error and check error handling
  }
  
  static Future<void> testTimeoutError(WidgetTester tester) async {
    // This would require mocking timeout scenarios
    await tester.pumpWidget(createTestWidget(child: SplashScreen()));
    await tester.pumpAndSettle();
    
    // Simulate timeout and check error handling
  }

  // Phase 8: Performance Tests
  static Future<void> testAppStartupPerformance(WidgetTester tester) async {
    final stopwatch = Stopwatch()..start();
    
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    
    stopwatch.stop();
    
    // App should start within 3 seconds
    expect(stopwatch.elapsedMilliseconds, lessThan(3000));
  }
  
  static Future<void> testNavigationPerformance(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(child: HomeScreen()));
    await tester.pumpAndSettle();
    
    final stopwatch = Stopwatch()..start();
    
    // Test navigation between screens
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();
    
    stopwatch.stop();
    
    // Navigation should be fast (< 500ms)
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  }

  // Utility Methods
  static Future<void> waitForLoading(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }
  
  static Future<void> scrollToEnd(WidgetTester tester) async {
    await tester.fling(find.byType(Scrollable), const Offset(0, -500), 10000);
    await tester.pumpAndSettle();
  }
  
  static void logTestResult(String testName, bool passed, {String? notes}) {
    final status = passed ? '✅ PASSED' : '❌ FAILED';
    print('$status: $testName');
    if (notes != null) {
      print('  Notes: $notes');
    }
  }
}

/// Custom Test Matchers
class CustomMatchers {
  static Matcher hasValidEmail() => predicate((dynamic widget) {
    if (widget is TextFormField) {
      final initialValue = widget.initialValue;
      return initialValue != null && 
             initialValue.toString().contains('@') && 
             initialValue.toString().contains('.');
    }
    return false;
  });
  
  static Matcher hasValidPassword() => predicate((dynamic widget) {
    if (widget is TextFormField) {
      final initialValue = widget.initialValue;
      return initialValue != null && initialValue.toString().length >= 6;
    }
    return false;
  });
}

/// Test Data Generator
class TestDataGenerator {
  static Map<String, dynamic> generateRandomTask() {
    final categories = ['morning', 'work', 'prayer', 'health', 'personal', 'evening'];
    final priorities = ['high', 'medium', 'low'];
    
    return {
      'title': 'مهمة اختبار ${DateTime.now().millisecondsSinceEpoch}',
      'category': categories[(DateTime.now().millisecondsSinceEpoch) % categories.length],
      'priority': priorities[(DateTime.now().millisecondsSinceEpoch) % priorities.length],
      'is_completed': false,
    };
  }
  
  static Map<String, dynamic> generateRandomProject() {
    final technologies = ['Flutter', 'Dart', 'React', 'Node.js', 'Python', 'Java'];
    
    return {
      'name': 'مشروع اختبار ${DateTime.now().millisecondsSinceEpoch}',
      'description': 'وصف مشروع اختبار تلقائي',
      'start_date': DateTime.now().toIso8601String().split('T')[0],
      'end_date': DateTime.now().add(const Duration(days: 365)).toIso8601String().split('T')[0],
      'technologies': [technologies[(DateTime.now().millisecondsSinceEpoch) % technologies.length]],
      'is_paused': false,
    };
  }
}
