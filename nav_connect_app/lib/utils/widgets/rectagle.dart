import 'package:flutter/material.dart';

class DrawRectagle extends CustomPainter {
  final double top;
  final double left;
  final double right;
  final double bottom;

  DrawRectagle(
    this.left,
    this.top,
    this.right,
    this.bottom,
  );
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
        RRect.fromLTRBR(
          left,
          top,
          right,
          bottom,
          const Radius.circular(10),
        ),
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
