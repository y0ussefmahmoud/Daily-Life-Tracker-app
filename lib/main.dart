import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/achievements_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/project_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/subtask_provider.dart';
import 'providers/task_provider.dart';
import 'providers/water_provider.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const DailyLifeTrackerApp());
}

class DailyLifeTrackerApp extends StatelessWidget {
  const DailyLifeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SubTaskProvider()),
        ChangeNotifierProxyProvider<AchievementsProvider, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, achievementsProvider, taskProvider) {
            final provider = taskProvider ?? TaskProvider();
            provider.setAchievementsProvider(achievementsProvider);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AchievementsProvider, ProjectProvider>(
          create: (_) => ProjectProvider(),
          update: (_, achievementsProvider, projectProvider) {
            final provider = projectProvider ?? ProjectProvider();
            provider.setAchievementsProvider(achievementsProvider);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider4<TaskProvider, ProjectProvider, WaterProvider,
            AchievementsProvider, StatsProvider>(
          create: (_) => StatsProvider(),
          update: (_, taskProvider, projectProvider, waterProvider,
              achievementsProvider, statsProvider) {
            final provider = statsProvider ?? StatsProvider();
            provider.setProviders(
              taskProvider,
              projectProvider,
              waterProvider,
              achievementsProvider,
            );
            return provider;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: AppStrings.appName,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            themeMode: settingsProvider.darkModeEnabled
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final textColor = isDark ? AppColors.textLight : AppColors.textPrimary;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor:
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      brightness: brightness,
    ),
    cardTheme: CardTheme(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      foregroundColor: textColor,
      elevation: 0,
    ),
    textTheme: GoogleFonts.tajawalTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    ),
  );
}
