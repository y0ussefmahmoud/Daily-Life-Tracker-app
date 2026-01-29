import 'package:flutter/material.dart';
import '../models/user_level_model.dart';
import '../utils/constants.dart';

class LevelHeroCard extends StatelessWidget {
  final UserLevelModel userLevel;
  final VoidCallback? onRoadmapPressed;

  const LevelHeroCard({
    Key? key,
    required this.userLevel,
    this.onRoadmapPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, Color(0xFF4338CA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Abstract background pattern
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Level info and medal icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.currentLevel,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: AppTypography.caption,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'المستوى ${userLevel.currentLevel}: ${userLevel.levelTitle}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: AppTypography.titleLarge,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.military_tech,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // XP display
                Text(
                  '${userLevel.currentXP} ${AppStrings.xpPoints}',
                  style: TextStyle(
                    fontFamily: 'Roboto Mono',
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${userLevel.currentXP}/${userLevel.xpForNextLevel}',
                  style: TextStyle(
                    fontFamily: 'Roboto Mono',
                    fontSize: AppTypography.body,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${userLevel.xpRemaining} ${AppStrings.xpRemaining}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: AppTypography.small,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Progress bar
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: userLevel.xpProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.successColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Roadmap button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRoadmapPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppStrings.viewRoadmap,
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
        ],
      ),
    );
  }
}
