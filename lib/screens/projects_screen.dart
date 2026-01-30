import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../widgets/project_card.dart';
import '../widgets/paused_project_card.dart';
import '../widgets/monthly_progress_widget.dart';
import '../widgets/skeleton_loader.dart';
import 'project_details_screen.dart';
import 'add_screen.dart';

class ProjectsScreen extends StatefulWidget {
  final bool showScaffold;

  const ProjectsScreen({
    Key? key,
    this.showScaffold = true,
  }) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    // Load projects when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget bodyContent = Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        final activeProjects = projectProvider.activeProjects;
        final pausedProjects = projectProvider.pausedProjects;

        // Check for error state
        if (projectProvider.error != null) {
          return ErrorStateWidget(
            message: handleProviderError(projectProvider.error, 'projects'),
            subtitle: 'لا يمكن عرض المشاريع حالياً',
            icon: Icons.work_off,
            onRetry: () => projectProvider.loadProjects(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            try {
              await projectProvider.refreshProjects();
            } catch (error) {
              showErrorSnackbar(context, handleSupabaseError(error));
            }
          },
          child: projectProvider.isLoading
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Enable refresh even when loading
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Motivational Quote Skeleton
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: SkeletonLoader(height: 20),
                      ),
                      
                      // Active Projects Section Skeleton
                      SkeletonLoader(height: 18, width: 100),
                      const SizedBox(height: AppSpacing.md),
                      SkeletonList(itemCount: 2),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Paused Projects Section Skeleton
                      SkeletonLoader(height: 18, width: 120),
                      const SizedBox(height: AppSpacing.md),
                      SkeletonList(itemCount: 1),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Monthly Progress Skeleton
                      SkeletonCard(height: 150),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Enable refresh
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Motivational Quote Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '"إن الله يحب إذا عمل أحدكم عملاً أن يتقنه"',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Active Projects Section
                    Row(
                      children: [
                        Text(
                          'قيد التنفيذ',
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(AppBorderRadius.full),
                          ),
                          child: Text(
                            '${activeProjects.length}',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Active Projects List
                    if (activeProjects.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          border: Border.all(
                            color: theme.brightness == Brightness.dark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.work_off,
                              size: 48,
                              color: AppColors.gray400,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'لا توجد مشاريع نشطة',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.gray400,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddScreen()),
                                );
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(
                                'إضافة مشروع',
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: AppColors.textLight,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...activeProjects.map((project) => ProjectCard(
                            project: project,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailsScreen(project: project),
                                ),
                              );
                            },
                            onMorePressed: () {
                              _showProjectOptions(context, project);
                            },
                          )),

                    const SizedBox(height: AppSpacing.xl),

                    // Paused Projects Section
                    Row(
                      children: [
                        Text(
                          'متوقف مؤقتاً',
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gray400,
                            borderRadius: BorderRadius.circular(AppBorderRadius.full),
                          ),
                          child: Text(
                            '${pausedProjects.length}',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Paused Projects List
                    if (pausedProjects.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          border: Border.all(
                            color: AppColors.gray300.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          'لا توجد مشاريع متوقفة',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                      )
                    else
                      ...pausedProjects.map((project) => PausedProjectCard(
                            project: project,
                          )),

                    const SizedBox(height: AppSpacing.xl),

                    // Monthly Progress Section
                    MonthlyProgressWidget(
                      progress: projectProvider.getMonthlyProgress(),
                      message: _getProgressMessage(projectProvider.getMonthlyProgress()),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
        );
      },
    );

    if (widget.showScaffold) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.cardTheme.color,
            elevation: 0,
            title: Text(
              'مشاريعي',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'مشروع',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: bodyContent,
        ),
      );
    } else {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: bodyContent,
      );
    }
  }

  void _showProjectOptions(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'خيارات المشروع',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('تعديل المشروع'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit project
              },
            ),
            ListTile(
              leading: Icon(
                project.status == ProjectStatus.active ? Icons.pause : Icons.play_arrow,
              ),
              title: Text(
                project.status == ProjectStatus.active ? 'إيقاف المشروع' : 'استئناف المشروع',
              ),
              onTap: () {
                Navigator.pop(context);
                if (project.id != null) {
                  try {
                    context.read<ProjectProvider>().toggleProjectStatus(project.id!);
                  } catch (error) {
                    showErrorSnackbar(context, AppStrings.errorUpdatingProject);
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.warningColor),
              title: const Text('حذف المشروع', style: TextStyle(color: AppColors.warningColor)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, project);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المشروع'),
        content: Text('هل أنت متأكد من حذف مشروع "${project.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (project.id != null) {
                try {
                  context.read<ProjectProvider>().deleteProject(project.id!);
                } catch (error) {
                  showErrorSnackbar(context, AppStrings.errorDeletingProject);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningColor,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  String _getProgressMessage(double progress) {
    if (progress >= 0.8) {
      return 'أداء استثنائي! استمر في التميز.';
    } else if (progress >= 0.6) {
      return 'تقدم رائع! أنت على الطريق الصحيح.';
    } else if (progress >= 0.4) {
      return 'أداء جيد. يمكن تحقيق المزيد من التقدم.';
    } else {
      return 'حان وقت زيادة الجهد لتحقيق الأهداف.';
    }
  }
}
