import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class MonthlyProgressWidget extends StatelessWidget {
  final double progress;
  final String message;

  const MonthlyProgressWidget({
    Key? key,
    required this.progress,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي إنجاز الشهر',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                NumberFormat('###').format((progress * 100).round()) + '%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray700 : AppColors.gray200,
              borderRadius: BorderRadius.circular(AppBorderRadius.full),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Motivational Message
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.gray500,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
