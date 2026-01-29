import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../utils/constants.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const DatePickerField({
    Key? key,
    this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Directionality(
              textDirection: ui.TextDirection.rtl,
              child: child!,
            );
          },
        );

        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        height: 56.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  selectedDate != null
                      ? DateFormat('d MMMM yyyy', 'ar').format(selectedDate!)
                      : 'اختر الموعد النهائي',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: selectedDate != null
                        ? theme.textTheme.bodyMedium?.color
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.calendar_today,
                color: AppColors.primaryColor,
                size: AppSizes.iconDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
