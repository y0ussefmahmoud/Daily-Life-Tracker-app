import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TechStackInput extends StatefulWidget {
  final List<String> techStack;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const TechStackInput({
    Key? key,
    required this.techStack,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<TechStackInput> createState() => _TechStackInputState();
}

class _TechStackInputState extends State<TechStackInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTech() {
    final tech = _controller.text.trim();
    if (tech.isNotEmpty && !widget.techStack.contains(tech)) {
      widget.onAdd(tech);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display existing tech stack tags
        if (widget.techStack.isNotEmpty)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: widget.techStack.map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tech,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    GestureDetector(
                      onTap: () => widget.onRemove(tech),
                      child: Icon(
                        Icons.close,
                        size: AppSizes.iconSmall,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Input field for adding new tech
        Container(
          height: AppSizes.inputHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            border: Border.all(
              color: theme.brightness == Brightness.dark 
                  ? AppColors.borderDark 
                  : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'أضف تقنية جديدة...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              prefixIcon: Icon(
                Icons.add,
                color: AppColors.primaryColor,
                size: AppSizes.iconSmall,
              ),
            ),
            onSubmitted: (_) => _addTech(),
          ),
        ),
      ],
    );
  }
}
