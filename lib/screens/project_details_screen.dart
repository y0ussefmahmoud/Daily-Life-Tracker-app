import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project_model.dart';
import '../models/subtask_model.dart';
import '../providers/subtask_provider.dart';
import '../utils/constants.dart';
import '../widgets/task_item.dart';
import '../widgets/conic_progress_indicator.dart';
import '../widgets/add_subtask_dialog.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load subtasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.project.id != null) {
        context.read<SubTaskProvider>().loadSubTasks(widget.project.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Consumer<SubTaskProvider>(
          builder: (context, subTaskProvider, child) {
            if (subTaskProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                if (widget.project.id != null) {
                  await subTaskProvider.loadSubTasks(widget.project.id!);
                }
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 80), // Top padding for AppBar
                    _buildProjectHeader(context, subTaskProvider),
                    SizedBox(height: AppSpacing.lg),
                    _buildWeeklyFocusCard(context),
                    SizedBox(height: AppSpacing.lg),
                    _buildInProgressTasksSection(context, subTaskProvider),
                    SizedBox(height: AppSpacing.lg),
                    _buildCompletedTasksSection(context, subTaskProvider),
                    SizedBox(height: 100), // Bottom padding for FAB
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: _buildFloatingActionButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'تفاصيل المشروع',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.more_horiz, color: theme.iconTheme.color),
          onPressed: () => _showMoreOptions(context),
        ),
      ],
    );
  }

  Widget _buildProjectHeader(BuildContext context, SubTaskProvider subTaskProvider) {
    final theme = Theme.of(context);
    final completionPercentage = subTaskProvider.completionPercentage;
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? AppColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark 
                        ? AppColors.textLight
                        : AppColors.textPrimary,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  textDirection: TextDirection.rtl,
                  children: widget.project.techStack.map((tech) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.small),
                      ),
                      child: Text(
                        tech,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Hero(
            tag: 'project_${widget.project.id ?? 'new'}',
            child: ConicProgressIndicator(
              progress: completionPercentage,
              size: 80,
              strokeWidth: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyFocusCard(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.project.weeklyFocus == null) {
      return SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppBorderRadius.default_),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            Icons.bolt,
            color: theme.primaryColor,
            size: 24,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التركيز الأسبوعي',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      onPressed: () {
                        // TODO: Edit weekly focus functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('تعديل التركيز الأسبوعي - قيد التطوير')),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  widget.project.weeklyFocus!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray600,
                    height: 1.5,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressTasksSection(BuildContext context, SubTaskProvider subTaskProvider) {
    final theme = Theme.of(context);
    final inProgressTasks = subTaskProvider.inProgressTasks;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'قيد التنفيذ',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark 
                    ? AppColors.textLight
                    : AppColors.textPrimary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Text(
                '${inProgressTasks.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        if (inProgressTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? AppColors.gray800
                  : AppColors.gray50,
              borderRadius: BorderRadius.circular(AppBorderRadius.default_),
              border: Border.all(
                color: theme.brightness == Brightness.dark 
                    ? AppColors.gray700
                    : AppColors.gray200,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppColors.gray400,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'لا توجد مهام قيد التنفيذ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          )
        else
          ...inProgressTasks.map((task) => TaskItem(
            task: task,
            onToggle: () => subTaskProvider.toggleSubTaskCompletion(task.id!),
            onLongPress: () => _showTaskOptions(context, task),
          )).toList(),
      ],
    );
  }

  Widget _buildCompletedTasksSection(BuildContext context, SubTaskProvider subTaskProvider) {
    final theme = Theme.of(context);
    final completedTasks = subTaskProvider.completedTasks;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'مكتمل',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark 
                    ? AppColors.textLight
                    : AppColors.textPrimary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Text(
                '${completedTasks.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        if (completedTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? AppColors.gray800
                  : AppColors.gray50,
              borderRadius: BorderRadius.circular(AppBorderRadius.default_),
              border: Border.all(
                color: theme.brightness == Brightness.dark 
                    ? AppColors.gray700
                    : AppColors.gray200,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.pending_outlined,
                  size: 48,
                  color: AppColors.gray400,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'لا توجد مهام مكتملة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          )
        else
          ...completedTasks.map((task) => TaskItem(
            task: task,
            onToggle: () => subTaskProvider.toggleSubTaskCompletion(task.id!),
            onLongPress: () => _showTaskOptions(context, task),
          )).toList(),
        if (completedTasks.isNotEmpty)
          SizedBox(height: AppSpacing.md),
        if (completedTasks.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.default_),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  Icons.celebration,
                  color: Colors.green,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'أحسنت! لقد أكملت ${completedTasks.length} مهام',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          if (widget.project.id != null) {
            showDialog(
              context: context,
              builder: (context) => AddSubTaskDialog(projectId: widget.project.id!),
            );
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
        elevation: 4,
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.large)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              title: Text('تعديل المشروع', textDirection: TextDirection.rtl),
              onTap: () {
                Navigator.pop(context);
                // TODO: Edit project functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.add, color: Theme.of(context).primaryColor),
              title: Text('إضافة مهمة فرعية', textDirection: TextDirection.rtl),
              onTap: () {
                Navigator.pop(context);
                if (widget.project.id != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AddSubTaskDialog(projectId: widget.project.id!),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('حذف المشروع', textDirection: TextDirection.rtl),
              onTap: () {
                Navigator.pop(context);
                // TODO: Delete project functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskOptions(BuildContext context, Subtask task) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.large)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              title: Text('تعديل المهمة', textDirection: TextDirection.rtl),
              onTap: () {
                Navigator.pop(context);
                // TODO: Edit task functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.content_copy, color: Theme.of(context).primaryColor),
              title: Text('نسخ المهمة', textDirection: TextDirection.rtl),
              onTap: () {
                Navigator.pop(context);
                // TODO: Duplicate task functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('حذف المهمة', textDirection: TextDirection.rtl),
              onTap: () {
                Navigator.pop(context);
                // TODO: Delete task functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
