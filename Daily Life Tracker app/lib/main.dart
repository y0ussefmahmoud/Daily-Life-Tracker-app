import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/achievements_screen.dart';
import 'providers/task_provider.dart';
import 'providers/project_provider.dart';
import 'providers/water_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/achievements_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'services/local_database_service.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for localization
  await initializeDateFormatting();
  
  // Initialize local storage before providers are used
  try {
    await LocalDatabaseService().init();
  } catch (e) {
    debugPrint('Database initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Daily Life Tracker',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryColor,
                secondary: AppColors.secondaryColor,
                surface: AppColors.cardLight,
                error: AppColors.warningColor,
                onPrimary: AppColors.textLight,
                onSecondary: AppColors.textLight,
                onSurface: AppColors.textPrimary,
              ),
              scaffoldBackgroundColor: AppColors.backgroundLight,
              cardColor: AppColors.cardLight,
              dividerColor: AppColors.borderLight,
              textTheme: GoogleFonts.tajawalTextTheme(
                ThemeData.light().textTheme,
              ).apply(
                bodyColor: AppColors.textPrimary,
                displayColor: AppColors.textPrimary,
              ),
              iconTheme: IconThemeData(
                color: AppColors.textPrimary,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                titleTextStyle: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: AppColors.cardLight,
                selectedItemColor: AppColors.primaryColor,
                unselectedItemColor: AppColors.gray500,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              cardTheme: CardThemeData(
                color: AppColors.cardLight,
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.dark(
                primary: AppColors.primaryColor,
                secondary: AppColors.secondaryColor,
                surface: AppColors.cardDark,
                error: AppColors.warningColor,
                onPrimary: AppColors.textLight,
                onSecondary: AppColors.textLight,
                onSurface: AppColors.textLight,
              ),
              scaffoldBackgroundColor: AppColors.backgroundDark,
              cardColor: AppColors.cardDark,
              dividerColor: AppColors.borderDark,
              textTheme: GoogleFonts.tajawalTextTheme(
                ThemeData.dark().textTheme,
              ).apply(
                bodyColor: AppColors.textLight,
                displayColor: AppColors.textLight,
              ),
              iconTheme: IconThemeData(
                color: AppColors.textLight,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                titleTextStyle: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: AppColors.cardDark,
                selectedItemColor: AppColors.primaryColor,
                unselectedItemColor: AppColors.darkTextSecondary,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
                unselectedLabelStyle: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkTextSecondary,
                ),
              ),
              cardTheme: CardThemeData(
                color: AppColors.cardDark,
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            themeMode: settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const HomeScreen(),
            routes: {
              '/tasks': (context) => const TasksScreen(),
              '/projects': (context) => const ProjectsScreen(),
              '/achievements': (context) => const AchievementsScreen(),
            },
            // Localization setup
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'), // English
              Locale('ar', 'SA'), // Arabic
            ],
            locale: const Locale('ar', 'SA'), // Default to Arabic
          );
        },
      ),
    );
  }
}
