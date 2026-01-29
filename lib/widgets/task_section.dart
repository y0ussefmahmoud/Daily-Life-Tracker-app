import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';
import 'custom_checkbox.dart';
import 'section_header.dart';

class TaskSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Task> tasks;
  final Function(String) onTaskToggle;

  const TaskSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.tasks,
    required this.onTaskToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          SectionHeader(
            title: title,
            icon: icon,
            iconColor: iconColor,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray900.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: tasks.asMap().entries.map((entry) {
                final index = entry.key;
                final task = entry.value;
                final isLast = index == tasks.length - 1;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (task.id == null) return;
                        onTaskToggle(task.id!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Row(
                          children: [
                            CustomCheckbox(
                              value: task.isCompleted,
                              onChanged: (value) {
                                if (task.id == null) return;
                                onTaskToggle(task.id!);
                              },
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Icon(
                              task.icon,
                              size: AppSizes.iconDefault,
                              color: isDark ? AppColors.textLight : AppColors.textPrimary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                task.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                                  fontWeight: AppTypography.medium,
                                  decoration: task.isCompleted 
                                      ? TextDecoration.lineThrough 
                                      : TextDecoration.none,
                                  decorationColor: isDark ? AppColors.textLight : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        thickness: 1,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
