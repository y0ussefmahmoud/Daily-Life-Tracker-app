import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ProgressBarWidget extends StatelessWidget {
  final String label;
  final double progress;

  const ProgressBarWidget({
    Key? key,
    required this.label,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentage = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentage%',
                style: GoogleFonts.robotoMono(
                  fontSize: AppTypography.caption,
                  fontWeight: AppTypography.medium,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: AppTypography.body,
                  fontWeight: AppTypography.medium,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray700 : AppColors.gray200,
              borderRadius: BorderRadius.circular(AppBorderRadius.full),
            ),
            child: TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: progress),
              builder: (context, value, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerRight,
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
