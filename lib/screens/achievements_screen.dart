import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/achievements_provider.dart';
import '../widgets/badge_widget.dart';
import '../widgets/level_hero_card.dart';
import '../widgets/leaderboard_item.dart';
import '../utils/constants.dart';

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
                    'حدث خطأ في تحميل البيانات',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: AppTypography.body,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: AppTypography.small,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadAchievementsData(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (provider.userLevel == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد بيانات إنجازات',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: AppTypography.body,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ابدأ بإكمال المهام لكسب نقاط الخبرة والإنجازات',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: AppTypography.small,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadAchievementsData();
              await provider.refreshLeaderboard();
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
              badge.title,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: AppTypography.title,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              badge.description,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: AppTypography.body,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (!badge.isEarned) ...[
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: badge.progress,
                backgroundColor: AppColors.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(badge.color),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${(badge.progress * 100).round()}% مكتمل',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: AppTypography.small,
                  color: badge.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
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
  }
}
