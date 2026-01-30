import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/badge_model.dart';
import '../utils/constants.dart';

class BadgeWidget extends StatefulWidget {
  final BadgeModel badge;
  final double size;
  final VoidCallback? onTap;

  const BadgeWidget({
    Key? key,
    required this.badge,
    this.size = 80.0,
    this.onTap,
  }) : super(key: key);

  @override
  _BadgeWidgetState createState() => _BadgeWidgetState();
}

class _BadgeWidgetState extends State<BadgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.badge.isEarned) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      );

      _glowAnimation = Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.badge.isEarned) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: widget.badge.isEarned ? _glowAnimation : const AlwaysStoppedAnimation(0.0),
            builder: (context, child) {
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  gradient: LinearGradient(
                    colors: widget.badge.getGradientColors(),
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: widget.badge.getBadgeColor(),
                    width: 2,
                  ),
                  boxShadow: widget.badge.isEarned
                      ? [
                          BoxShadow(
                            color: widget.badge.color.withOpacity(
                              0.2 + (_glowAnimation.value * 0.3),
                            ),
                            blurRadius: 20 + (_glowAnimation.value * 10),
                            spreadRadius: 2 + (_glowAnimation.value * 2),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: widget.badge.iconUrl != null
                          ? ClipOval(
                              child: Image.network(
                                widget.badge.iconUrl!,
                                width: widget.size * 0.6,
                                height: widget.size * 0.6,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    widget.badge.icon,
                                    size: widget.size * 0.5,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              widget.badge.icon,
                              size: widget.size * 0.5,
                              color: Colors.white,
                            ),
                    ),
                    if (widget.badge.isEarned)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.successColor,
                          ),
                        ),
                      ),
                    if (!widget.badge.isEarned)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppBorderRadius.full),
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: Icon(
                            Icons.lock,
                            size: widget.size * 0.3,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            widget.badge.title,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: widget.badge.isEarned
                  ? widget.badge.color.withOpacity(0.1)
                  : (Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.gray700 
                      : AppColors.gray200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.badge.isEarned ? widget.badge.description : AppStrings.locked,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 10,
                color: widget.badge.isEarned
                    ? widget.badge.color
                    : (Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.gray400 
                        : AppColors.gray500),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
