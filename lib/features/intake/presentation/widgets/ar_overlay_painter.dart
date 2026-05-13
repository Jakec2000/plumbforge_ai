import 'package:flutter/material.dart';

class ArOverlayPainter extends CustomPainter {
  final List<Offset> points;
  final Color overlayColor;

  ArOverlayPainter({
    required this.points,
    this.overlayColor = const Color(0xFFF9A826), // AppTheme.highlightColor
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paintLine = Paint()
      ..color = overlayColor.withOpacity(0.8)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintNode = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    // Draw lines connecting the points to simulate pipe runs
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paintLine);
    }

    // Draw nodes at each point
    for (final point in points) {
      canvas.drawCircle(point, 8.0, paintNode);
      canvas.drawCircle(
        point,
        14.0,
        paintLine..strokeWidth = 2.0..color = overlayColor.withOpacity(0.5),
      );
    }
    
    // Draw crosshair in center to help user aim
    final center = Offset(size.width / 2, size.height / 2);
    final crosshairPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.0;
      
    canvas.drawLine(Offset(center.dx - 20, center.dy), Offset(center.dx + 20, center.dy), crosshairPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 20), Offset(center.dx, center.dy + 20), crosshairPaint);
  }

  @override
  bool shouldRepaint(covariant ArOverlayPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.overlayColor != overlayColor;
  }
}
