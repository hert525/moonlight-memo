import 'package:flutter/material.dart';

import '../constants.dart';

class LinedPaperPainter extends CustomPainter {
  LinedPaperPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double y = 26; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    final margin = Paint()
      ..color = kPurple.withAlpha(71)
      ..strokeWidth = 1.4;
    canvas.drawLine(const Offset(30, 0), Offset(30, size.height), margin);
  }

  @override
  bool shouldRepaint(covariant LinedPaperPainter oldDelegate) =>
      oldDelegate.color != color;
}
