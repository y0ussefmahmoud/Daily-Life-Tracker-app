import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stats_provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/water_provider.dart';
import '../providers/achievements_provider.dart';
import '../utils/constants.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/achievement_item.dart';
import '../widgets/time_distribution_item.dart';
import '../widgets/skeleton_loader.dart';
import '../models/stats_model.dart';
import '../models/report_model.dart';
import '../utils/error_handler.dart';

class StatsScreen extends StatefulWidget {
  final bool showScaffold;

  const StatsScreen({
    super.key,
    this.showScaffold = true,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;
  
  // State variables for loaded data
  Map<String, double>? _weeklyProductivity;
  List<WeeklyStats>? _weeklyChartData;
  List<TimeDistribution>? _timeDistribution;
  List<Achievement>? _achievements;
  List<ProjectReportModel>? _projectsOverview;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    if (!mounted) return;
    
    final context = this.context; // Store context before async operations
    
    try {
      final statsProvider = Provider.of<StatsProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      final waterProvider = Provider.of<WaterProvider>(context, listen: false);
      final achievementsProvider = Provider.of<AchievementsProvider>(context, listen: false);
      
      // Set providers in StatsProvider
      statsProvider.setProviders(
        taskProvider,
        projectProvider,
        waterProvider,
        achievementsProvider,
      );
      
      // Load stats data
      await _loadStatsData();
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = handleSupabaseError(error);
          _isLoading = false;
          _isInitialized = true;
        });
        showErrorSnackbar(context, _errorMessage!);
      }
    }
  }

  Future<void> _loadStatsData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final statsProvider = Provider.of<StatsProvider>(context, listen: false);
      
      // Load each dataset individually with fallback handling
      Map<String, double> weeklyProductivity = {};
      List<WeeklyStats> weeklyChartData = [];
      List<TimeDistribution> timeDistribution = [];
      List<Achievement> achievements = [];
      List<ProjectReportModel> projectsOverview = [];
      
      // Load weekly productivity with fallback
      try {
        weeklyProductivity = await statsProvider.getWeeklyProductivity();
      } catch (error) {
        debugPrint('Error loading weekly productivity, using fallback: $error');
        if (error is StatsException) {
          weeklyProductivity = await statsProvider.getWeeklyProductivityFallback();
        }
      }
      
      // Load weekly chart data with fallback
      try {
        weeklyChartData = await statsProvider.getWeeklyChartData();
      } catch (error) {
        debugPrint('Error loading weekly chart data, using fallback: $error');
        if (error is StatsException) {
          weeklyChartData = await statsProvider.getWeeklyChartDataFallback();
        }
      }
      
      // Load time distribution (already has built-in fallback)
      try {
        timeDistribution = await statsProvider.getTimeDistribution();
      } catch (error) {
        debugPrint('Error loading time distribution: $error');
        timeDistribution = [];
      }
      
      // Load weekly achievements (already has built-in fallback)
      try {
        achievements = await statsProvider.getWeeklyAchievements();
      } catch (error) {
        debugPrint('Error loading weekly achievements: $error');
        achievements = [];
      }
      
      // Load projects overview (no fallback method available)
      try {
        projectsOverview = await statsProvider.getProjectsOverview();
      } catch (error) {
        debugPrint('Error loading projects overview: $error');
        projectsOverview = [];
      }
      
      if (mounted) {
        setState(() {
          _weeklyProductivity = weeklyProductivity;
          _weeklyChartData = weeklyChartData;
          _timeDistribution = timeDistribution;
          _achievements = achievements;
          _projectsOverview = projectsOverview;
          _isLoading = false;
          _isInitialized = true;
        });
      }
    } catch (error) {
      debugPrint('Unexpected error in _loadStatsData: $error');
      if (mounted) {
        setState(() {
          _errorMessage = handleSupabaseError(error);
          _isLoading = false;
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer5<
        StatsProvider,
        TaskProvider,
        ProjectProvider,
        WaterProvider,
        AchievementsProvider
      >(
        builder: (
          context,
          statsProvider,
          taskProvider,
          projectProvider,
          waterProvider,
          achievementsProvider,
          child,
        ) {
          // Check for error states
          if (!_isInitialized || _isLoading) {
            return _buildLoadingState();
          }
          
          if (_errorMessage != null) {
            return _buildErrorState(_errorMessage);
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              final context = this.context; // Store context before async operations
              try {
                await statsProvider.refreshStats();
                await _loadStatsData();
              } catch (error) {
                showErrorSnackbar(context, handleSupabaseError(error));
              }
            },
            child: _buildContent(
              context,
              isDark,
              _weeklyProductivity ?? {},
              _weeklyChartData ?? [],
              _timeDistribution ?? [],
              _achievements ?? [],
              _projectsOverview ?? [],
            ),
          );
        },
      ),
    );

    return content;
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Weekly Productivity Card Skeleton
          SkeletonCard(height: 200),
          const SizedBox(height: AppSpacing.xl),

          // Time Distribution Section Skeleton
          SkeletonLoader(height: 18, width: 100),
          const SizedBox(height: AppSpacing.lg),
          SkeletonCard(height: 180),
          const SizedBox(height: AppSpacing.xl),

          // Weekly Achievements Section Skeleton
          SkeletonLoader(height: 18, width: 120),
          const SizedBox(height: AppSpacing.lg),
          SkeletonList(itemCount: 3),
          const SizedBox(height: AppSpacing.xl),

          // Projects Overview Section Skeleton
          SkeletonLoader(height: 18, width: 140),
          const SizedBox(height: AppSpacing.lg),
          SkeletonCard(height: 180),
          const SizedBox(height: AppSpacing.xl),

          // Footer Skeleton
          Center(
            child: SkeletonLoader(height: 14, width: 150),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SizedBox(height: 96), // Bottom padding for navigation bar
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return ErrorStateWidget(
      message: errorMessage ?? AppStrings.errorLoadingStats,
      onRetry: () {
        _loadStatsData();
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    Map<String, double> weeklyProductivity,
    List<WeeklyStats> weeklyChartData,
    List<TimeDistribution> timeDistribution,
    List<Achievement> achievements,
    List<ProjectReportModel> projectsOverview,
  ) {
    final activeProjects = projectsOverview.where((project) {
      final status = project.status.toLowerCase();
      return status == 'active' || status == 'in_progress';
    }).toList();
    final topProjects = activeProjects.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Weekly Productivity Card
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray200.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        ),
                        child: Text(
                          '+${weeklyProductivity['trend']?.toStringAsFixed(0) ?? '0'}%',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'الإنتاجية الإجمالية',
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: isDark ? AppColors.gray400 : AppColors.gray500,
                            ),
                          ),
                          Text(
                            '${weeklyProductivity['percentage']?.toStringAsFixed(0) ?? '0'}%',
                            style: GoogleFonts.tajawal(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'أداء ممتاز هذا الأسبوع مقارنة بالسابق',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  WeeklyChart(data: weeklyChartData),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Time Distribution Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'توزيع الوقت',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gray200.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: timeDistribution.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: TimeDistributionItem(item: item),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Weekly Achievements Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'إنجازات الأسبوع',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Column(
                children: achievements.map((achievement) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AchievementItem(
                      achievement: achievement,
                      onTap: () {
                        // TODO: Handle achievement tap
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Projects Overview Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'نظرة عامة على المشاريع',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gray200.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: topProjects.isEmpty
                        ? [
                            Text(
                              AppStrings.noData,
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                          ]
                        : topProjects.map((project) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(project.progress * 100).toStringAsFixed(0)}%',
                                        style: GoogleFonts.tajawal(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          project.projectName,
                                          textAlign: TextAlign.end,
                                          style: GoogleFonts.tajawal(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                                    child: LinearProgressIndicator(
                                      value: project.progress.clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor:
                                          isDark ? AppColors.gray800 : AppColors.gray100,
                                      color: AppColors.successColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        project.displayStatus(),
                                        style: GoogleFonts.tajawal(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.gray400
                                              : AppColors.gray500,
                                        ),
                                      ),
                                      Text(
                                        project.formatTimeSpent(),
                                        style: GoogleFonts.tajawal(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.gray400
                                              : AppColors.gray500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Footer
          Center(
            child: Text(
              'بارك الله في وقتك وجهدك',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          const SizedBox(height: 96), // Bottom padding for navigation bar
        ],
      ),
    );
  }
}
