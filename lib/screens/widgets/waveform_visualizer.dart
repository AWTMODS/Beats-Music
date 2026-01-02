import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveformVisualizer extends StatefulWidget {
  final Color color;
  final bool isPlaying;
  final double height;
  final double width;

  const WaveformVisualizer({
    Key? key,
    required this.color,
    this.isPlaying = false,
    this.height = 60,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = List.generate(30, (_) => 0.2 + 0.8 * math.Random().nextDouble());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) {
      return SizedBox(
        height: widget.height,
        width: widget.width,
        child: Center(
          child: Container(
            height: 2,
            width: widget.width * 0.8,
            color: widget.color.withOpacity(0.3),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: WaveformPainter(
            color: widget.color,
            animationValue: _controller.value,
            barHeights: _barHeights,
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Color color;
  final double animationValue;
  final List<double> barHeights;

  WaveformPainter({
    required this.color,
    required this.animationValue,
    required this.barHeights,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final barWidth = 4.0;
    final spacing = 6.0;
    final totalBars = barHeights.length;
    final totalWidth = totalBars * (barWidth + spacing);
    final startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < totalBars; i++) {
      final x = startX + i * (barWidth + spacing);
      
      // Calculate dynamic height based on animation and base height
      final baseHeight = barHeights[i] * size.height;
      final waveEffect = math.sin((animationValue * 2 * math.pi) + (i * 0.5)) * 0.3;
      final currentHeight = (baseHeight * (0.7 + waveEffect)).clamp(4.0, size.height);

      final top = (size.height - currentHeight) / 2;
      final bottom = top + currentHeight;

      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}
