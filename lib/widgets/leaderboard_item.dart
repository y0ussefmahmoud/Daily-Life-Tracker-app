import 'package:flutter/material.dart';
import '../models/leaderboard_user_model.dart';
import '../utils/constants.dart';

class LeaderboardItem extends StatelessWidget {
  final LeaderboardUserModel user;
  final VoidCallback? onTap;

  const LeaderboardItem({
    Key? key,
    required this.user,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: user.isCurrentUser
              ? AppColors.primaryColor.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: user.isCurrentUser
              ? Border.all(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 40,
              child: Text(
                user.rankDisplay,
                style: TextStyle(
                  fontFamily: 'Roboto Mono',
                  fontSize: AppTypography.title,
                  fontWeight: FontWeight.bold,
                  color: user.hasMedal
                      ? user.rank == 1
                          ? Colors.amber
                          : user.rank == 2
                              ? Colors.grey.shade400
                              : Colors.brown.shade300
                      : AppColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Avatar
            ClipOval(
              child: user.avatarUrl != null
                  ? Image.network(
                      user.avatarUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 40,
                          height: 40,
                          color: AppColors.gray200,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          color: AppColors.gray200,
                          child: Icon(
                            Icons.person,
                            color: AppColors.gray500,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      color: AppColors.gray200,
                      child: Icon(
                        Icons.person,
                        color: AppColors.gray500,
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: AppTypography.body,
                      fontWeight: FontWeight.bold,
                      color: user.isCurrentUser
                          ? AppColors.primaryColor
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${user.xp} XP',
                    style: TextStyle(
                      fontFamily: 'Roboto Mono',
                      fontSize: AppTypography.small,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            // Badge or premium icon
            if (user.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.badge!,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: AppTypography.tiny,
                    color: AppColors.warningColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (user.isCurrentUser)
              Icon(
                Icons.star,
                color: AppColors.primaryColor,
                size: 20,
              )
            else
              const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
