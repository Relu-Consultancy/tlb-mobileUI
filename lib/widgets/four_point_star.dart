import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A single filled 4-point star (sparkle) with concave sides between the four
/// outer points — one clean star, no secondary sparkle (unlike
/// `Icons.auto_awesome`, which renders a star plus a small twinkle). Used as the
/// ornament in the "Spotlight" and "Explore the Stage" section titles.
class FourPointStar extends StatelessWidget {
  final double size;
  final Color color;

  const FourPointStar({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _FourPointStarPainter(color)),
      );
}

class _FourPointStarPainter extends CustomPainter {
  final Color color;
  const _FourPointStarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double outer = size.width / 2;
    final double inner = outer * 0.30; // smaller = sharper points

    final Path path = Path();
    for (int i = 0; i < 4; i++) {
      final double outerA = -math.pi / 2 + i * math.pi / 2; // up, right, down, left
      final Offset op = Offset(
        cx + outer * math.cos(outerA),
        cy + outer * math.sin(outerA),
      );
      final double innerA = outerA + math.pi / 4;
      final Offset ip = Offset(
        cx + inner * math.cos(innerA),
        cy + inner * math.sin(innerA),
      );
      if (i == 0) {
        path.moveTo(op.dx, op.dy);
      } else {
        path.lineTo(op.dx, op.dy);
      }
      path.lineTo(ip.dx, ip.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_FourPointStarPainter oldDelegate) =>
      oldDelegate.color != color;
}
