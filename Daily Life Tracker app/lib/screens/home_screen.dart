// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/water_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/profile_provider.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../screens/tasks_screen.dart';
import '../screens/projects_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/prayer_screen.dart';
import '../screens/dhikr_screen.dart';
import '../screens/gym_screen.dart';
import '../screens/food_screen.dart';
import '../screens/water_screen.dart';
import '../screens/profile_screen.dart';
import '../services/local_database_service.dart';
import '../services/localization_service.dart';
import '../utils/constants.dart';
import '../utils/responsive_breakpoints.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    try {
      if (!mounted) return;
      await Future.wait([
        context.read<TaskProvider>().initialize(),
        context.read<ProjectProvider>().initialize(),
        context.read<WaterProvider>().initialize(),
      ]).timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('Providers initialization timeout');
          return [];
        },
      );
    } catch (e) {
      debugPrint('Error initializing providers: $e');
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            AppLocalizations.of(context).viewAll,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCardsSection(AppLocalizations l10n, int gridColumns, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.achievements, Icons.apps, () {}),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridColumns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isMobile ? 1.2 : 1.5,
          children: [
            _FeatureCardWidget(
              title: l10n.prayers,
              icon: Icons.mosque,
              color: AppColors.primaryColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrayerScreen()),
              ),
            ),
            _FeatureCardWidget(
              title: l10n.dhikr,
              icon: Icons.auto_stories,
              color: AppColors.successColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DhikrScreen()),
              ),
            ),
            _FeatureCardWidget(
              title: l10n.gym,
              icon: Icons.fitness_center,
              color: AppColors.warningColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GymScreen()),
              ),
            ),
            _FeatureCardWidget(
              title: l10n.food,
              icon: Icons.restaurant,
              color: AppColors.infoColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoodScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildTaskTile(TaskModel task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isCompleted 
                  ? AppColors.successColor 
                  : Colors.transparent,
              border: Border.all(
                color: task.isCompleted 
                    ? AppColors.successColor 
                    : AppColors.gray400,
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: task.isCompleted 
                        ? AppColors.textSecondary 
                        : AppColors.textPrimary,
                    decoration: task.isCompleted 
                        ? TextDecoration.lineThrough 
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.category,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            task.icon,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTile(Project project) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(project.progress * 100).toInt()}% ${l10n.completed}',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            project.techStack.join(', '),
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWaterScreen() {
    return const WaterScreen();
  }

  Widget _buildBottomNavigationBar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.darkTextSecondary 
            : AppColors.textSecondary,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: GoogleFonts.tajawal(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.tajawal(
          fontWeight: FontWeight.w400,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.task_outlined),
            activeIcon: const Icon(Icons.task),
            label: l10n.tasks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline),
            activeIcon: const Icon(Icons.work),
            label: l10n.projects,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.water_drop_outlined),
            activeIcon: const Icon(Icons.water_drop),
            label: l10n.water,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }

  void _showAddOptions() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(ResponsiveBreakpoints.getScreenPadding(context).left),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.task),
              title: Text(l10n.addTask),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: Text(l10n.addProject),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.water_drop),
              title: Text(l10n.drinkWater),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).appName,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return const TasksScreen();
      case 2:
        return const ProjectsScreen();
      case 3:
        return _buildWaterScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Consumer4<StatsProvider, TaskProvider, ProjectProvider, WaterProvider>(
      builder: (context, stats, tasks, projects, water, child) {
        final l10n = AppLocalizations.of(context);
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = ResponsiveBreakpoints.isMobile(context);
            final gridColumns = ResponsiveBreakpoints.getGridColumns(context);
            final padding = ResponsiveBreakpoints.getScreenPadding(context);
            
            return SingleChildScrollView(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 20 : 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.welcome,
                          style: TextStyle(
                            fontSize: ResponsiveBreakpoints.getFontSize(context, 24),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tasksToday.replaceFirst('{count}', '${tasks.todayTasks.length}'),
                          style: TextStyle(
                            fontSize: ResponsiveBreakpoints.getFontSize(context, 16),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              
              SizedBox(height: isMobile ? 24 : 32),
              
              if (isMobile)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            l10n.tasks,
                            '${tasks.todayTasks.where((t) => !t.isCompleted).length}',
                            Icons.task_alt,
                            AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            l10n.projects,
                            '${projects.projects.where((p) => p.status == ProjectStatus.active).length}',
                            Icons.work,
                            AppColors.warningColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            l10n.water,
                            '${water.currentIntake}${l10n.ml}',
                            Icons.water_drop,
                            AppColors.infoColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            l10n.progress,
                            '${(tasks.getCompletionPercentage() * 100).toInt()}%',
                            Icons.trending_up,
                            AppColors.successColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        l10n.tasks,
                        '${tasks.todayTasks.where((t) => !t.isCompleted).length}',
                        Icons.task_alt,
                        AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        l10n.projects,
                        '${projects.projects.where((p) => p.status == ProjectStatus.active).length}',
                        Icons.work,
                        AppColors.warningColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        l10n.water,
                        '${water.currentIntake.toString()}${l10n.ml}',
                        Icons.water_drop,
                        AppColors.infoColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        l10n.progress,
                        '${(tasks.getCompletionPercentage() * 100).toInt()}%',
                        Icons.trending_up,
                        AppColors.successColor,
                      ),
                    ),
                  ],
                ),
              
              SizedBox(height: isMobile ? 24 : 32),
              
              _buildFeatureCardsSection(l10n, gridColumns, isMobile),
              
              SizedBox(height: isMobile ? 24 : 32),
              
              _buildSectionHeader(l10n.tasks, Icons.task, () {
                setState(() {
                  _selectedIndex = 1;
                });
              }),
              
              const SizedBox(height: 12),
              
              if (tasks.todayTasks.isEmpty)
                _buildEmptyState(l10n.noData, l10n.addTask)
              else
                ...tasks.todayTasks.take(3).map((task) => _buildTaskTile(task)),
              
              SizedBox(height: isMobile ? 24 : 32),
              
              _buildSectionHeader(l10n.activeProjects, Icons.work, () {
                setState(() {
                  _selectedIndex = 2;
                });
              }),
              
              const SizedBox(height: 12),
              
              if (projects.projects.where((p) => p.status == ProjectStatus.active).isEmpty)
                _buildEmptyState(l10n.noData, l10n.addProject)
              else
                ...projects.projects
                    .where((p) => p.status == ProjectStatus.active)
                    .take(3)
                    .map((project) => _buildProjectTile(project)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FeatureCardWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCardWidget({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withAlpha(77),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

