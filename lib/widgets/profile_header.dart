import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'custom_circular_progress.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String date;
  final double progress;

  const ProfileHeader({
    Key? key,
    required this.userName,
    required this.date,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'مرحباً، $userName',
                  style: GoogleFonts.tajawal(
                    fontSize: AppTypography.heading,
                    fontWeight: AppTypography.bold,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  date,
                  style: GoogleFonts.tajawal(
                    fontSize: AppTypography.body,
                    fontWeight: AppTypography.medium,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          CustomCircularProgress(
            progress: progress,
            size: 80,
            strokeWidth: 6,
            progressColor: AppColors.primaryColor,
            backgroundColor: isDark ? AppColors.gray700 : AppColors.gray200,
            percentageStyle: GoogleFonts.robotoMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
