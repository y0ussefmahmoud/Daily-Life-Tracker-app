import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/water_provider.dart';
import '../providers/project_provider.dart';
import '../utils/error_handler.dart';
import '../utils/constants.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';
import 'auth/login_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _errorMessage;
  bool _hasError = false;
  bool _isRetrying = false;
  IconData _errorIcon = Icons.error_outline;
  StreamSubscription<bool>? _connectivitySubscription;
  @override
  void initState() {
    super.initState();
    _initializeApp();
    _startConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _startConnectivityListener() {
    _connectivitySubscription = SupabaseService.connectivityStream.listen((isOnline) {
      if (isOnline && _hasError && _errorMessage == AppStrings.errorNoInternet) {
        // Auto-retry when connection is restored
        _initializeApp();
      }
    });
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.initialize()
          .timeout(AppConstants.longTimeout);

      if (authProvider.isAuthenticated) {
        await Future.wait([
          Provider.of<TaskProvider>(context, listen: false).initialize()
              .timeout(AppConstants.mediumTimeout),
          Provider.of<WaterProvider>(context, listen: false).initialize()
              .timeout(AppConstants.mediumTimeout),
          Provider.of<ProjectProvider>(context, listen: false).loadProjects()
              .timeout(AppConstants.mediumTimeout),
        ]);
      }
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => authProvider.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen(),
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = AppStrings.errorTimeout;
          _errorIcon = Icons.access_time;
          _isRetrying = false;
        });
      }
    } on SocketException {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = AppStrings.errorNoInternet;
          _errorIcon = Icons.wifi_off;
          _isRetrying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = handleSupabaseError(e);
          _errorIcon = _getIconForError(e);
          _isRetrying = false;
        });
      }
    }
  }

  IconData _getIconForError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('internet')) {
      return Icons.wifi_off;
    }
    if (errorString.contains('timeout')) {
      return Icons.access_time;
    }
    if (errorString.contains('auth')) {
      return Icons.lock;
    }
    return Icons.error_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            ],
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: AppConstants.mediumAnimation,
            child: _hasError
                ? ErrorStateWidget(
                    key: ValueKey(_errorMessage),
                    message: _errorMessage ?? AppStrings.errorInitialization,
                    icon: _errorIcon,
                    subtitle: _getSubtitleForError(),
                    onRetry: () {
                      setState(() {
                        _hasError = false;
                        _errorMessage = null;
                        _isRetrying = true;
                      });
                      _initializeApp();
                    },
                  )
                : FadeTransition(
                    opacity: const AlwaysStoppedAnimation(1.0),
                    child: Column(
                      key: const ValueKey('loading'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'app_logo',
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.primaryColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: AppConstants.shortAnimation,
                              child: _isRetrying
                                  ? SizedBox(
                                      key: const ValueKey('retrying_indicator'),
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.primaryColor,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      key: const ValueKey('logo'),
                                      Icons.track_changes,
                                      size: 60,
                                      color: AppColors.primaryColor,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AnimatedSwitcher(
                          duration: AppConstants.shortAnimation,
                          child: _isRetrying
                              ? Column(
                                  key: const ValueKey('retrying_text'),
                                  children: [
                                    Text(
                                      AppStrings.errorRetrying,
                                      style: GoogleFonts.tajawal(
                                        fontSize: AppTypography.title,
                                        fontWeight: AppTypography.bold,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      AppStrings.errorCheckConnection,
                                      style: GoogleFonts.tajawal(
                                        fontSize: AppTypography.caption,
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : Column(
                                  key: const ValueKey('loading_text'),
                                  children: [
                                    Text(
                                      AppStrings.appName,
                                      style: GoogleFonts.tajawal(
                                        fontSize: AppTypography.heading,
                                        fontWeight: AppTypography.bold,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      AppStrings.loading,
                                      style: GoogleFonts.tajawal(
                                        fontSize: AppTypography.body,
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String? _getSubtitleForError() {
    if (_errorMessage == AppStrings.errorNoInternet) {
      return AppStrings.errorCheckConnection;
    }
    if (_errorMessage == AppStrings.errorTimeout) {
      return 'العملية استغرقت وقتاً طويلاً، حاول مرة أخرى';
    }
    if (_errorMessage?.contains('المصادقة') == true) {
      return 'يرجى التحقق من بيانات الدخول والمحاولة مرة أخرى';
    }
    return AppStrings.errorTryAgain;
  }
}
