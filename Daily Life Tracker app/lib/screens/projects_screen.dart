import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import '../utils/constants.dart';
import '../widgets/project_card.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';
  String _selectedSortBy = 'created';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Delay initialization to avoid setState() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProjects();
    });
  }

  Future<void> _initializeProjects() async {
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    await projectProvider.loadProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('المشاريع'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'نشط'),
            Tab(text: 'مكتملة'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث في المشاريع...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          
          // Projects List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProjectsList('all'),
                _buildProjectsList('active'),
                _buildProjectsList('completed'),
              ],
            ),
          ),
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
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        List filteredProjects = _getFilteredProjects(projectProvider.projects, filter);
        
        if (_searchController.text.isNotEmpty) {
          filteredProjects = filteredProjects.where((project) =>
            project.name.toLowerCase().contains(_searchController.text.toLowerCase())
          ).toList();
        }

        if (_selectedStatus != 'all') {
          filteredProjects = filteredProjects.where((project) {
            switch (_selectedStatus) {
              case 'active':
                return !project.isCompleted && project.status != ProjectStatus.paused;
              case 'completed':
                return project.isCompleted;
              case 'paused':
                return project.status == ProjectStatus.paused;
              default:
                return true;
            }
          }).toList();
        }

        // Apply sorting
        filteredProjects = _getSortedProjects(filteredProjects, _selectedSortBy);
        
        if (filteredProjects.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'لا توجد مشاريع',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
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
              child: ProjectCard(
                project: project,
                onTap: () => _showProjectDetails(project),
                onMorePressed: () => _showProjectOptions(project),
              ),
            );
          },
        );
      },
    );
  }

  List _getFilteredProjects(List projects, String filter) {
    switch (filter) {
      case 'active':
        return projects.where((project) => !project.isCompleted).toList();
      case 'completed':
        return projects.where((project) => project.isCompleted).toList();
      default:
        return projects;
    }
  }

  List _getSortedProjects(List projects, String sortBy) {
    List sortedProjects = List.from(projects);
    switch (sortBy) {
      case 'name':
        sortedProjects.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'progress':
        sortedProjects.sort((a, b) => (b.progress ?? 0.0).compareTo(a.progress ?? 0.0));
        break;
      case 'created':
      default:
        sortedProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sortedProjects;
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddProjectDialog(),
    );
  }

  void _showProjectOptions(Project project) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('تفاصيل المشروع'),
              onTap: () {
                Navigator.pop(context);
                _showProjectDetails(project);
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('تحديث التقدم'),
              onTap: () {
                Navigator.pop(context);
                _showProgressDialog(project);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('تعديل'),
              onTap: () {
                Navigator.pop(context);
                _showEditProjectDialog(project);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(project);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectDetails(Project project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryColor.withAlpha(26),
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
                          project.statusMessage ?? 'حالة غير محددة',
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
              
              // Progress Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التقدم',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(project.progress * 100).toInt()}% مكتمل',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showProgressDialog(project);
                      },
                      icon: const Icon(Icons.trending_up),
                      label: const Text('تحديث التقدم'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditProjectDialog(project);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('تعديل'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Delete Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(project);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('حذف المشروع', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProjectDialog(Project project) {
    showDialog(
      context: context,
      builder: (context) => _AddProjectDialog(project: project),
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
              Navigator.pop(context);
              Provider.of<ProjectProvider>(context, listen: false).deleteProject(project.id);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog(Project project) {
    final TextEditingController progressController = TextEditingController(
      text: (project.progress * 100).toInt().toString(),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحديث التقدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('نسبة الإنجاز (%):'),
            const SizedBox(height: 12),
            TextField(
              controller: progressController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final progress = double.tryParse(progressController.text) ?? 0.0;
              final normalizedProgress = (progress / 100).clamp(0.0, 1.0);
              
              Navigator.pop(context);
              Provider.of<ProjectProvider>(context, listen: false)
                  .updateProjectProgress(project.id, normalizedProgress);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
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
                  DropdownMenuItem(value: 'active', child: Text('نشط')),
                  DropdownMenuItem(value: 'completed', child: Text('مكتملة')),
                  DropdownMenuItem(value: 'paused', child: Text('متوقفة')),
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
}

class _AddProjectDialog extends StatefulWidget {
  final dynamic project;

  const _AddProjectDialog({this.project});

  @override
  State<_AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<_AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _techStackController = TextEditingController();
  final _weeklyHoursController = TextEditingController();
  final _progressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project.name;
      _techStackController.text = widget.project.techStack.join(', ');
      _weeklyHoursController.text = widget.project.weeklyHours.toString();
      _progressController.text = ((widget.project.progress ?? 0.0) * 100).toInt().toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _techStackController.dispose();
    _weeklyHoursController.dispose();
    _progressController.dispose();
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
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الساعات الأسبوعية';
                  }
                  final hours = int.tryParse(value);
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
                  labelText: 'التقدم المبدئي (%)',
                  border: OutlineInputBorder(),
                  suffixText: '%',
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
    debugPrint('=== _saveProject called ===');
    if (_formKey.currentState!.validate()) {
      debugPrint('Form validated successfully');
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      debugPrint('ProjectProvider obtained');
      
      try {
        final progress = double.tryParse(_progressController.text) ?? 0.0;
        final normalizedProgress = (progress / 100).clamp(0.0, 1.0);
        debugPrint('Progress: $normalizedProgress');
        
        if (widget.project == null) {
          debugPrint('Creating new project...');
          await projectProvider.addProject(
            name: _nameController.text.trim(),
            techStack: _techStackController.text.split(',').map((e) => e.trim()).toList(),
            weeklyHours: int.tryParse(_weeklyHoursController.text) ?? 40,
            status: ProjectStatus.active,
            progress: normalizedProgress,
            category: 'عام',
            totalHoursSpent: 0,
            description: null,
          );
          debugPrint('Project added successfully');
        } else {
          debugPrint('Updating existing project...');
          await projectProvider.updateProject(
            widget.project.copyWith(
              name: _nameController.text.trim(),
              progress: normalizedProgress,
            ),
          );
          debugPrint('Project updated successfully');
        }
        
        if (mounted) {
          debugPrint('Navigator popped');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.project == null ? 'تمت إضافة المشروع' : 'تم تعديل المشروع'),
              backgroundColor: AppColors.successColor,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error in _saveProject: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    } else {
      debugPrint('Form validation failed');
    }
  }
}
