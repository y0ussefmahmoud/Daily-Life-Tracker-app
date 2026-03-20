import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subtask_model.dart';
import '../utils/constants.dart';
import 'custom_checkbox.dart';

class TaskItem extends StatelessWidget {
  final Subtask task;
  final VoidCallback onToggle;
  final VoidCallback? onLongPress;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = task.priority.getPriorityColor();
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      onLongPress: onLongPress,
      child: AnimatedScale(
        scale: task.isCompleted ? 0.98 : 1.0,
        duration: Duration(milliseconds: 150),
        child: Opacity(
          opacity: task.isCompleted ? 0.75 : 1.0,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            margin: EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: task.isCompleted 
                  ? (theme.brightness == Brightness.dark 
                      ? AppColors.gray800.withValues(alpha: 0.5)
                      : AppColors.gray50)
                  : (theme.brightness == Brightness.dark 
                      ? AppColors.gray800
                      : Colors.white),
              borderRadius: BorderRadius.circular(AppBorderRadius.default_),
              border: Border.all(
                color: theme.brightness == Brightness.dark 
                    ? AppColors.gray700
                    : AppColors.gray200,
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                CustomCheckbox(
                  value: task.isCompleted,
                  onChanged: (value) => onToggle(),
                  activeColor: theme.primaryColor,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                          color: task.isCompleted 
                              ? AppColors.gray500
                              : (theme.brightness == Brightness.dark 
                                  ? AppColors.textLight
                                  : AppColors.textPrimary),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      _buildPriorityBadge(priorityColor, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(Color priorityColor, bool isDark) {
    String priorityText;
    Color backgroundColor;
    Color textColor;
    
    switch (task.priority) {
      case SubtaskPriority.high:
        priorityText = 'عالي';
        backgroundColor = isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade100;
        textColor = isDark ? Colors.red.shade300 : Colors.red.shade700;
        break;
      case SubtaskPriority.medium:
        priorityText = 'متوسط';
        backgroundColor = isDark ? Colors.orange.withValues(alpha: 0.2) : Colors.yellow.shade100;
        textColor = isDark ? Colors.orange.shade300 : Colors.orange.shade700;
        break;
      case SubtaskPriority.low:
        priorityText = 'منخفض';
        backgroundColor = isDark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.shade100;
        textColor = isDark ? Colors.blue.shade300 : Colors.blue.shade700;
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Text(
        priorityText.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
