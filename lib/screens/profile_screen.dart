import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/achievements_provider.dart';
import '../providers/auth_provider.dart';
import 'splash_screen.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/settings_list_item.dart';
import '../widgets/ios_toggle.dart';
import '../widgets/skeleton_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _error;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profileProvider = context.read<ProfileProvider>();
      final achievementsProvider = context.read<AchievementsProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      
      await Future.wait([
        profileProvider.loadProfile(achievementsProvider),
        settingsProvider.loadSettings(),
      ]);
    } catch (error) {
      setState(() {
        _error = handleSupabaseError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, SettingsProvider>(
      builder: (context, profileProvider, settingsProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final profile = profileProvider.profile;

        // Check for provider errors
        if (profileProvider.error != null || settingsProvider.error != null) {
          final error = profileProvider.error ?? settingsProvider.error;
          final context = error == profileProvider.error ? 'profile' : 'settings';
          return Scaffold(
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            body: ErrorStateWidget(
              message: handleProviderError(error, context),
              subtitle: context == 'settings' ? 'لا يمكن تحميل الإعدادات حالياً' : 'لا يمكن عرض الملف الشخصي حالياً',
              icon: context == 'settings' ? Icons.settings : Icons.person,
              onRetry: _loadData,
            ),
          );
        }

        // Show loading skeleton
        if (_isLoading) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            body: _buildLoadingSkeleton(isDark),
          );
        }

        // Show error state
        if (_error != null) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            body: ErrorStateWidget(
              message: _error!,
              subtitle: 'فشل تحميل الملف الشخصي',
              icon: Icons.error_outline,
              onRetry: _loadData,
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: SafeArea(
            child: CustomScrollView(
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
                      color: Theme.of(context).cardColor,
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
              _buildSectionHeader(Text(
                AppStrings.myAccount,
                style: TextStyle(
                  fontSize: AppTypography.title,
                  fontWeight: AppTypography.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              )),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(isDark ? 0.05 : 1.0),
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
              _buildSectionHeader(Text(
                AppStrings.notifications,
                style: TextStyle(
                  fontSize: AppTypography.title,
                  fontWeight: AppTypography.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              )),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(isDark ? 0.05 : 1.0),
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
                                onChanged: (value) async {
                                  try {
                                    await settingsProvider.togglePrayerNotifications();
                                  } catch (error) {
                                    showErrorSnackbar(context, AppStrings.errorUpdatingSettings);
                                  }
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
                                onChanged: (value) async {
                                  try {
                                    await settingsProvider.toggleProjectReminders();
                                  } catch (error) {
                                    showErrorSnackbar(context, AppStrings.errorUpdatingSettings);
                                  }
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
              _buildSectionHeader(Text(
                AppStrings.appearance,
                style: TextStyle(
                  fontSize: AppTypography.title,
                  fontWeight: AppTypography.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              )),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(isDark ? 0.05 : 1.0),
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
                                onChanged: (value) async {
                                  try {
                                    await settingsProvider.toggleDarkMode();
                                  } catch (error) {
                                    showErrorSnackbar(context, AppStrings.errorUpdatingSettings);
                                  }
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
              _buildSectionHeader(Text(
                AppStrings.support,
                style: TextStyle(
                  fontSize: AppTypography.title,
                  fontWeight: AppTypography.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              )),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(isDark ? 0.05 : 1.0),
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
                      onPressed: _isSigningOut ? null : () => _showSignOutDialog(profileProvider),
                      child: _isSigningOut
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                            )
                          : Row(
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
              // Bottom padding to prevent overflow
              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // Extra bottom padding
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return CustomScrollView(
      slivers: [
        // Custom AppBar Skeleton
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
            child: const Center(
              child: SkeletonLoader(width: 24, height: 24),
            ),
          ),
          centerTitle: true,
          title: const SkeletonLoader(width: 120, height: 20),
        ),

        // Profile Header Skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Avatar Skeleton
                SkeletonLoader(
                  width: 128,
                  height: 128,
                  borderRadius: BorderRadius.circular(64),
                ),
                const SizedBox(height: 16),
                // Name Skeleton
                const SkeletonLoader(width: 100, height: 24),
                const SizedBox(height: 4),
                // Subtitle Skeleton
                const SkeletonLoader(width: 200, height: 16),
              ],
            ),
          ),
        ),

        // Stats Cards Skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SkeletonCard(
                    height: 80,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SkeletonCard(
                    height: 80,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SkeletonCard(
                    height: 80,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Sections Skeleton
        ...List.generate(4, (index) => [
          _buildSectionHeader(const SkeletonLoader(width: 80, height: 12)),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SkeletonCard(
                height: 120,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]).expand((e) => e).toList(),
      ],
    );
  }

  Widget _buildSectionHeader(Widget child) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: child,
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
              
              setState(() => _isSigningOut = true);
              
              try {
                final authProvider = context.read<AuthProvider>();
                await authProvider.signOut();
                
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                }
              } catch (error) {
                if (mounted) {
                  setState(() => _isSigningOut = false);
                  showErrorDialog(
                    context,
                    'فشل تسجيل الخروج',
                    handleSupabaseError(error),
                    onRetry: () => _showSignOutDialog(profileProvider),
                  );
                }
              }
            },
            child: _isSigningOut
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  )
                : const Text(
                    AppStrings.signOut,
                    style: TextStyle(color: Colors.red),
                  ),
          ),
        ],
      ),
    );
  }
}
