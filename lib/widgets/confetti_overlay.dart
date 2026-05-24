import 'dart:math';
import 'package:flutter/material.dart';

/// Full-screen confetti burst for celebrations (level-up, achievements, etc.)
class ConfettiOverlay extends StatefulWidget {
  final VoidCallback? onComplete;
  const ConfettiOverlay({super.key, this.onComplete});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_ConfettiPiece> _pieces;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _pieces = List.generate(60, (_) => _ConfettiPiece(
      x: _rng.nextDouble(),
      y: -_rng.nextDouble() * 0.3,
      vx: (_rng.nextDouble() - 0.5) * 2.5,
      vy: 1.5 + _rng.nextDouble() * 3.0,
      rotation: _rng.nextDouble() * pi * 2,
      rotSpeed: (_rng.nextDouble() - 0.5) * 8,
      size: 6 + _rng.nextDouble() * 8,
      color: _colors[_rng.nextInt(_colors.length)],
    ));

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      });
    _ctrl.forward();
  }

  static const _colors = [
    Color(0xFFFF8FAB), Color(0xFFFFD93D), Color(0xFFA8D8EA),
    Color(0xFFB5EAD7), Color(0xFFC3A8F5), Color(0xFFFF6B9D),
    Color(0xFFFFB800), Color(0xFF74C7F0),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _ConfettiPainter(_pieces, _ctrl.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ConfettiPiece {
  double x, y, vx, vy, rotation, rotSpeed, size;
  Color color;
  _ConfettiPiece({
    required this.x, required this.y, required this.vx, required this.vy,
    required this.rotation, required this.rotSpeed, required this.size,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double t;
  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - (t * t)).clamp(0.0, 1.0);
    if (opacity <= 0) return;

    for (final p in pieces) {
      final px = (p.x + p.vx * t * 0.15) * size.width;
      final py = (p.y + p.vy * t * 0.3) * size.height;
      final rot = p.rotation + p.rotSpeed * t;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rot);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // Draw a small rectangle confetti piece
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
          Radius.circular(p.size * 0.15),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
