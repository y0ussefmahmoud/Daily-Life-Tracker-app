import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import '../providers/task_provider.dart';
import '../providers/water_provider.dart';
import '../providers/project_provider.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../widgets/profile_header.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/task_section.dart';
import '../widgets/water_tracker.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/skeleton_loader.dart';
import 'projects_screen.dart';
import 'stats_screen.dart';
import 'add_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'ar').format(DateTime.now());
    final String userName = 'يوسف';

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Consumer3<TaskProvider, WaterProvider, ProjectProvider>(
        builder: (context, taskProvider, waterProvider, projectProvider, child) {
          // Check for errors from any provider
          final hasTaskError = taskProvider.error != null && !taskProvider.isLoading;
          final hasWaterError = waterProvider.error != null && !waterProvider.isLoading;
          final hasProjectError = projectProvider.error != null && !projectProvider.isLoading;
          
          if (hasTaskError || hasWaterError || hasProjectError) {
            String errorMessage = '';
            VoidCallback? onRetry;
            
            if (hasTaskError) {
              errorMessage = taskProvider.error!;
              onRetry = () {
                taskProvider.clearError();
                taskProvider.refreshTasks();
              };
            } else if (hasWaterError) {
              errorMessage = waterProvider.error!;
              onRetry = () {
                waterProvider.clearError();
                waterProvider.refreshWaterData();
              };
            } else if (hasProjectError) {
              errorMessage = projectProvider.error!;
              onRetry = () {
                projectProvider.clearError();
                projectProvider.refreshProjects();
              };
            }
            
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: _buildAppBar(context),
              body: ErrorStateWidget(
                message: errorMessage,
                onRetry: onRetry,
              ),
              bottomNavigationBar: CustomBottomNavigation(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                onFabPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddScreen()),
                ),
              ),
            );
          }
          
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).cardTheme.color,
              elevation: 0,
              title: Text(
                _getAppBarTitle(),
                style: GoogleFonts.tajawal(
                  fontSize: AppTypography.titleLarge,
                  fontWeight: AppTypography.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              centerTitle: true,
              leading: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primaryColor,
                      size: AppSizes.iconDefault,
                    ),
                  ),
                ),
              ),
              actions: [
                if (_currentIndex == 1)
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Theme.of(context).iconTheme.color,
                      size: AppSizes.iconDefault,
                    ),
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                  )
                else
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: Theme.of(context).iconTheme.color,
                      size: AppSizes.iconDefault,
                    ),
                    onPressed: () {
                      // TODO: Implement notifications
                    },
                  ),
              ],
            ),
            body: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _getScreenForIndex(_currentIndex, taskProvider, waterProvider, Key('tab_$_currentIndex')),
            ),
            bottomNavigationBar: CustomBottomNavigation(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                // TODO: Handle navigation
              },
              onFabPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddScreen(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'اليوم';
      case 1:
        return 'إحصائيات الأسبوع';
      case 3:
        return 'مشاريعي';
      case 4:
        return 'الملف الشخصي';
      default:
        return 'متتبع الحياة اليومية';
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).cardTheme.color,
      elevation: 0,
      title: Text(
        _getAppBarTitle(),
        style: GoogleFonts.tajawal(
          fontSize: AppTypography.titleLarge,
          fontWeight: AppTypography.bold,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: AppColors.primaryColor,
              size: AppSizes.iconDefault,
            ),
          ),
        ),
      ),
      actions: [
        if (_currentIndex == 1)
          IconButton(
            icon: Icon(
              Icons.share,
              color: Theme.of(context).iconTheme.color,
              size: AppSizes.iconDefault,
            ),
            onPressed: () {
              // TODO: Implement share functionality
            },
          )
        else
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Theme.of(context).iconTheme.color,
              size: AppSizes.iconDefault,
            ),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
      ],
    );
  }

  String _getMotivationalMessage(double progress) {
    if (progress >= 1.0) {
      return 'ممتاز! لقد أكملت جميع مهام اليوم بنجاح. استمر في التميز!';
    } else if (progress >= 0.75) {
      return 'رائع! أنت على وشك إكمال جميع مهام اليوم. بقليل من الجهد ستحقق الهدف!';
    } else if (progress >= 0.5) {
      return 'أداء جيد جداً! لقد أكملت نصف مهام اليوم. استمر في المضي قدماً!';
    } else if (progress >= 0.25) {
      return 'بداية مشجعة! استمر في العمل على مهامك لتحقيق أهداف اليوم.';
    } else {
      return 'كل رحلة تبدأ بخطوة. ابدأ بإكمال أول مهمة اليوم وستجد الأمور أسهل.';
    }
  }

  Widget _getScreenForIndex(int index, TaskProvider taskProvider, WaterProvider waterProvider, Key key) {
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'ar').format(DateTime.now());
    final String userName = 'يوسف';

    switch (index) {
      case 0:
        // Home Screen
        return RefreshIndicator(
          key: key,
          onRefresh: () async {
            try {
              await Future.wait([
                taskProvider.refreshTasks(),
                waterProvider.refreshWaterData(),
              ]);
              
              if (taskProvider.error != null) {
                if (mounted) {
                  showErrorSnackbar(
                    context,
                    taskProvider.error!,
                    onRetry: () => taskProvider.refreshTasks(),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                showErrorSnackbar(
                  context,
                  handleSupabaseError(e),
                  onRetry: () async {
                    await taskProvider.refreshTasks();
                    await waterProvider.refreshWaterData();
                  },
                );
              }
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              children: [
                if (taskProvider.error != null || waterProvider.error != null)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: AppSizes.iconDefault,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            taskProvider.error ?? waterProvider.error ?? '',
                            style: GoogleFonts.tajawal(
                              fontSize: AppTypography.caption,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: AppSizes.iconSmall),
                          onPressed: () {
                            taskProvider.clearError();
                            waterProvider.clearError();
                          },
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),
                if (taskProvider.isLoading)
                  Column(
                    children: [
                      // Profile Header Skeleton
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SkeletonCircle(size: 60),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SkeletonLoader(height: 20, width: 120),
                                      const SizedBox(height: AppSpacing.sm),
                                      SkeletonLoader(height: 14, width: 200),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SkeletonLoader(height: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Progress Bar Skeleton
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLoader(height: 16, width: 150),
                            const SizedBox(height: AppSpacing.sm),
                            SkeletonLoader(height: 12),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Task Sections Skeleton
                      SkeletonList(itemCount: 6),
                      const SizedBox(height: AppSpacing.lg),
                      // Water Tracker Skeleton
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SkeletonLoader(height: 20, width: 100),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: List.generate(
                                8,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                                  child: SkeletonLoader(
                                    width: 32,
                                    height: 32,
                                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Daily Summary Skeleton
                      SkeletonCard(),
                    ],
                  )
                else
                  Column(
                    children: [
                      ProfileHeader(
                        userName: userName,
                        date: formattedDate,
                        progress: taskProvider.getCompletionPercentage(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ProgressBarWidget(
                        label: 'إنجاز المهام اليومية',
                        progress: taskProvider.getCompletionPercentage(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TaskSection(
                      title: 'الصباح',
                      icon: Icons.wb_sunny,
                      iconColor: Colors.orange[400] ?? AppColors.morningOrange,
                      tasks: taskProvider.getTasksByCategory('morning'),
                      onTaskToggle: (taskId) => taskProvider.toggleTask(taskId),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TaskSection(
                      title: 'العمل',
                      icon: Icons.work,
                      iconColor: AppColors.primaryColor,
                      tasks: taskProvider.getTasksByCategory('work'),
                      onTaskToggle: (taskId) => taskProvider.toggleTask(taskId),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TaskSection(
                      title: 'الصلاة',
                      icon: Icons.menu_book,
                      iconColor: Colors.teal,
                      tasks: taskProvider.getTasksByCategory('prayer'),
                      onTaskToggle: (taskId) => taskProvider.toggleTask(taskId),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TaskSection(
                      title: 'الصحة',
                      icon: Icons.fitness_center,
                      iconColor: Colors.orange,
                      tasks: taskProvider.getTasksByCategory('health'),
                      onTaskToggle: (taskId) => taskProvider.toggleTask(taskId),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TaskSection(
                      title: 'شخصي',
                      icon: Icons.person,
                      iconColor: Colors.purple,
                      tasks: taskProvider.getTasksByCategory('personal'),
                      onTaskToggle: (taskId) => taskProvider.toggleTask(taskId),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TaskSection(
                      title: 'المساء',
                      icon: Icons.dark_mode,
                      iconColor: Colors.indigo[400] ?? AppColors.eveningIndigo,
                      tasks: taskProvider.getTasksByCategory('evening'),
                      onTaskToggle: (taskId) => taskProvider.toggleTask(taskId),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const WaterTracker(),
                    const SizedBox(height: AppSpacing.lg),
                    DailySummaryCard(
                      message: _getMotivationalMessage(taskProvider.getCompletionPercentage()),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ],
            ),
          ),
        );
      case 1:
        // Stats Screen
        return StatsScreen(showScaffold: false, key: key);
      case 3:
        // Projects Screen
        return ProjectsScreen(showScaffold: false, key: key);
      case 4:
        // Profile Screen
        return ProfileScreen(key: key);
      default:
        // Placeholder for other tabs
        return Center(
          child: Text(
            'قريباً',
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        );
    }
  }
}
