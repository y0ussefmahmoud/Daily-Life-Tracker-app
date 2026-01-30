import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/achievements_provider.dart';
import '../widgets/badge_widget.dart';
import '../widgets/level_hero_card.dart';
import '../widgets/leaderboard_item.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementsProvider>().loadAchievementsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          AppStrings.achievements,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: AppTypography.title,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Navigate to settings
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      body: Consumer<AchievementsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return ErrorStateWidget(
              message: handleProviderError(provider.error, 'achievements'),
              subtitle: 'لا يمكن عرض الإنجازات حالياً',
              icon: Icons.emoji_events_outlined,
              onRetry: () => provider.loadAchievementsData(),
            );
          }

          if (provider.userLevel == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(
                        Icons.emoji_events_outlined,
                        size: 64,
                        color: AppColors.primaryColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'ابدأ رحلة الإنجازات!',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: AppTypography.title,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'أكمل المهام اليومية واحصل على نقاط الخبرة لفتح الأوسمة والارتقاء بمستواك',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: AppTypography.body,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.add_task),
                      label: const Text('إضافة مهمة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              try {
                await Future.wait([
                  provider.loadAchievementsData(),
                  provider.refreshLeaderboard(),
                ]);
              } catch (error) {
                showErrorSnackbar(context, handleSupabaseError(error));
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 80),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSizes.maxMobileWidth),
                child: Column(
                  children: [
                    // Section 1: Level Hero Card
                    LevelHeroCard(
                      userLevel: provider.userLevel!,
                      onRoadmapPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'خارطة الطريق قيد التطوير',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: AppTypography.body,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // Section 2: Earned Badges Header
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.earnedBadges,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: AppTypography.title,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Show all badges
                          },
                          child: Text(
                            AppStrings.viewAll,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: AppTypography.body,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Section 3: Badge Grid
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: provider.allBadges.length,
                      itemBuilder: (context, index) {
                        final badge = provider.allBadges[index];
                        return BadgeWidget(
                          badge: badge,
                          onTap: () {
                            _showBadgeDetailsDialog(context, badge);
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Section 4: Weekly Leaderboard
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.weeklyLeaderboard,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: AppTypography.title,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Icon(
                                Icons.chevron_left,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                        // Leaderboard Items
                        ...provider.leaderboard.map((user) {
                          final isLast = provider.leaderboard.last == user;
                          return Column(
                            children: [
                              LeaderboardItem(
                                user: user,
                                onTap: () {
                                  // TODO: Show user details
                                },
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  color: Theme.of(context).dividerColor,
                                  indent: AppSpacing.md,
                                  endIndent: AppSpacing.md,
                                ),
                            ],
                          );
                        }).toList(),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

  void _showBadgeDetailsDialog(BuildContext context, dynamic badge) {
    try {
      // Validate badge data
      if (badge == null) {
        showErrorSnackbar(context, AppStrings.errorLoadingAchievements);
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BadgeWidget(
                badge: badge,
                size: 100,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                badge.title ?? 'شارة غير معروفة',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: AppTypography.title,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                badge.description ?? 'لا يوجد وصف لهذه الشارة',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: AppTypography.body,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              if (badge.isEarned == false) ...[
                const SizedBox(height: AppSpacing.md),
                LinearProgressIndicator(
                  value: badge.progress ?? 0.0,
                  backgroundColor: AppColors.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(badge.color ?? AppColors.primaryColor),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${((badge.progress ?? 0.0) * 100).round()}% مكتمل',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: AppTypography.small,
                    color: badge.color ?? AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else if (badge.earnedDate != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'تم الحصول عليها في ${badge.earnedDate?.day}/${badge.earnedDate?.month}/${badge.earnedDate?.year}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: AppTypography.small,
                    color: AppColors.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                  ),
                  child: Text(
                    'حسناً',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: AppTypography.body,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (error) {
      showErrorSnackbar(context, 'فشل عرض تفاصيل الشارة');
    }
  }
}
