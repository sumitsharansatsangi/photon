import 'package:flutter/material.dart';

class ProgressLine extends CustomPainter {
  final double pos;
  ProgressLine({required this.pos});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 10
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color.fromARGB(255, 24, 228, 218),
          Color.fromARGB(255, 15, 147, 255),
        ],
      ).createShader(rect)
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(10, 24), Offset(pos + 10, 24), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
