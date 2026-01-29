import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SettingsListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showBorder;

  const SettingsListItem({
    Key? key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: AppSizes.iconDefault,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppTypography.body,
                  fontWeight: AppTypography.medium,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons.chevron_left,
                color: AppColors.gray400,
                size: AppSizes.iconDefault,
              ),
          ],
        ),
      ),
    );
  }
}
