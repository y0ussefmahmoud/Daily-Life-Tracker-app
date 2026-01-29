import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../models/project_model.dart';
import '../providers/project_provider.dart';
import '../utils/constants.dart';

class DashedBorder extends Border {
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const DashedBorder({
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    super.top = BorderSide.none,
    super.right = BorderSide.none,
    super.bottom = BorderSide.none,
    super.left = BorderSide.none,
  });

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection, BoxShape shape = BoxShape.rectangle, BorderRadius? borderRadius}) {
    assert(shape == BoxShape.rectangle);
    
    final paint = Paint()
      ..color = top.color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    if (borderRadius != null && borderRadius != BorderRadius.zero) {
      _paintDashedRoundedRect(canvas, rect, borderRadius.topLeft.x, paint);
    } else {
      _paintDashedRect(canvas, rect, paint);
    }
  }

  void _paintDashedRect(Canvas canvas, Rect rect, Paint paint) {
    final path = Path();
    double distance = 0.0;
    
    // Top edge
    _drawDashedLine(canvas, Offset(rect.left, rect.top), Offset(rect.right, rect.top), paint, distance);
    // Right edge
    _drawDashedLine(canvas, Offset(rect.right, rect.top), Offset(rect.right, rect.bottom), paint, distance);
    // Bottom edge
    _drawDashedLine(canvas, Offset(rect.right, rect.bottom), Offset(rect.left, rect.bottom), paint, distance);
    // Left edge
    _drawDashedLine(canvas, Offset(rect.left, rect.bottom), Offset(rect.left, rect.top), paint, distance);
  }

  void _paintDashedRoundedRect(Canvas canvas, Rect rect, double radius, Paint paint) {
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    
    double distance = 0.0;
    ui.PathMetrics pathMetrics = path.computeMetrics();
    
    for (ui.PathMetric pathMetric in pathMetrics) {
      double pathLength = pathMetric.length;
      while (distance < pathLength) {
        double start = distance;
        double end = (distance + dashWidth).clamp(0.0, pathLength);
        canvas.drawPath(
          pathMetric.extractPath(start, end),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double distance) {
    double totalDistance = (end - start).distance;
    double currentDistance = 0.0;
    
    while (currentDistance < totalDistance) {
      double segmentStart = currentDistance;
      double segmentEnd = (currentDistance + dashWidth).clamp(0.0, totalDistance);
      
      Offset segmentStartPoint = Offset.lerp(start, end, segmentStart / totalDistance)!;
      Offset segmentEndPoint = Offset.lerp(start, end, segmentEnd / totalDistance)!;
      
      canvas.drawLine(segmentStartPoint, segmentEndPoint, paint);
      
      currentDistance += dashWidth + dashSpace;
    }
  }
}

class PausedProjectCard extends StatelessWidget {
  final Project project;

  const PausedProjectCard({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: DashedBorder(
          strokeWidth: 1,
          dashWidth: 5,
          dashSpace: 3,
          top: BorderSide(color: AppColors.gray400.withOpacity(0.5)),
          right: BorderSide(color: AppColors.gray400.withOpacity(0.5)),
          bottom: BorderSide(color: AppColors.gray400.withOpacity(0.5)),
          left: BorderSide(color: AppColors.gray400.withOpacity(0.5)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Pause Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.gray400.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppBorderRadius.default_),
              ),
              child: Icon(
                Icons.pause,
                size: 20,
                color: AppColors.gray600,
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Project Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.titleMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    project.statusMessage ?? 'متوقف',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.gray500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Resume Button
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                if (project.id == null) return;
                context.read<ProjectProvider>().toggleProjectStatus(project.id!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor.withOpacity(0.8),
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
              ),
              child: Text(
                'استئناف',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
