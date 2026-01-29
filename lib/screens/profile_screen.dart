import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/achievements_provider.dart';
import '../providers/auth_provider.dart';
import 'splash_screen.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/settings_list_item.dart';
import '../widgets/ios_toggle.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      final achievementsProvider = context.read<AchievementsProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      
      profileProvider.loadProfile(achievementsProvider);
      settingsProvider.loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, SettingsProvider>(
      builder: (context, profileProvider, settingsProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final profile = profileProvider.profile;

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // Custom AppBar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: isDark 
                    ? AppColors.backgroundDark.withOpacity(0.8) 
                    : AppColors.backgroundLight.withOpacity(0.8),
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                centerTitle: true,
                title: Text(
                  AppStrings.profile,
                  style: TextStyle(
                    fontSize: AppTypography.title,
                    fontWeight: AppTypography.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                actions: const [
                  SizedBox(width: 48), // For symmetry
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(
                    height: 1,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                ),
              ),

              // Profile Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Avatar
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark 
                                ? AppColors.primaryColor.withOpacity(0.2)
                                : Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        profile?.name ?? 'يوسف',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: AppTypography.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Subtitle
                      Text(
                        profile?.subtitle ?? 'مطور واجهات | أسعى للتطوير',
                        style: TextStyle(
                          fontSize: AppTypography.body,
                          color: AppColors.primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      ProfileStatsCard(
                        icon: Icons.workspace_premium,
                        label: AppStrings.badges,
                        value: '${profile?.badgeCount ?? 0}',
                      ),
                      const SizedBox(width: 12),
                      ProfileStatsCard(
                        icon: Icons.local_fire_department,
                        label: AppStrings.streak,
                        value: '${profile?.streakDays ?? 0} ${AppStrings.days}',
                      ),
                      const SizedBox(width: 12),
                      ProfileStatsCard(
                        icon: Icons.military_tech,
                        label: AppStrings.points,
                        value: '${profile?.points ?? 0}',
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // My Account Section
              _buildSectionHeader(AppStrings.myAccount),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      SettingsListItem(
                        icon: Icons.person,
                        title: AppStrings.editProfile,
                        onTap: () {
                          // TODO: Navigate to edit profile screen
                        },
                      ),
                      SettingsListItem(
                        icon: Icons.lock,
                        title: AppStrings.privacy,
                        onTap: () {
                          // TODO: Navigate to privacy settings screen
                        },
                        showBorder: false,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Notifications Section
              _buildSectionHeader(AppStrings.notifications),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      SettingsListItem(
                        icon: Icons.bedtime,
                        title: AppStrings.prayerNotifications,
                        trailing: settingsProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IosToggle(
                                value: settingsProvider.prayerNotificationsEnabled,
                                onChanged: (value) {
                                  settingsProvider.togglePrayerNotifications();
                                },
                              ),
                      ),
                      SettingsListItem(
                        icon: Icons.assignment,
                        title: AppStrings.projectReminders,
                        trailing: settingsProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IosToggle(
                                value: settingsProvider.projectRemindersEnabled,
                                onChanged: (value) {
                                  settingsProvider.toggleProjectReminders();
                                },
                              ),
                      ),
                      SettingsListItem(
                        icon: Icons.water_drop,
                        title: AppStrings.waterTrackerNotifications,
                        onTap: () {
                          // TODO: Navigate to water tracker notification settings
                        },
                        showBorder: false,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Appearance Section
              _buildSectionHeader(AppStrings.appearance),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      SettingsListItem(
                        icon: Icons.dark_mode,
                        title: AppStrings.darkMode,
                        trailing: settingsProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IosToggle(
                                value: settingsProvider.darkModeEnabled,
                                onChanged: (value) {
                                  settingsProvider.toggleDarkMode();
                                },
                              ),
                      ),
                      SettingsListItem(
                        icon: Icons.palette,
                        title: AppStrings.changeTheme,
                        onTap: () {
                          // TODO: Navigate to theme picker screen
                        },
                        showBorder: false,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Support Section
              _buildSectionHeader(AppStrings.support),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      SettingsListItem(
                        icon: Icons.info,
                        title: AppStrings.aboutApp,
                        onTap: () {
                          // TODO: Navigate to about app screen
                        },
                      ),
                      SettingsListItem(
                        icon: Icons.mail,
                        title: AppStrings.contactUs,
                        onTap: () {
                          // TODO: Navigate to contact us screen
                        },
                        showBorder: false,
                      ),
                    ],
                  ),
                ),
              ),

              // Sign Out Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.red.withOpacity(0.1)
                          : Colors.red.shade50,
                      border: Border.all(
                        color: isDark 
                            ? Colors.red.withOpacity(0.2)
                            : Colors.red.shade100,
                      ),
                      borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    ),
                    child: MaterialButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: () => _showSignOutDialog(profileProvider),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.red.shade500,
                            size: AppSizes.iconDefault,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.signOut,
                            style: TextStyle(
                              color: Colors.red.shade500,
                              fontSize: AppTypography.body,
                              fontWeight: AppTypography.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // App Version
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Text(
                    'النسخة 2.4.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.gray400,
                      fontSize: AppTypography.small,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: AppTypography.small,
            fontWeight: AppTypography.bold,
            color: AppColors.primaryColor.withOpacity(0.6),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Future<void> _showSignOutDialog(ProfileProvider profileProvider) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              AppStrings.signOut,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
