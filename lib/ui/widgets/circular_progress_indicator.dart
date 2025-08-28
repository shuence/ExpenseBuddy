import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import '../../core/constants/responsive_constants.dart';
import '../../core/constants/colors.dart';

class CircularProgressWidget extends StatelessWidget {
  final double percentage;
  final double? size;
  final double? strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final Widget? child;

  const CircularProgressWidget({
    super.key,
    required this.percentage,
    this.size,
    this.strokeWidth,
    this.progressColor = AppColors.primary,
    this.backgroundColor = AppColors.neutral300,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;
    
    final responsiveSize = size ?? _getResponsiveSize(isTablet, isDesktop);
    final responsiveStrokeWidth = strokeWidth ?? _getResponsiveStrokeWidth(isTablet, isDesktop);
    
    return SizedBox(
      width: responsiveSize,
      height: responsiveSize,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          percentage: percentage,
          strokeWidth: responsiveStrokeWidth,
          progressColor: progressColor,
          backgroundColor: backgroundColor,
        ),
        child: child,
      ),
    );
  }

  double _getResponsiveSize(bool isTablet, bool isDesktop) {
    if (isDesktop) return ResponsiveConstants.containerHeight120;
    if (isTablet) return 100.0;
    return ResponsiveConstants.containerHeight80;
  }

  double _getResponsiveStrokeWidth(bool isTablet, bool isDesktop) {
    if (isDesktop) return 10.0;
    if (isTablet) return 8.0;
    return ResponsiveConstants.spacing6;
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
