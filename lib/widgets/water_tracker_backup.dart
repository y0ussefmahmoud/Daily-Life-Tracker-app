import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import 'skeleton_loader.dart';

class WaterTracker extends StatefulWidget {
  const WaterTracker({Key? key}) : super(key: key);

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Auto-initialize WaterProvider if not already initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final provider = Provider.of<WaterProvider>(context, listen: false);
        if (!provider.isInitialized) {
          provider.initialize();
        }
      } catch (e) {
        // Handle initialization error silently or show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تهيئة متتبع المياه'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _WaterTrackerWrapper(
      child: Consumer<WaterProvider>(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.textLight,
                      elevation: 2,
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
              
              // Achievement celebration when target is reached
              if (provider.currentCups >= provider.targetCups)
                AnimatedContainer(
                  duration: AppConstants.mediumAnimation,
                  curve: Curves.elasticOut,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.2),
                        AppColors.secondaryColor.withOpacity(0.2),
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

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isFilled ? 1.0 : _scaleAnimation.value,
          child: Tooltip(
            message: isFilled ? 'تم' : 'اضغط لإضافة كوب ماء',
            child: InkWell(
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              splashColor: AppColors.primaryColor.withOpacity(0.3),
              highlightColor: AppColors.primaryColor.withOpacity(0.1),
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              onTap: () async {
                if (!isFilled) {
                  HapticFeedback.mediumImpact();
                  
                  // Trigger bounce animation
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  
                  try {
                    await provider.addCup();
                  } catch (e) {
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
                  gradient: isFilled 
                      ? LinearGradient(
                          colors: [AppColors.primaryColor, AppColors.secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isFilled 
                      ? null
                      : isDark ? AppColors.gray800 : AppColors.gray200,
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  border: Border.all(
                    color: isFilled 
                        ? Colors.transparent
                        : isDark 
                            ? AppColors.primaryColor.withOpacity(0.3)
                            : AppColors.primaryColor.withOpacity(0.4),
                    width: 1,
                  ),
                  boxShadow: isFilled && isDark
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isFilled ? Icons.check : Icons.add,
                  size: 16,
                  color: isFilled 
                      ? AppColors.textLight 
                      : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6) ?? AppColors.primaryColor.withOpacity(0.6),
                ),
              ),
            ),
          ),
        );
      },
    ),
);
  }
}

class _WaterTrackerWrapper extends StatelessWidget {
  final Widget child;
  
  const _WaterTrackerWrapper({required this.child});
  
  @override
  Widget build(BuildContext context) {
    try {
      // Try to access existing provider
      context.read<WaterProvider>();
      return child;
    } catch (e) {
      // Provider doesn't exist, create a new one
      return ChangeNotifierProvider(
        create: (_) => WaterProvider()..initialize(),
        child: child,
      );
    }
  }
}
