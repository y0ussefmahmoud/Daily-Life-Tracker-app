import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../widgets/category_chip.dart';
import '../widgets/tech_stack_input.dart';
import '../widgets/ios_toggle.dart';
import '../widgets/time_picker_field.dart';
import '../widgets/date_picker_field.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isTaskMode = true;
  String _taskName = '';
  String _projectName = '';
  String _selectedCategory = '';
  List<String> _techStack = [];
  TimeOfDay? _reminderTime;
  bool _isRepeating = false;
  DateTime? _deadline;
  bool _isSaving = false;
  
  // Validation state variables
  String? _taskNameError;
  String? _projectNameError;
  String? _categoryError;
  String? _techStackError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.cardTheme.color,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            AppStrings.addNew,
            style: GoogleFonts.tajawal(
              fontSize: AppTypography.titleLarge,
              fontWeight: AppTypography.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          centerTitle: true,
          actions: const [
            SizedBox(width: 48), // Spacer for symmetry
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                _buildHeroSection(theme),
                const SizedBox(height: AppSpacing.lg),
                
                // Segmented Control
                _buildSegmentedControl(theme, isDark),
                const SizedBox(height: AppSpacing.xl),
                
                // Task Form
                Visibility(
                  visible: _isTaskMode,
                  child: _buildTaskForm(theme, isDark),
                ),
                
                // Project Form
                Visibility(
                  visible: !_isTaskMode,
                  child: _buildProjectForm(theme, isDark),
                ),
                
                // Decorative Illustration
                const SizedBox(height: AppSpacing.xl),
                _buildDecorativeSection(theme),
                const SizedBox(height: 100), // Space for fixed button
              ],
            ),
          ),
        ),
        bottomSheet: _buildFixedSaveButton(theme),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.heroMessage,
          style: GoogleFonts.tajawal(
            fontSize: AppTypography.heading,
            fontWeight: AppTypography.bold,
            color: theme.textTheme.headlineSmall?.color,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.heroSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : AppColors.gray100,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isTaskMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: _isTaskMode 
                      ? AppColors.primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: Text(
                  AppStrings.addTask,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: AppTypography.body,
                    fontWeight: FontWeight.w600,
                    color: _isTaskMode 
                        ? AppColors.textLight 
                        : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isTaskMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: !_isTaskMode 
                      ? AppColors.primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: Text(
                  AppStrings.addProject,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: AppTypography.body,
                    fontWeight: FontWeight.w600,
                    color: !_isTaskMode 
                        ? AppColors.textLight 
                        : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskForm(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task Name Input
        Text(
          AppStrings.taskName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: AppSizes.inputHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: TextFormField(
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'مثال: قراءة ورد القرآن',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.required;
              }
              if (value.trim().length < 3) {
                return AppStrings.errorNameTooShort;
              }
              if (value.trim().length > 100) {
                return AppStrings.errorNameTooLong;
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _taskNameError = null;
              });
            },
            onSaved: (value) => _taskName = value ?? '',
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Category Selection
        Text(
          AppStrings.category,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_categoryError != null) ...[
          Text(
            _categoryError!,
            style: GoogleFonts.tajawal(
              fontSize: AppTypography.caption,
              color: AppColors.warningColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AppCategories.getAllCategories().map((category) {
              return Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: CategoryChip(
                  label: AppCategories.getCategoryLabel(category),
                  icon: AppCategories.getCategoryIcon(category),
                  isSelected: _selectedCategory == category,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _categoryError = null;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Reminder and Repeat Grid
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.reminderTime,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TimePickerField(
                    selectedTime: _reminderTime,
                    onTimeSelected: (time) => setState(() => _reminderTime = time),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.repeat,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        AppStrings.daily,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IosToggle(
                        value: _isRepeating,
                        onChanged: (value) => setState(() => _isRepeating = value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectForm(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Name Input
        Text(
          AppStrings.projectName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: AppSizes.inputHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: TextFormField(
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'تطبيق تتبع المهام',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.required;
              }
              if (value.trim().length < 3) {
                return AppStrings.errorNameTooShort;
              }
              if (value.trim().length > 100) {
                return AppStrings.errorNameTooLong;
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _projectNameError = null;
              });
            },
            onSaved: (value) => _projectName = value ?? '',
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Tech Stack Input
        Text(
          AppStrings.techStack,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_techStackError != null) ...[
          Text(
            _techStackError!,
            style: GoogleFonts.tajawal(
              fontSize: AppTypography.caption,
              color: AppColors.warningColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TechStackInput(
          techStack: _techStack,
          onAdd: (tech) {
            setState(() {
              _techStack.add(tech);
              _techStackError = null;
            });
          },
          onRemove: (tech) {
            setState(() {
              _techStack.remove(tech);
            });
          },
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Deadline Picker
        Text(
          AppStrings.deadline,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DatePickerField(
          selectedDate: _deadline,
          onDateSelected: (date) => setState(() => _deadline = date),
        ),
      ],
    );
  }

  Widget _buildDecorativeSection(ThemeData theme) {
    return Center(
      child: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor.withOpacity(0.05),
              AppColors.primaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.rocket_launch,
                size: 64,
                color: AppColors.primaryColor.withOpacity(0.4),
              ),
            ),
            Positioned(
              top: 20,
              right: 30,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.3),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 40,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedSaveButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.cardTheme.color?.withOpacity(0.8) ?? Colors.white.withOpacity(0.8),
            theme.cardTheme.color ?? Colors.white,
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            onTap: _isSaving ? null : _handleSave,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSaving)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Icon(
                      Icons.check_circle,
                      color: AppColors.textLight,
                      size: AppSizes.iconDefault,
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _isSaving 
                        ? 'جاري الحفظ...'
                        : (_isTaskMode ? AppStrings.saveTask : AppStrings.saveProject),
                    style: GoogleFonts.tajawal(
                      fontSize: AppTypography.title,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() async {
    // Clear previous errors
    setState(() {
      _taskNameError = null;
      _projectNameError = null;
      _categoryError = null;
      _techStackError = null;
    });

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    _formKey.currentState!.save();

    // Additional validation
    bool hasError = false;
    
    if (_isTaskMode && _selectedCategory.isEmpty) {
      setState(() => _categoryError = AppStrings.errorSelectCategory);
      hasError = true;
    }
    
    if (!_isTaskMode && _techStack.isEmpty) {
      setState(() => _techStackError = AppStrings.errorAddTechStack);
      hasError = true;
    }
    
    if (hasError) {
      HapticFeedback.lightImpact();
      return;
    }

    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      if (_isTaskMode) {
        final task = Task(
          title: _taskName.trim(),
          icon: AppCategories.getCategoryIcon(_selectedCategory),
          isCompleted: false,
          category: _selectedCategory,
          reminderTime: _reminderTime,
          isRepeating: _isRepeating,
        );

        await Provider.of<TaskProvider>(context, listen: false).addTask(task);
        
        HapticFeedback.mediumImpact();
        _showSuccessSnackBar('تمت إضافة المهمة بنجاح');
      } else {
        final project = Project(
          id: Provider.of<ProjectProvider>(context, listen: false).generateProjectId(),
          name: _projectName.trim(),
          progress: 0.0,
          techStack: _techStack,
          weeklyHours: 0,
          status: ProjectStatus.active,
          deadline: _deadline,
        );

        await Provider.of<ProjectProvider>(context, listen: false).addProject(project);
        
        HapticFeedback.mediumImpact();
        _showSuccessSnackBar('تمت إضافة المشروع بنجاح');
      }

      Navigator.pop(context);
    } catch (error) {
      HapticFeedback.heavyImpact();
      final errorMessage = handleSupabaseError(error);
      
      if (_isTaskMode) {
        showErrorSnackbar(context, AppStrings.errorSavingTask, onRetry: () => _handleSave());
      } else {
        showErrorSnackbar(context, AppStrings.errorSavingProject, onRetry: () => _handleSave());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.warningColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
      ),
    );
  }
}
