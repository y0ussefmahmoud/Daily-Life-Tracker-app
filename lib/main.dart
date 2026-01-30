import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/project_provider.dart';
import 'providers/water_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/achievements_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/subtask_provider.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for localization
  await initializeDateFormatting();
  
  // Initialize Supabase using the service
  await SupabaseService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // المرحلة الأولى - Providers المستقلة
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SubTaskProvider()),
        
        // المرحلة الثانية - Providers مع Dependencies بسيطة
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
        
        // المرحلة الثالثة - StatsProvider مع Dependencies متعددة
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
        
        // المرحلة الرابعة - ProfileProvider
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Daily Life Tracker',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryColor,
                secondary: AppColors.secondaryColor,
                surface: AppColors.cardLight,
                background: AppColors.backgroundLight,
                error: AppColors.warningColor,
                onPrimary: AppColors.textLight,
                onSecondary: AppColors.textLight,
                onSurface: AppColors.textPrimary,
                onBackground: AppColors.textPrimary,
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
                backgroundColor: AppColors.cardLight,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: AppColors.cardLight,
                selectedItemColor: AppColors.primaryColor,
                unselectedItemColor: AppColors.textSecondary,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.dark(
                primary: AppColors.primaryColor,
                secondary: AppColors.secondaryColor,
                surface: AppColors.cardDark,
                background: AppColors.backgroundDark,
                error: AppColors.warningColor,
                onPrimary: AppColors.textLight,
                onSecondary: AppColors.textLight,
                onSurface: AppColors.textLight,
                onBackground: AppColors.textLight,
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
                backgroundColor: AppColors.cardDark,
                foregroundColor: AppColors.textLight,
                elevation: 0,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: AppColors.cardDark,
                selectedItemColor: AppColors.primaryColor,
                unselectedItemColor: AppColors.gray400,
              ),
            ),
            themeMode: settingsProvider.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
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
