// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';
import '../widgets/category_chip.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Delay initialization to avoid setState() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTasks();
    });
  }

  Future<void> _initializeTasks() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.loadTasks();
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
        title: const Text('المهام'),
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
            Tab(text: 'قيد التنفيذ'),
            Tab(text: 'مكتملة'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث في المهام...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () => _showFilterDialog(),
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
                
                const SizedBox(height: 12),
                
                // Category Chips
                _buildCategoryChips(),
              ],
            ),
          ),
          
          // Tasks List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTasksList('all'),
                _buildTasksList('pending'),
                _buildTasksList('completed'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    return AppCategories.getCategoryIcon(category);
  }

  Widget _buildCategoryChips() {
    final categories = ['all', 'work', 'personal', 'study', 'sport', 'health'];
    final categoryLabels = {
      'all': 'الكل',
      'work': 'عمل', 
      'personal': 'شخصي',
      'study': 'دراسة',
      'sport': 'رياضة',
      'health': 'صحة',
    };
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryChip(
              label: categoryLabels[category] ?? category,
              icon: _getCategoryIcon(category),
              isSelected: _selectedCategory == category,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTasksList(String filter) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        List filteredTasks = _getFilteredTasks(taskProvider.tasks, filter);
        
        if (_searchController.text.isNotEmpty) {
          filteredTasks = taskProvider.searchTasks(_searchController.text);
        }
        
        if (_selectedCategory != 'الكل') {
          filteredTasks = filteredTasks.where((task) => task.category == _selectedCategory).toList();
        }
        
        if (filteredTasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'لا توجد مهام',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'اضغط على + لإضافة مهمة جديدة',
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
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: task.isCompleted 
                                  ? AppColors.gray400 
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                              decoration: task.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppCategories.getCategoryLabel(task.category),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.gray400,
                      ),
                      onSelected: (value) {
                        if (value == 'toggle') {
                          taskProvider.toggleTask(task.id);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(task);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                            task.isCompleted ? 'إلغاء الإنجاز' : 'إنجاز المهمة',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('حذف المهمة'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List _getFilteredTasks(List tasks, String filter) {
    switch (filter) {
      case 'pending':
        return tasks.where((task) => !task.isCompleted).toList();
      case 'completed':
        return tasks.where((task) => task.isCompleted).toList();
      default:
        return tasks;
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddTaskDialog(task: null),
    );
  }

  void _showDeleteConfirmation(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المهمة'),
        content: const Text('هل أنت متأكد من حذف هذه المهمة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (!context.mounted) return;
              await Provider.of<TaskProvider>(context, listen: false).loadTasks();
              if (!context.mounted) return;
              Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية المهام'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('الأولوية'),
              trailing: DropdownButton<String>(
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('الكل')),
                  DropdownMenuItem(value: 'high', child: Text('عالية')),
                  DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                  DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                ],
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ),
            ListTile(
              title: const Text('التاريخ'),
              trailing: DropdownButton<String>(
                items: const [
                  DropdownMenuItem(value: 'today', child: Text('اليوم')),
                  DropdownMenuItem(value: 'week', child: Text('هذا الأسبوع')),
                  DropdownMenuItem(value: 'month', child: Text('هذا الشهر')),
                  DropdownMenuItem(value: 'all', child: Text('الكل')),
                ],
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {});
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

class _AddTaskDialog extends StatefulWidget {
  final Task? task;

  const _AddTaskDialog({required this.task});

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
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _categoryController.text = widget.task!.category;
      _selectedPriority = widget.task!.priority.toString().split('.').last;
      _selectedIcon = IconData(widget.task!.iconCodePoint, fontFamily: 'MaterialIcons');
      _isRepeating = widget.task!.isRepeating;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
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
                widget.task == null ? 'إضافة مهمة جديدة' : 'تعديل المهمة',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
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
              Text(
                'الأيقونة',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final icons = [
                      Icons.task,
                      Icons.work,
                      Icons.school,
                      Icons.fitness_center,
                      Icons.local_hospital,
                      Icons.shopping_cart,
                      Icons.home,
                      Icons.phone,
                    ];
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
                title: const Text('مهمة متكررة'),
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
                      child: Text(widget.task == null ? 'إضافة' : 'حفظ'),
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

  void _saveTask() async {
    debugPrint('=== _saveTask called ===');
    if (_formKey.currentState!.validate()) {
      debugPrint('Form validated successfully');
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      debugPrint('TaskProvider obtained');
      
      try {
        if (widget.task == null) {
          debugPrint('Creating new task...');
          final newTask = Task(
            id: const Uuid().v4(),
            title: _titleController.text.trim(),
            category: _categoryController.text.trim(),
            iconCodePoint: _selectedIcon.codePoint,
            priority: _getPriorityFromString(_selectedPriority),
            isRepeating: _isRepeating,
            createdAt: DateTime.now(),
          );
          debugPrint('Task created: ${newTask.title}');
          debugPrint('Calling taskProvider.addTask...');
          await taskProvider.addTask(
            title: newTask.title,
            category: newTask.category,
            icon: _selectedIcon,
            priority: newTask.priority,
            reminderTime: null,
            isRepeating: newTask.isRepeating,
          );
          debugPrint('Task added successfully');
        } else {
          debugPrint('Updating existing task...');
          await taskProvider.updateTask(
            widget.task!.copyWith(
              title: _titleController.text.trim(),
              category: _categoryController.text.trim(),
              iconCodePoint: _selectedIcon.codePoint,
              priority: _getPriorityFromString(_selectedPriority),
              isRepeating: _isRepeating,
            ),
          );
          debugPrint('Task updated successfully');
        }
        
        if (mounted) {
          debugPrint('Navigator popped');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.task == null ? 'تمت إضافة المهمة' : 'تم تعديل المهمة'),
              backgroundColor: AppColors.successColor,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error in _saveTask: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    } else {
      debugPrint('Form validation failed');
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
