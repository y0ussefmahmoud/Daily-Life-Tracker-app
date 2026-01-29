import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import '../utils/constants.dart';
import '../utils/app_exception.dart';

String handleSupabaseError(dynamic error) {
  // Handle AppException (type-safe custom exceptions)
  if (error is AppException) {
    return error.message;
  }

  // Handle AuthException
  if (error is AuthException) {
    switch (error.statusCode) {
      case '400':
        if (error.message.contains('Invalid login credentials')) {
          return AppStrings.errorInvalidCredentials;
        }
        if (error.message.contains('User already registered')) {
          return AppStrings.errorEmailAlreadyExists;
        }
        return AppStrings.errorAuthentication;
      case '401':
        return AppStrings.errorSessionExpired;
      case '422':
        return AppStrings.errorWeakPassword;
      default:
        return AppStrings.errorAuthentication;
    }
  }

  // Handle PostgrestException
  if (error is PostgrestException) {
    final message = error.message.toLowerCase();
    
    if (message.contains('jwt') || message.contains('token')) {
      return AppStrings.errorSessionExpired;
    }
    if (message.contains('network') || message.contains('connection')) {
      return AppStrings.errorNetworkConnection;
    }
    if (message.contains('timeout')) {
      return AppStrings.errorTimeout;
    }
    if (message.contains('not found')) {
      return AppStrings.errorLoadingReports;
    }
    
    return '${AppStrings.error}: ${error.message}';
  }

  // Handle custom Exception messages from SupabaseService
  if (error is Exception) {
    final errorString = error.toString();
    
    // Extract clean message by removing 'Exception: ' prefix if present
    final cleanMessage = errorString.startsWith('Exception: ') 
        ? errorString.substring(10) // Remove 'Exception: ' (10 characters)
        : errorString;
    
    // Check if clean error message already matches an AppStrings error
    if (cleanMessage == AppStrings.errorNoInternet ||
        cleanMessage == AppStrings.errorTimeout ||
        cleanMessage.startsWith(AppStrings.errorDatabaseConnection)) {
      return cleanMessage;
    }
    
    // Handle network errors using cleanMessage for keyword checks
    if (cleanMessage.toLowerCase().contains('socket') || 
        cleanMessage.toLowerCase().contains('network')) {
      return AppStrings.errorNoInternet;
    }
    if (cleanMessage.toLowerCase().contains('timeout')) {
      return AppStrings.errorTimeout;
    }
  }

  return AppStrings.errorUnexpected;
}

void showErrorSnackbar(BuildContext context, String message, {VoidCallback? onRetry}) {
  final theme = Theme.of(context);
  final snackBar = SnackBar(
    backgroundColor: theme.colorScheme.error,
    content: Text(
      message,
      style: GoogleFonts.tajawal(fontSize: AppTypography.body),
    ),
    action: onRetry == null
        ? null
        : SnackBarAction(
            label: AppStrings.errorRetry,
            onPressed: onRetry,
            textColor: Colors.white,
          ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String handleProviderError(dynamic error, String context) {
  if (error is PostgrestException) {
    return handleSupabaseError(error);
  }
  
  // Context-specific errors
  switch (context) {
    case 'tasks':
      return AppStrings.errorLoadingTasks;
    case 'projects':
      return AppStrings.errorLoadingProjects;
    case 'profile':
      return AppStrings.errorLoadingProfile;
    case 'water':
      return AppStrings.errorLoadingWater;
    case 'achievements':
      return AppStrings.errorLoadingAchievements;
    default:
      return AppStrings.error;
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.error.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: AppTypography.body,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(
                  AppStrings.errorRetry,
                  style: GoogleFonts.tajawal(
                    fontSize: AppTypography.body,
                    fontWeight: AppTypography.medium,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void showErrorDialog(BuildContext context, String title, String message, {VoidCallback? onRetry}) {
  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: ui.TextDirection.rtl,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: AppTypography.title,
                fontWeight: AppTypography.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.tajawal(fontSize: AppTypography.body),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(
                AppStrings.errorRetry,
                style: GoogleFonts.tajawal(
                  fontSize: AppTypography.body,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.tajawal(fontSize: AppTypography.body),
            ),
          ),
        ],
      ),
    ),
  );
}
