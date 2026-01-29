import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProfileStatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileStatsCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: AppSizes.iconLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.small,
                color: AppColors.primaryColor.withOpacity(0.7),
                fontWeight: AppTypography.medium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: AppTypography.titleLarge,
                fontWeight: AppTypography.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
