import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import 'skeleton_loader.dart';

class WaterTracker extends StatelessWidget {
  const WaterTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonLoader(height: 20, width: 120),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(
                    8,
                    (index) => Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: SkeletonLoader(
                        width: 32,
                        height: 32,
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: AppColors.primaryColor,
                      size: AppSizes.iconDefault,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'متتبع المياه',
                      style: GoogleFonts.tajawal(
                        fontSize: AppTypography.title,
                        fontWeight: AppTypography.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'حدث خطأ أثناء تحميل بيانات المياه',
                  style: GoogleFonts.tajawal(
                    fontSize: AppTypography.caption,
                    fontWeight: AppTypography.medium,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      provider.initialize();
                    },
                    child: Text(
                      'إعادة المحاولة',
                      style: GoogleFonts.tajawal(
                        fontSize: AppTypography.caption,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${provider.currentCups} / ${provider.targetCups} أكواب',
                    style: GoogleFonts.robotoMono(
                      fontSize: AppTypography.caption,
                      fontWeight: AppTypography.medium,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: AppColors.primaryColor,
                        size: AppSizes.iconDefault,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'متتبع المياه',
                        style: GoogleFonts.tajawal(
                          fontSize: AppTypography.title,
                          fontWeight: AppTypography.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(
                  provider.targetCups,
                  (index) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: _buildCupIndicator(context, index, provider),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCupIndicator(BuildContext context, int index, WaterProvider provider) {
    final isFilled = index < provider.currentCups;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedScale(
      scale: isFilled ? 1.0 : 0.95,
      duration: Duration(milliseconds: 200),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        splashColor: AppColors.primaryColor.withOpacity(0.3),
        highlightColor: AppColors.primaryColor.withOpacity(0.1),
        onTap: () async {
          if (!isFilled) {
            HapticFeedback.lightImpact();
            await provider.addCup();
          }
        },
        child: AnimatedContainer(
          duration: AppConstants.mediumAnimation,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isFilled 
                ? AppColors.primaryColor 
                : isDark ? AppColors.gray700 : AppColors.gray200,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(
              color: isFilled 
                  ? AppColors.primaryColor 
                  : AppColors.primaryColor.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Icon(
            isFilled ? Icons.check : Icons.add,
            size: 16,
            color: isFilled 
                ? AppColors.textLight 
                : AppColors.primaryColor.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
