import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryColor.withOpacity(0.1)
              : isDark 
                  ? AppColors.gray800
                  : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryColor
                : isDark 
                    ? AppColors.gray600
                    : AppColors.gray300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSizes.iconSmall,
              color: isSelected 
                  ? AppColors.primaryColor
                  : isDark 
                      ? AppColors.gray300
                      : AppColors.gray600,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: AppTypography.caption,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? AppColors.primaryColor
                    : isDark 
                        ? AppColors.gray300
                        : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
