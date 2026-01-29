import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onFabPressed;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.onFabPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: AppSizes.navigationHeight,
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.cardDark.withOpacity(0.8)
                : AppColors.cardLight.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.0,
              ),
            ),
          ),
          child: Row(
              children: [
                // Home button (index 0)
                _buildNavigationItem(
                  context,
                  icon: Icons.home,
                  label: 'اليوم',
                  index: 0,
                  isActive: currentIndex == 0,
                  useFilled: currentIndex == 0,
                ),
                // Stats button (index 1)
                _buildNavigationItem(
                  context,
                  icon: Icons.bar_chart,
                  label: 'الإحصائيات',
                  index: 1,
                  isActive: currentIndex == 1,
                ),
                // Spacer for FAB
                const Expanded(child: SizedBox()),
                // Projects button (index 3)
                _buildNavigationItem(
                  context,
                  icon: Icons.assignment,
                  label: 'المشاريع',
                  index: 3,
                  isActive: currentIndex == 3,
                ),
                // Profile button (index 4)
                _buildNavigationItem(
                  context,
                  icon: Icons.person,
                  label: 'الملف الشخصي',
                  index: 4,
                  isActive: currentIndex == 4,
                ),
              ],
            ),
          ),
        // Floating Action Button
        Positioned(
          top: -28,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: AppSizes.fabSize,
              height: AppSizes.fabSize,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                  width: 4.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  onTap: onFabPressed,
                  child: Icon(
                    Icons.add,
                    size: 32,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    bool useFilled = false,
  }) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  useFilled ? _getFilledIcon(icon) : icon,
                  size: AppSizes.iconNavigation,
                  color: isActive ? AppColors.primaryColor : AppColors.gray400,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.tiny,
                    color: isActive ? AppColors.primaryColor : AppColors.gray400,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFilledIcon(IconData icon) {
    // Return filled variants for common icons
    switch (icon) {
      case Icons.home:
        return Icons.home_filled;
      case Icons.bar_chart:
        return Icons.bar_chart_rounded;
      case Icons.assignment:
        return Icons.assignment_rounded;
      case Icons.person:
        return Icons.person_rounded;
      default:
        return icon;
    }
  }
}
