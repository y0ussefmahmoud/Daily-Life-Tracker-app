import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color? activeColor;
  final Color? checkColor;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.checkColor,
  }) : super(key: key);

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.primaryColor;
    final checkColor = widget.checkColor ?? AppColors.textLight;

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: Container(
        width: AppSizes.iconSmall,
        height: AppSizes.iconSmall,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.default_),
          border: Border.all(
            color: widget.value ? activeColor : AppColors.gray300,
            width: 2.0,
          ),
          color: widget.value ? activeColor : Colors.transparent,
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Icon(
            Icons.check,
            size: AppSizes.iconSmall - 4,
            color: checkColor,
          ),
        ),
      ),
    );
  }
}
