import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ConicProgressIndicator extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;

  const ConicProgressIndicator({
    Key? key,
    required this.progress,
    this.size = 80.0,
    this.strokeWidth = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _BackgroundCirclePainter(
                color: theme.brightness == Brightness.dark 
                    ? AppColors.gray700
                    : AppColors.gray200,
                strokeWidth: strokeWidth,
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _ConicProgressPainter(
                progress: progress,
                color: theme.primaryColor,
                strokeWidth: strokeWidth,
              ),
            ),
          ),
          // Inner white/dark circle for donut effect
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? AppColors.gray800
                  : Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          // Percentage text
          Text(
            '${(progress * 100).toInt()}%',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _BackgroundCirclePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConicProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ConicProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [color, color.withOpacity(0.8)],
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + (2 * math.pi * progress),
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _ConicProgressPainter &&
        (oldDelegate.progress != progress || oldDelegate.color != color);
  }
}
