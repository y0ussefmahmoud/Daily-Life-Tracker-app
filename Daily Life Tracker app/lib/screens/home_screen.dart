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
import '../utils/constants.dart';

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
    // Initialize providers after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    try {
      // Initialize providers one by one to avoid complex dependencies
      if (!mounted) return;
      await context.read<TaskProvider>().initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () => debugPrint('TaskProvider initialization timeout'),
      );
      if (!mounted) return;
      await context.read<ProjectProvider>().initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () => debugPrint('ProjectProvider initialization timeout'),
      );
      if (!mounted) return;
      await context.read<WaterProvider>().initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () => debugPrint('WaterProvider initialization timeout'),
      );
    } catch (e) {
      debugPrint('Error initializing providers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Life Tracker',
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
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section with Gradient
              Container(
                padding: const EdgeInsets.all(20),
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
                      'مرحباً بك!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لديك ${tasks.todayTasks.length} مهام اليوم',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Quick Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'المهام اليومية',
                      '${tasks.todayTasks.where((t) => !t.isCompleted).length}',
                      Icons.task_alt,
                      AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'المشاريع',
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
                      'المياه',
                      '${water.currentIntake}مل',
                      Icons.water_drop,
                      AppColors.infoColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'الإنتاجية',
                      '${(tasks.getCompletionPercentage() * 100).toInt()}%',
                      Icons.trending_up,
                      AppColors.successColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Features Section
              _buildSectionHeader('الميزات', Icons.apps, () {}),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildFeatureCard(
                    'الصلوات',
                    Icons.mosque,
                    AppColors.primaryColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrayerScreen()),
                    ),
                  ),
                  _buildFeatureCard(
                    'الأذكار',
                    Icons.auto_stories,
                    AppColors.successColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DhikrScreen()),
                    ),
                  ),
                  _buildFeatureCard(
                    'الجيم',
                    Icons.fitness_center,
                    AppColors.warningColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GymScreen()),
                    ),
                  ),
                  _buildFeatureCard(
                    'الأكل',
                    Icons.restaurant,
                    AppColors.infoColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FoodScreen()),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recent Tasks Section
              _buildSectionHeader('المهام الأخيرة', Icons.task, () {
                setState(() {
                  _selectedIndex = 1;
                });
              }),
              
              const SizedBox(height: 12),
              
              if (tasks.todayTasks.isEmpty)
                _buildEmptyState('لا توجد مهام اليوم', 'اضغط على + لإضافة مهمة جديدة')
              else
                ...tasks.todayTasks.take(3).map((task) => _buildTaskTile(task)),
              
              const SizedBox(height: 24),
              
              // Active Projects Section
              _buildSectionHeader('المشاريع النشطة', Icons.work, () {
                setState(() {
                  _selectedIndex = 2;
                });
              }),
              
              const SizedBox(height: 12),
              
              if (projects.projects.where((p) => p.status == ProjectStatus.active).isEmpty)
                _buildEmptyState('لا توجد مشاريع نشطة', 'اضغط على + لإضافة مشروع جديد')
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
  }

  Widget _buildWaterScreen() {
    return const WaterScreen();
  }

  Widget _buildBottomNavigationBar() {
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'المهام',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'المشاريع',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_outlined),
            activeIcon: Icon(Icons.water_drop),
            label: 'المياه',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'الملف',
          ),
        ],
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('إضافة مهمة'),
              onTap: () {
                Navigator.pop(context);
                _showAddTaskDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('إضافة مشروع'),
              onTap: () {
                Navigator.pop(context);
                _showAddProjectDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.water_drop),
              title: const Text('تسجيل مياه'),
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

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddTaskDialog(),
    );
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddProjectDialog(),
    );
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
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
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
            'عرض الكل',
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

  Widget _buildTaskTile(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            task.icon,
            color: task.isCompleted ? AppColors.successColor : AppColors.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted 
                    ? AppColors.textSecondary 
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTile(Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.work,
            color: AppColors.warningColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(project.progress * 100).toInt()}% مكتمل',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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

  Widget _buildFeatureCard(String title, IconData icon, Color color, VoidCallback onTap) {
    debugPrint('Building feature card: $title');
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

// Add Task Dialog
class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog();

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  String _selectedPriority = 'medium';
  IconData _selectedIcon = Icons.task;
  bool _isRepeating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'إضافة مهمة جديدة',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المهمة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال عنوان المهمة';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category Field
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال الفئة';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Priority Selection
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'الأولوية',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'high', child: Text('عالية')),
                  DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                  DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Icon Selection
              Text('اختر الأيقونة'),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final icons = [Icons.task, Icons.work, Icons.home, Icons.school, Icons.sports];
                    final icon = icons[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon;
                        });
                      },
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon ? AppColors.primaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: _selectedIcon == icon ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Repeating Checkbox
              CheckboxListTile(
                title: Text('مهمة متكررة'),
                value: _isRepeating,
                onChanged: (value) {
                  setState(() {
                    _isRepeating = value!;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('إضافة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('إضافة'),
        ),
      ],
    );
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      try {
        await taskProvider.addTask(
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          icon: _selectedIcon,
          priority: _getPriorityFromString(_selectedPriority),
          reminderTime: null,
          isRepeating: _isRepeating,
        );
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت إضافة المهمة'),
              backgroundColor: AppColors.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }

  TaskPriority _getPriorityFromString(String priority) {
    switch (priority) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
}

// Add Project Dialog
class _AddProjectDialog extends StatefulWidget {
  const _AddProjectDialog();

  @override
  State<_AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<_AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _techStackController = TextEditingController();
  final _weeklyHoursController = TextEditingController();
  final _progressController = TextEditingController();
  final _categoryController = TextEditingController(text: 'عام');
  final _totalHoursSpentController = TextEditingController(text: '0');
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _techStackController.dispose();
    _weeklyHoursController.dispose();
    _progressController.dispose();
    _categoryController.dispose();
    _totalHoursSpentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إضافة مشروع جديد',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المشروع',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال اسم المشروع';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Tech Stack Field
              TextFormField(
                controller: _techStackController,
                decoration: const InputDecoration(
                  labelText: 'تقنيات المشروع (افصل بينها بفاصلة)',
                  border: OutlineInputBorder(),
                  hintText: 'Flutter, Dart, Firebase',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال تقنية واحدة على الأقل';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Weekly Hours Field
              TextFormField(
                controller: _weeklyHoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الساعات الأسبوعية',
                  border: OutlineInputBorder(),
                  hintText: '40',
                ),
                validator: (value) {
                  final hours = int.tryParse(value ?? '');
                  if (hours == null || hours < 1 || hours > 168) {
                    return 'الرجاء إدخال عدد ساعات صحيح (1-168)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Progress Field
              TextFormField(
                controller: _progressController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'نسبة التقدم (%)',
                  border: OutlineInputBorder(),
                  hintText: '0',
                ),
                validator: (value) {
                  final progress = double.tryParse(value ?? '');
                  if (progress == null || progress < 0 || progress > 100) {
                    return 'الرجاء إدخال نسبة صحيحة (0-100)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category Field
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  border: OutlineInputBorder(),
                  hintText: 'مثال: تطوير، تصميم، تعلم',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال الفئة';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Total Hours Spent Field
              TextFormField(
                controller: _totalHoursSpentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الساعات المقضية',
                  border: OutlineInputBorder(),
                  hintText: '0',
                ),
                validator: (value) {
                  final hours = int.tryParse(value ?? '');
                  if (hours == null || hours < 0) {
                    return 'الرجاء إدخال عدد ساعات صحيح';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  border: OutlineInputBorder(),
                  hintText: 'وصف مختصر للمشروع',
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('إضافة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProject() async {
    if (_formKey.currentState!.validate()) {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      
      try {
        final progress = double.tryParse(_progressController.text) ?? 0.0;
        final normalizedProgress = (progress / 100).clamp(0.0, 1.0);
        
        await projectProvider.addProject(
          name: _nameController.text.trim(),
          techStack: _techStackController.text.split(',').map((e) => e.trim()).toList(),
          weeklyHours: int.tryParse(_weeklyHoursController.text) ?? 40,
          status: ProjectStatus.active,
          progress: normalizedProgress,
          category: _categoryController.text.trim(),
          totalHoursSpent: int.tryParse(_totalHoursSpentController.text) ?? 0,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        );
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت إضافة المشروع'),
              backgroundColor: AppColors.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }
}
