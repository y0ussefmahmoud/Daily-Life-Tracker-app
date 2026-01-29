import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stats_model.dart';
import '../utils/constants.dart';

class TimeDistributionItem extends StatelessWidget {
  final TimeDistribution item;

  const TimeDistributionItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Icon(
              item.icon,
              color: item.color,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              item.category,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const Spacer(),
            Text(
              '${item.hours.toInt()}h',
              style: GoogleFonts.robotoMono(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: isDark ? AppColors.gray800 : AppColors.gray100,
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedContainer(
              duration: AppConstants.mediumAnimation,
              width: (item.percentage / 100.0) * MediaQuery.of(context).size.width * 0.8,
              height: 10,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
