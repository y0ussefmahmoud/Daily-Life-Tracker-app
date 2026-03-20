import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/projects_provider.dart';
import '../models/project_model.dart';
import '../constants/app_colors.dart';
import 'package:intl/intl.dart';

class ProjectsManagerScreen extends StatefulWidget {
  const ProjectsManagerScreen({super.key});

  @override
  State<ProjectsManagerScreen> createState() => _ProjectsManagerScreenState();
}

class _ProjectsManagerScreenState extends State<ProjectsManagerScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'all';
  String _selectedSortBy = 'created';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('إدارة المشاريع'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'قيد التنفيذ'),
            Tab(text: 'متوقف'),
            Tab(text: 'مكتمل'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProjectsList('all'),
          _buildProjectsList('in_progress'),
          _buildProjectsList('paused'),
          _buildProjectsList('completed'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProjectsList(String filter) {
    return Consumer<ProjectsProvider>(
      builder: (context, projectsProvider, child) {
        List<Project> filteredProjects = _getFilteredProjects(projectsProvider.projects, filter);

        // Apply additional filters
        if (_selectedStatus != 'all') {
          filteredProjects = filteredProjects.where((project) {
            switch (_selectedStatus) {
              case 'in_progress':
                return project.status == ProjectStatus.inProgress;
              case 'paused':
                return project.status == ProjectStatus.paused;
              case 'completed':
                return project.isCompleted;
              default:
                return true;
            }
          }).toList();
        }

        // Apply sorting
        filteredProjects = _getSortedProjects(filteredProjects, _selectedSortBy);

        if (filteredProjects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyIcon(filter),
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(filter),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اضغط على + لإضافة مشروع جديد',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredProjects.length,
          itemBuilder: (context, index) {
            final project = filteredProjects[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildProjectCard(project),
            );
          },
        );
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showProjectDetails(project),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status).withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getProjectIcon(project.category),
                      color: _getStatusColor(project.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getCategoryDisplayName(project.category),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                    ),
                    onSelected: (value) => _handleProjectAction(project, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: Text('تفاصيل'),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('تعديل'),
                      ),
                      const PopupMenuItem(
                        value: 'time_track',
                        child: Text('تتبع الوقت'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('حذف'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التقدم',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${project.progress.toInt()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: project.progress / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(project.status)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Footer Info
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${project.totalHoursSpent} ساعة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd').format(project.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              // Tech Stack
              if (project.techStack.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: project.techStack.take(3).map((tech) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tech,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Project> _getFilteredProjects(List<Project> projects, String filter) {
    switch (filter) {
      case 'in_progress':
        return projects.where((project) => project.status == ProjectStatus.inProgress).toList();
      case 'paused':
        return projects.where((project) => project.status == ProjectStatus.paused).toList();
      case 'completed':
        return projects.where((project) => project.isCompleted).toList();
      default:
        return projects;
    }
  }

  List<Project> _getSortedProjects(List<Project> projects, String sortBy) {
    final sortedProjects = List<Project>.from(projects);
    switch (sortBy) {
      case 'name':
        sortedProjects.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'progress':
        sortedProjects.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'hours':
        sortedProjects.sort((a, b) => b.totalHoursSpent.compareTo(a.totalHoursSpent));
        break;
      case 'created':
      default:
        sortedProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sortedProjects;
  }

  void _handleProjectAction(Project project, String action) {
    switch (action) {
      case 'details':
        _showProjectDetails(project);
        break;
      case 'edit':
        _showEditProjectDialog(project);
        break;
      case 'time_track':
        _showTimeTrackingDialog(project);
        break;
      case 'delete':
        _showDeleteConfirmation(project);
        break;
    }
  }

  void _showProjectDetails(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(project: project),
      ),
    );
  }

  void _showTimeTrackingDialog(Project project) {
    showDialog(
      context: context,
      builder: (context) => TimeTrackingDialog(project: project),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية المشاريع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('الحالة'),
              trailing: DropdownButton<String>(
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('الكل')),
                  DropdownMenuItem(value: 'in_progress', child: Text('قيد التنفيذ')),
                  DropdownMenuItem(value: 'paused', child: Text('متوقف')),
                  DropdownMenuItem(value: 'completed', child: Text('مكتمل')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('الترتيب'),
              trailing: DropdownButton<String>(
                value: _selectedSortBy,
                items: const [
                  DropdownMenuItem(value: 'created', child: Text('تاريخ الإنشاء')),
                  DropdownMenuItem(value: 'name', child: Text('الاسم')),
                  DropdownMenuItem(value: 'progress', child: Text('التقدم')),
                  DropdownMenuItem(value: 'hours', child: Text('الساعات')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSortBy = value;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddProjectDialog(),
    );
  }

  void _showEditProjectDialog(Project project) {
    showDialog(
      context: context,
      builder: (context) => AddProjectDialog(project: project),
    );
  }

  void _showDeleteConfirmation(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المشروع'),
        content: const Text('هل أنت متأكد من حذف هذا المشروع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ProjectsProvider>(context, listen: false).deleteProject(project.id);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getProjectIcon(String category) {
    switch (category.toLowerCase()) {
      case 'flutter':
        return Icons.phone_android;
      case 'web':
        return Icons.web;
      case 'backend':
        return Icons.storage;
      case 'mobile':
        return Icons.smartphone;
      case 'desktop':
        return Icons.computer;
      default:
        return Icons.work;
    }
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.paused:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'flutter':
        return 'Flutter App';
      case 'web':
        return 'Website';
      case 'backend':
        return 'Backend';
      case 'mobile':
        return 'Mobile App';
      case 'desktop':
        return 'Desktop App';
      case 'hardware':
        return 'Hardware';
      default:
        return category;
    }
  }

  IconData _getEmptyIcon(String filter) {
    switch (filter) {
      case 'in_progress':
        return Icons.play_arrow;
      case 'paused':
        return Icons.pause;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.work;
    }
  }

  String _getEmptyMessage(String filter) {
    switch (filter) {
      case 'in_progress':
        return 'لا توجد مشاريع قيد التنفيذ';
      case 'paused':
        return 'لا توجد مشاريع متوقفة';
      case 'completed':
        return 'لا توجد مشاريع مكتملة';
      default:
        return 'لا توجد مشاريع';
    }
  }
}

// Project Details Screen
class ProjectDetailsScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(project.name),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.work,
                          color: AppColors.primaryColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              project.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress
                  LinearProgressIndicator(
                    value: project.progress / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${project.progress.toInt()}% مكتمل',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Time Stats
            Text(
              'إحصائيات الوقت',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeStat('إجمالي الساعات', '${project.totalHoursSpent}'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeStat('الأسبوع الحالي', '12.5'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tech Stack
            if (project.techStack.isNotEmpty) ...[
              Text(
                'التقنيات المستخدمة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: project.techStack.map((tech) {
                  return Chip(
                    label: Text(tech),
                    backgroundColor: Colors.blue.shade50,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeStat(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// Time Tracking Dialog
class TimeTrackingDialog extends StatefulWidget {
  final Project project;

  const TimeTrackingDialog({super.key, required this.project});

  @override
  State<TimeTrackingDialog> createState() => _TimeTrackingDialogState();
}

class _TimeTrackingDialogState extends State<TimeTrackingDialog> {
  bool _isTracking = false;
  DateTime? _startTime;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تتبع الوقت - ${widget.project.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الوقت المسجل: ${widget.project.totalHoursSpent} ساعة',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _toggleTracking,
            icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
            label: Text(_isTracking ? 'إيقاف التتبع' : 'بدء التتبع'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isTracking ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  void _toggleTracking() {
    setState(() {
      if (_isTracking) {
        // Stop tracking
        if (_startTime != null) {
          final duration = DateTime.now().difference(_startTime!);
          final hours = duration.inMinutes / 60.0;
          // Update project hours (this would need to be implemented in provider)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تسجيل ${hours.toStringAsFixed(1)} ساعة')),
          );
        }
        _isTracking = false;
        _startTime = null;
      } else {
        // Start tracking
        _isTracking = true;
        _startTime = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('بدأ تتبع الوقت')),
        );
      }
    });
  }
}

// Add Project Dialog
class AddProjectDialog extends StatefulWidget {
  final Project? project;

  const AddProjectDialog({super.key, this.project});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _techStackController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weeklyHoursController = TextEditingController(text: '40');
  final _progressController = TextEditingController(text: '0');
  String _selectedCategory = 'flutter';
  int _priority = 3;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _techStackController.text = widget.project!.techStack.join(', ');
      _descriptionController.text = widget.project!.description ?? '';
      _selectedCategory = widget.project!.category;
      _priority = widget.project!.priority;
      _weeklyHoursController.text = widget.project!.weeklyHours.toString();
      _progressController.text = (widget.project!.progress * 100).toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _techStackController.dispose();
    _descriptionController.dispose();
    _weeklyHoursController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.project == null ? 'إضافة مشروع جديد' : 'تعديل المشروع',
                style: const TextStyle(
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

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'flutter', child: Text('Flutter App')),
                  DropdownMenuItem(value: 'web', child: Text('Website')),
                  DropdownMenuItem(value: 'backend', child: Text('Backend')),
                  DropdownMenuItem(value: 'mobile', child: Text('Mobile App')),
                  DropdownMenuItem(value: 'desktop', child: Text('Desktop App')),
                  DropdownMenuItem(value: 'hardware', child: Text('Hardware')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Tech Stack Field
              TextFormField(
                controller: _techStackController,
                decoration: const InputDecoration(
                  labelText: 'التقنيات (افصل بفاصلة)',
                  border: OutlineInputBorder(),
                  hintText: 'Flutter, Firebase, Node.js',
                ),
              ),

              const SizedBox(height: 16),

              // Priority Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الأولوية: $_priority/5'),
                  Slider(
                    value: _priority.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _priority.toString(),
                    onChanged: (value) {
                      setState(() {
                        _priority = value.toInt();
                      });
                    },
                  ),
                ],
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
                      child: Text(widget.project == null ? 'إضافة' : 'حفظ'),
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
      final techStack = _techStackController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);

      if (widget.project == null) {
        // Add new project
        final progress = double.tryParse(_progressController.text) ?? 0.0;
        final normalizedProgress = (progress / 100).clamp(0.0, 1.0);
        
        await projectsProvider.addProject(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          techStack: techStack,
          weeklyHours: int.tryParse(_weeklyHoursController.text) ?? 40,
          totalHoursSpent: 0, // Default for new projects
          progress: normalizedProgress,
          status: ProjectStatus.inProgress,
          description: _descriptionController.text.trim(),
        );
      } else {
        // Update existing project
        await projectsProvider.updateProject(
          widget.project!.copyWith(
            name: _nameController.text.trim(),
            category: _selectedCategory,
            techStack: techStack,
            weeklyHours: int.tryParse(_weeklyHoursController.text) ?? widget.project!.weeklyHours,
            totalHoursSpent: widget.project!.totalHoursSpent,
            progress: (double.tryParse(_progressController.text) ?? (widget.project!.progress * 100)) / 100,
            description: _descriptionController.text.trim(),
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.project == null ? 'تمت إضافة المشروع' : 'تم تعديل المشروع'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
  }
}
