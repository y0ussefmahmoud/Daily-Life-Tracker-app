import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../utils/constants.dart';

class CustomCircularProgress extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const CustomCircularProgress({
    Key? key,
    required this.progress,
    this.size = 64.0,
    this.strokeWidth = 4.0,
    this.progressColor,
    this.backgroundColor,
    this.showPercentage = true,
    this.percentageStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final progressColor = this.progressColor ?? AppColors.primaryColor;
    final backgroundColor = this.backgroundColor ?? 
        (isDark ? AppColors.gray700 : AppColors.gray200);
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      tween: Tween(begin: 0.0, end: progress),
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: CircularProgressPainter(
                  progress: value,
                  strokeWidth: strokeWidth,
                  progressColor: progressColor,
                  backgroundColor: backgroundColor,
                ),
              ),
              if (showPercentage)
                Positioned.fill(
                  child: Center(
                    child: Text(
                      NumberFormat('###').format((value * 100).round()),
                      style: percentageStyle ?? theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -pi / 2; // Start from top
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
