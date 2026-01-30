import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class DailySummaryCard extends StatelessWidget {
  final String message;

  const DailySummaryCard({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.primaryColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.cardDark : AppColors.primaryColor).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Icon(
              Icons.format_quote,
              size: 48,
              color: AppColors.textLight.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ملخص اليوم',
                style: GoogleFonts.tajawal(
                  fontSize: AppTypography.caption,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: GoogleFonts.tajawal(
                  fontSize: AppTypography.title,
                  fontWeight: AppTypography.medium,
                  color: AppColors.textLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
