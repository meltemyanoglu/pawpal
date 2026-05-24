import 'dart:math';
import 'package:flutter/material.dart';

/// Ambient floating particles (hearts, stars, paw prints) that drift
/// across the background for a living, magical feel.
class FloatingParticles extends StatefulWidget {
  final int count;
  const FloatingParticles({super.key, this.count = 12});

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;
  final _rng = Random();

  static const _emojis = ['🐾', '✨', '💖', '⭐', '🌸', '💫', '🩷', '🪽'];

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.count, (_) => _randomParticle());
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  _Particle _randomParticle() => _Particle(
        emoji: _emojis[_rng.nextInt(_emojis.length)],
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: 10 + _rng.nextDouble() * 12,
        speed: 0.08 + _rng.nextDouble() * 0.15,
        drift: (_rng.nextDouble() - 0.5) * 0.4,
        opacity: 0.12 + _rng.nextDouble() * 0.18,
        phase: _rng.nextDouble() * pi * 2,
      );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        // Advance particles
        for (final p in _particles) {
          p.y -= p.speed * 0.008;
          p.x += sin(p.phase + p.y * 6) * 0.0008 * p.drift;
          if (p.y < -0.05) {
            p.y = 1.05;
            p.x = _rng.nextDouble();
          }
        }

        return CustomPaint(
          painter: _ParticlePainter(_particles),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  String emoji;
  double x, y, size, speed, drift, opacity, phase;
  _Particle({
    required this.emoji,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.opacity,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final span = TextSpan(
        text: p.emoji,
        style: TextStyle(fontSize: p.size),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
        ..layout();
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      final paint = Paint()..color = Colors.white.withValues(alpha: p.opacity);
      canvas.saveLayer(Rect.fromLTWH(0, 0, tp.width, tp.height), paint);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}
