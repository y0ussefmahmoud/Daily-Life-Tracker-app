import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stats_model.dart';
import '../utils/constants.dart';

class WeeklyChart extends StatefulWidget {
  final List<WeeklyStats> data;

  const WeeklyChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  int? _activeIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasData = widget.data.any((stat) => stat.percentage > 0);

    if (!hasData) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          color: isDark ? AppColors.gray800 : AppColors.gray100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_outlined,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'لا توجد بيانات لهذا الأسبوع',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'ابدأ بإكمال المهام لرؤية تقدمك',
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widget.data.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          final isActive = _activeIndex == index;
          final barHeightFactor = (stat.percentage / 100).clamp(0.0, 1.0);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Tooltip(
                          message: '${stat.dayName}: ${stat.percentage.toStringAsFixed(0)}%',
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeIndex = _activeIndex == index ? null : index;
                              });
                            },
                            child: AnimatedScale(
                              scale: isActive ? 1.05 : 1.0,
                              duration: AppConstants.shortAnimation,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(AppBorderRadius.lg),
                                    topRight: Radius.circular(AppBorderRadius.lg),
                                  ),
                                  color: isDark ? AppColors.gray800 : AppColors.gray100,
                                ),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AnimatedContainer(
                                    duration: AppConstants.mediumAnimation,
                                    curve: Curves.easeInOut,
                                    width: double.infinity,
                                    height: constraints.maxHeight * barHeightFactor,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(AppBorderRadius.lg),
                                        topRight: Radius.circular(AppBorderRadius.lg),
                                      ),
                                      color: stat.isToday
                                          ? AppColors.successColor
                                          : AppColors.successColor.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    stat.dayName,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: stat.isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
