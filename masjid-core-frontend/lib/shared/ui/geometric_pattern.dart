import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A faint Islamic eight-pointed star lattice (two squares turned 45° with
/// a small rosette inside), tiled across the area. It sits behind hero
/// cards and the welcome screens: decoration only, never information.
class GeometricPattern extends StatelessWidget {
  const GeometricPattern({
    super.key,
    this.color = Colors.white,
    this.opacity = 0.09,
    this.cell = 56,
  });

  final Color color;
  final double opacity;

  /// Width of one star tile in logical pixels.
  final double cell;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _StarLatticePainter(
            color: color.withValues(alpha: opacity),
            cell: cell,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _StarLatticePainter extends CustomPainter {
  _StarLatticePainter({required this.color, required this.cell});

  final Color color;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final dot = Paint()..color = color;
    final r = cell * 0.36;
    final columns = (size.width / cell).ceil() + 1;
    final rows = (size.height / cell).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        // Offset every other row by half a tile, like a tiled wall.
        final center = Offset(
          col * cell + (row.isOdd ? cell / 2 : 0),
          row * cell,
        );
        _star(canvas, center, r, stroke);
        _star(canvas, center, r * 0.45, stroke, turn: math.pi / 8);
        canvas.drawCircle(center, 1.6, dot);
      }
    }
  }

  /// Two overlapping squares = an eight-pointed star (Rub el Hizb shape).
  void _star(
    Canvas canvas,
    Offset c,
    double r,
    Paint paint, {
    double turn = 0,
  }) {
    for (final start in <double>[turn, turn + math.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = start + i * math.pi / 2;
        final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StarLatticePainter old) =>
      old.color != color || old.cell != cell;
}
