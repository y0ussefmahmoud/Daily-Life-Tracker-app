import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stats_provider.dart';
import '../utils/constants.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/achievement_item.dart';
import '../widgets/time_distribution_item.dart';
import '../widgets/skeleton_loader.dart';
import '../models/stats_model.dart';
import '../models/report_model.dart';
import '../utils/error_handler.dart';

class StatsScreen extends StatelessWidget {
  final bool showScaffold;

  const StatsScreen({
    Key? key,
    this.showScaffold = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<StatsProvider>(
        builder: (context, statsProvider, child) {
          if (statsProvider.errorMessage != null) {
            return _buildErrorState(statsProvider.errorMessage, context);
          }
          return RefreshIndicator(
            onRefresh: () async {
              await statsProvider.refreshStats();
            },
            child: FutureBuilder(
              future: Future.wait([
                statsProvider.getWeeklyProductivity(),
                statsProvider.getWeeklyChartData(),
                statsProvider.getTimeDistribution(),
                statsProvider.getWeeklyAchievements(),
                statsProvider.getProjectsOverview(),
              ]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error, context);
                }

                final weeklyProductivity = snapshot.data![0] as Map<String, double>;
                final weeklyChartData = snapshot.data![1] as List<WeeklyStats>;
                final timeDistribution = snapshot.data![2] as List<TimeDistribution>;
                final achievements = snapshot.data![3] as List<Achievement>;
                final projectsOverview = snapshot.data![4] as List<ProjectReportModel>;

                return _buildContent(
                  context,
                  isDark,
                  weeklyProductivity,
                  weeklyChartData,
                  timeDistribution,
                  achievements,
                  projectsOverview,
                );
              },
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

  Widget _buildErrorState(dynamic error, BuildContext context) {
    final message = error is String
        ? error
        : error is StatsException
            ? error.message
            : handleSupabaseError(error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.errorLoadingStats,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<StatsProvider>(context, listen: false).refreshStats();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
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
