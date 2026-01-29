import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = this.iconColor ?? theme.primaryColor;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppSizes.iconDefault,
                color: iconColor,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.textTheme.titleLarge?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
