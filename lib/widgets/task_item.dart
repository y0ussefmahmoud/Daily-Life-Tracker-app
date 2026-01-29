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
    Key? key,
    required this.task,
    required this.onToggle,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = task.priority.getPriorityColor();
    
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
                      ? AppColors.gray800.withOpacity(0.5)
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
                      _buildPriorityBadge(priorityColor),
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

  Widget _buildPriorityBadge(Color priorityColor) {
    String priorityText;
    Color backgroundColor;
    Color textColor;
    
    switch (task.priority) {
      case TaskPriority.high:
        priorityText = 'عالي';
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade600;
        break;
      case TaskPriority.medium:
        priorityText = 'متوسط';
        backgroundColor = Colors.yellow.shade100;
        textColor = Colors.yellow.shade700;
        break;
      case TaskPriority.low:
        priorityText = 'منخفض';
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade600;
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
