import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/app_exception.dart';

String handleAppError(dynamic error) {
  // Handle AppException (type-safe custom exceptions)
  if (error is AppException) {
    return error.message;
  }

  // Handle generic exceptions
  if (error is Exception) {
    return error.toString().replaceAll('Exception: ', '');
  }

  // Handle generic errors
  return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
        textDirection: TextDirection.rtl,
      ),
      backgroundColor: AppColors.warningColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
        textDirection: TextDirection.rtl,
      ),
      backgroundColor: AppColors.successColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
