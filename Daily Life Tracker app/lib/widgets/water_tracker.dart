import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import 'skeleton_loader.dart';

class WaterTracker extends StatefulWidget {
  const WaterTracker({super.key});

  @override
  WaterTrackerState createState() => WaterTrackerState();
}

class WaterTrackerState extends State<WaterTracker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
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
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
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
                  provider.error ?? 'حدث خطأ أثناء تحميل بيانات المياه',
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
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.initialize();
                    },
                    icon: Icon(Icons.refresh, size: 16),
                    label: Text(
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

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final currentCups = provider.currentCups;
        final targetCups = provider.targetCups;
        final progress = currentCups / targetCups;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.1),
                AppColors.secondaryColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Header
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
              
              // Progress info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$currentCups من $targetCups أكواب',
                    style: GoogleFonts.tajawal(
                      fontSize: AppTypography.body,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.tajawal(
                      fontSize: AppTypography.body,
                      fontWeight: AppTypography.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              
              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gray700 : AppColors.gray200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerRight,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Cups grid
              Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: List.generate(
                  targetCups,
                  (index) => GestureDetector(
                    onTap: () async {
                      if (index < currentCups) return;

                      _animationController.forward().then((_) {
                        _animationController.reverse();
                      });

                      try {
                        await provider.addCup();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('حدث خطأ أثناء إضافة كوب الماء'),
                              backgroundColor: Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: AppConstants.mediumAnimation,
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: index < currentCups
                            ? LinearGradient(
                                colors: [AppColors.primaryColor, AppColors.secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: index < currentCups
                            ? null
                            : isDark ? AppColors.gray800 : AppColors.gray200,
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        border: Border.all(
                          color: index < currentCups
                              ? Colors.transparent
                              : isDark
                                  ? AppColors.primaryColor.withValues(alpha: 0.3)
                                  : AppColors.primaryColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        boxShadow: index < currentCups && isDark
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        index < currentCups ? Icons.check : Icons.add,
                        size: 16,
                        color: index < currentCups
                            ? AppColors.textLight
                            : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6) ?? AppColors.primaryColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Success message
              if (progress >= 1.0) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.2),
                        AppColors.secondaryColor.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.secondaryColor],
                    ).createShader(bounds),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: Colors.white, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'ممتاز! لقد حققت هدفك اليومي 🎉',
                          style: GoogleFonts.tajawal(
                            fontSize: AppTypography.caption,
                            fontWeight: AppTypography.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
