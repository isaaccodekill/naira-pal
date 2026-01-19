import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutSection {
  final double value;
  final Color color;

  const DonutSection({required this.value, required this.color});
}

class RoundedDonutChart extends StatelessWidget {
  final List<DonutSection> sections;
  final double size;
  final double strokeWidth;
  final Widget? centerWidget;
  final double animationValue;

  const RoundedDonutChart({
    super.key,
    required this.sections,
    this.size = 200,
    this.strokeWidth = 24,
    this.centerWidget,
    this.animationValue = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RoundedDonutPainter(
              sections: sections,
              strokeWidth: strokeWidth,
              animationValue: animationValue,
            ),
          ),
          if (centerWidget != null) centerWidget!,
        ],
      ),
    );
  }
}

class _RoundedDonutPainter extends CustomPainter {
  final List<DonutSection> sections;
  final double strokeWidth;
  final double animationValue;

  _RoundedDonutPainter({
    required this.sections,
    required this.strokeWidth,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Calculate total
    final total = sections.fold<double>(0, (sum, s) => sum + s.value);
    if (total == 0) return;

    // Gap between sections in radians
    final gapAngle = sections.length > 1 ? 0.08 : 0.0;
    final totalGapAngle = gapAngle * sections.length;
    final availableAngle = 2 * math.pi - totalGapAngle;

    double startAngle = -math.pi / 2; // Start from top

    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      final sweepAngle = (section.value / total) * availableAngle * animationValue;

      if (sweepAngle > 0.01) {
        final paint = Paint()
          ..color = section.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }

      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _RoundedDonutPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.sections != sections;
  }
}
