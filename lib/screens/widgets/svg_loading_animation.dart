import 'dart:math' as math;
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A native, high-performance Flutter loading indicator that faithfully reproduces
/// the animated SVG music-note and orbiting ring with sparkling accents.
class SvgLoadingAnimation extends StatefulWidget {
  const SvgLoadingAnimation({
    super.key,
    this.size = 120.0,
    this.primaryColor,
    this.accentColor,
  });

  final double size;
  final Color? primaryColor;
  final Color? accentColor;

  @override
  State<SvgLoadingAnimation> createState() => _SvgLoadingAnimationState();
}

class _SvgLoadingAnimationState extends State<SvgLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor ?? const Color(0xFF8247FF);
    final secondary = widget.accentColor ?? Default_Theme.accentColor2;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SvgLoadingPainter(
              progress: _controller.value,
              primaryColor: primary,
              secondaryColor: secondary,
            ),
          );
        },
      ),
    );
  }
}

class _SvgLoadingPainter extends CustomPainter {
  _SvgLoadingPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 100.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    // ── 1. Rotating Outer Ring ───────────────────────────────────────────────
    // SVG: <ellipse ry="32" rx="32" stroke-width="6" stroke="#8247ff" />
    const ringRadius = 32.0;
    final ringRotation = progress * 2 * math.pi;

    canvas.save();
    canvas.rotate(ringRotation);

    final ringPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    // Draw swept arc corresponding to animated stroke-dasharray
    final sweepAngle = math.pi * (0.8 + 0.4 * math.sin(progress * 2 * math.pi));
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: ringRadius),
      -math.pi / 2,
      sweepAngle,
      false,
      ringPaint,
    );

    // Subtle background track
    final trackPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(Offset.zero, ringRadius, trackPaint);

    canvas.restore();

    // ── 2. Bouncing Musical Note (Double Eighth Note) ─────────────────────────
    // Recreated from user's exact SVG path coordinates:
    // Path: M10.866,-15.565 C10.866,-15.565,-2.194,-11.405...
    final bounce = math.sin(progress * 2 * math.pi) * 3.5;
    final noteScale = 0.95 + 0.05 * math.cos(progress * 2 * math.pi);

    canvas.save();
    canvas.translate(0, 1.5 + bounce);
    canvas.scale(noteScale);

    final notePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final notePath = Path();
    // Beamed Eighth Note accurately plotted from the SVG path definition
    notePath.moveTo(10.866, -15.565);
    notePath.lineTo(-2.194, -11.405);
    notePath.cubicTo(-3.784, -10.935, -5.054, -9.235, -5.054, -7.585);
    notePath.lineTo(-4.944, 9.035);
    notePath.cubicTo(-5.959, 8.338, -8.004, 8.875, -8.004, 8.875);
    notePath.cubicTo(-11.099, 9.687, -13.587, 12.17, -13.587, 14.76);
    notePath.cubicTo(-13.587, 17.35, -11.017, 19.236, -7.977, 18.48);
    notePath.cubicTo(-4.787, 17.687, -2.634, 14.75, -2.634, 12.675);
    notePath.lineTo(-2.744, -2.055);
    notePath.cubicTo(-2.744, -3.195, -1.434, -3.685, -1.434, -3.685);
    notePath.lineTo(10.116, -7.445);
    notePath.cubicTo(10.116, -7.445, 11.416, -7.895, 11.416, -6.665);
    notePath.lineTo(11.526, 5.635);
    notePath.cubicTo(10.298, 4.691, 8.226, 5.205, 8.226, 5.205);
    notePath.cubicTo(5.026, 6.0, 2.643, 8.39, 2.643, 10.98);
    notePath.cubicTo(2.643, 13.57, 5.215, 15.505, 8.253, 14.82);
    notePath.cubicTo(11.338, 14.125, 13.836, 11.125, 13.836, 9.055);
    notePath.lineTo(13.726, -13.425);
    notePath.cubicTo(13.726, -15.075, 12.446, -16.035, 10.866, -15.565);
    notePath.close();

    canvas.drawPath(notePath, notePaint);
    canvas.restore();

    // ── 3. Orbiting Sparkle Star ─────────────────────────────────────────────
    // SVG sparkle star at translate(60.247, 36.744) -> relative to center: (10.247, -13.256)
    final starAngle = progress * 2 * math.pi;
    final starScale = 0.8 + 0.3 * math.sin(progress * 4 * math.pi);

    canvas.save();
    canvas.translate(12.0, -14.0);
    canvas.rotate(starAngle);
    canvas.scale(starScale);

    final starPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // 4-point sparkle star from SVG coordinates
    final starPath = Path();
    starPath.moveTo(-0.946, -6.296);
    starPath.cubicTo(-0.636, -7.186, 0.634, -7.186, 0.944, -6.296);
    starPath.lineTo(1.854, -3.696);
    starPath.cubicTo(2.154, -2.836, 2.834, -2.156, 3.694, -1.856);
    starPath.lineTo(6.294, -0.946);
    starPath.cubicTo(7.194, -0.636, 7.194, 0.634, 6.294, 0.944);
    starPath.lineTo(3.694, 1.854);
    starPath.cubicTo(2.834, 2.154, 2.154, 2.834, 1.854, 3.694);
    starPath.lineTo(0.944, 6.294);
    starPath.cubicTo(0.634, 7.194, -0.636, 7.194, -0.946, 6.294);
    starPath.lineTo(-1.856, 3.694);
    starPath.cubicTo(-2.156, 2.834, -2.836, 2.154, -3.696, 1.854);
    starPath.lineTo(-6.296, 0.944);
    starPath.cubicTo(-7.186, 0.634, -7.186, -0.636, -6.296, -0.946);
    starPath.lineTo(-3.696, -1.856);
    starPath.cubicTo(-2.836, -2.156, -2.156, -2.836, -1.856, -3.696);
    starPath.close();

    canvas.drawPath(starPath, starPaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SvgLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
