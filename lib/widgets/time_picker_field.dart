import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../utils/constants.dart';

class TimePickerField extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onTimeSelected;

  const TimePickerField({
    Key? key,
    this.selectedTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? const TimeOfDay(hour: 20, minute: 0),
          builder: (context, child) {
            return Directionality(
              textDirection: ui.TextDirection.rtl,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  alwaysUse24HourFormat: false,
                ),
                child: child!,
              ),
            );
          },
        );

        if (picked != null) {
          onTimeSelected(picked);
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
                  selectedTime != null
                      ? DateFormat('h:mm a', 'ar').format(
                          DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          ),
                        )
                      : 'اختر وقت التذكير',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: selectedTime != null
                        ? theme.textTheme.bodyMedium?.color
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.access_time,
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
