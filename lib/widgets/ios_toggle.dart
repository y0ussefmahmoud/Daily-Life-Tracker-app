import 'package:flutter/material.dart';
import '../utils/constants.dart';

class IosToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const IosToggle({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<IosToggle> createState() => _IosToggleState();
}

class _IosToggleState extends State<IosToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 16.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(IosToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
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
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        width: 40.0,
        height: 24.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: widget.value 
              ? AppColors.primaryColor 
              : AppColors.gray300,
        ),
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Padding(
              padding: EdgeInsets.only(right: 2.0 + _slideAnimation.value),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
