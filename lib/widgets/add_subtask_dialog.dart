import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/subtask_model.dart';
import '../providers/subtask_provider.dart';
import '../utils/constants.dart';

class AddSubTaskDialog extends StatefulWidget {
  final String projectId;

  const AddSubTaskDialog({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  State<AddSubTaskDialog> createState() => _AddSubTaskDialogState();
}

class _AddSubTaskDialogState extends State<AddSubTaskDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: theme.cardTheme.color,
        title: Text(
          'إضافة مهمة فرعية',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
          textDirection: TextDirection.rtl,
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Field
              Text(
                'عنوان المهمة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
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
                  controller: _titleController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'مثال: تصميم واجهة المستخدم',
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
                      return 'هذا الحقل مطلوب';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Priority Selection
              Text(
                'الأولوية',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = TaskPriority.high),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: _priority == TaskPriority.high
                              ? AppColors.warningColor.withOpacity(0.2)
                              : isDark
                                  ? AppColors.gray800
                                  : AppColors.gray100,
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          border: Border.all(
                            color: _priority == TaskPriority.high
                                ? AppColors.warningColor
                                : isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                            width: _priority == TaskPriority.high ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          'عالية',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.tajawal(
                            color: _priority == TaskPriority.high
                                ? AppColors.warningColor
                                : theme.textTheme.bodyMedium?.color,
                            fontWeight: _priority == TaskPriority.high
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = TaskPriority.medium),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: _priority == TaskPriority.medium
                              ? AppColors.primaryColor.withOpacity(0.2)
                              : isDark
                                  ? AppColors.gray800
                                  : AppColors.gray100,
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          border: Border.all(
                            color: _priority == TaskPriority.medium
                                ? AppColors.primaryColor
                                : isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                            width: _priority == TaskPriority.medium ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          'متوسطة',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.tajawal(
                            color: _priority == TaskPriority.medium
                                ? AppColors.primaryColor
                                : theme.textTheme.bodyMedium?.color,
                            fontWeight: _priority == TaskPriority.medium
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = TaskPriority.low),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: _priority == TaskPriority.low
                              ? AppColors.successColor.withOpacity(0.2)
                              : isDark
                                  ? AppColors.gray800
                                  : AppColors.gray100,
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          border: Border.all(
                            color: _priority == TaskPriority.low
                                ? AppColors.successColor
                                : isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                            width: _priority == TaskPriority.low ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          'منخفضة',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.tajawal(
                            color: _priority == TaskPriority.low
                                ? AppColors.successColor
                                : theme.textTheme.bodyMedium?.color,
                            fontWeight: _priority == TaskPriority.low
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveSubTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.textLight,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'إضافة',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w500),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSubTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final subTask = Subtask(
        title: _titleController.text.trim(),
        isCompleted: false,
        priority: _priority,
        projectId: widget.projectId,
      );

      await context.read<SubTaskProvider>().addSubTask(subTask);
      
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت إضافة المهمة الفرعية بنجاح',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ: ${e.toString()}',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: AppColors.warningColor,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
}
