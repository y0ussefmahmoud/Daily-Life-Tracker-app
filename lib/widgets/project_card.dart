import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_circular_progress.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;

  const ProjectCard({
    Key? key,
    required this.project,
    this.onTap,
    this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Circle
                    Hero(
                      tag: 'project_${project.id}',
                      child: CustomCircularProgress(
                        progress: project.progress,
                        size: 64,
                        strokeWidth: 4,
                        progressColor: project.getProgressColor(),
                        showPercentage: true,
                        percentageStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: project.getProgressColor(),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    
                    // Project Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          
                          // Tech Stack Tags
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: project.techStack.map((tech) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTechColor(tech, isDark: isDark),
                                  borderRadius: BorderRadius.circular(AppBorderRadius.default_),
                                ),
                                child: Text(
                                  tech,
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    // More Options Button
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onMorePressed?.call();
                      },
                      icon: const Icon(Icons.more_vert),
                      iconSize: AppSizes.iconSmall,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Bottom Section with Divider
                Container(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Status Icon and Message
                      Icon(
                        project.progress > 0.6 ? Icons.trending_up : Icons.warning,
                        size: 16,
                        color: project.getProgressColor(),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        project.statusMessage ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: project.getProgressColor(),
                          fontSize: 12,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Schedule or Deadline Info
                      if (project.status == ProjectStatus.active) ...[
                        Icon(
                          project.deadline != null ? Icons.event : Icons.schedule,
                          size: 16,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          project.deadline != null
                              ? DateFormat('d MMM').format(project.deadline!)
                              : '${project.weeklyHours} ساعة/أسبوع',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  Color _getTechColor(String tech, {bool isDark = false}) {
    switch (tech.toLowerCase()) {
      case 'flutter':
        return isDark ? AppColors.primaryColor.withOpacity(0.9) : AppColors.primaryColor;
      case 'firebase':
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFFFA726);
      case 'healthtech':
        return isDark ? AppColors.successColor.withOpacity(0.9) : AppColors.successColor;
      case 'web':
        return isDark ? AppColors.warningColor.withOpacity(0.9) : AppColors.warningColor;
      case 'html':
        return isDark ? const Color(0xFFEF6C00) : const Color(0xFFE34C26);
      default:
        return isDark ? AppColors.gray500 : AppColors.gray600;
    }
  }
}
