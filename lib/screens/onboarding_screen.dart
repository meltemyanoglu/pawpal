import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../core/routes.dart';
import '../services/storage_service.dart';

// ── Renk paleti (köpek illüstrasyonlarından ilham) ───────────────────────────
const _cream = Color(0xFFF5EFE0);
const _coral = Color(0xFFE8634A);
const _pink = Color(0xFFF2A7B8);
const _green = Color(0xFF6B9E57);
const _navy = Color(0xFF1A1A2E);
const _gold = Color(0xFFF5C842);
const _lilac = Color(0xFFB8A9D9);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onStart() {
    if (StorageService.hasSelectedPet) {
      Navigator.pushReplacementNamed(context, Routes.main);
    } else {
      Navigator.pushReplacementNamed(context, Routes.petSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          // ── Groovy arka plan şekilleri ─────────────────────────────────────
          const Positioned.fill(child: _GroovyBackground()),

          // ── İçerik ────────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: SizedBox(
                  height: size.height,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 36),

                        // ── Üst etiket ─────────────────────────────────────
                        _GroovyChip(label: '🐾  Virtual Pet'),

                        const SizedBox(height: 24),

                        // ── Bold başlık ────────────────────────────────────
                        const Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: _navy,
                            fontFamily: 'Nunito',
                            letterSpacing: -2,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Let's meet your\nnew best friend.",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _navy,
                            fontFamily: 'Nunito',
                            height: 1.3,
                          ),
                        ),

                        const Spacer(),

                        // ── Hero illüstrasyon ──────────────────────────────
                        Center(child: _HeroIllustration()),

                        const Spacer(),

                        // ── Butonlar ───────────────────────────────────────
                        _SolidButton(
                          label: "Let's Go  →",
                          color: _navy,
                          textColor: _cream,
                          onTap: _onStart,
                        ),
                        const SizedBox(height: 12),

                        // Alt not
                        Center(
                          child: Text(
                            'Free · Ad-free · Adorable ✨',
                            style: TextStyle(
                              fontSize: 12,
                              color: _navy.withValues(alpha: 0.4),
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Groovy Arka Plan Şekilleri ────────────────────────────────────────────────

class _GroovyBackground extends StatelessWidget {
  const _GroovyBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GroovyPainter());
  }
}

class _GroovyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sağ üst — scalloped flower (büyük)
    _drawScallop(canvas, Offset(size.width + 10, -20), 90, _coral.withValues(alpha: 0.18), 10);

    // Sol alt — 4-nokta yıldız
    _draw4Star(canvas, Offset(-20, size.height * 0.72), 70, _pink.withValues(alpha: 0.25));

    // Sağ orta — küçük scallop
    _drawScallop(canvas, Offset(size.width * 0.88, size.height * 0.52), 44, _green.withValues(alpha: 0.20), 8);

    // Sol üst — blob/wavy circle
    _drawBlob(canvas, Offset(size.width * 0.08, size.height * 0.22), 36, _gold.withValues(alpha: 0.30));

    // Sağ alt köşe — scallop
    _drawScallop(canvas, Offset(size.width * 0.15, size.height * 0.91), 32, _lilac.withValues(alpha: 0.30), 7);

    // Küçük 4-yıldız sağ üst iç
    _draw4Star(canvas, Offset(size.width * 0.82, size.height * 0.14), 28, _coral.withValues(alpha: 0.22));

    // Nokta/artı işaretleri
    _drawPlus(canvas, Offset(size.width * 0.12, size.height * 0.42), 10, _green.withValues(alpha: 0.5));
    _drawPlus(canvas, Offset(size.width * 0.78, size.height * 0.62), 8, _coral.withValues(alpha: 0.4));
    _drawPlus(canvas, Offset(size.width * 0.55, size.height * 0.08), 7, _pink.withValues(alpha: 0.5));
  }

  void _drawScallop(Canvas canvas, Offset center, double size, Color color, int bumps) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    final r = size * 0.5;
    final bumpR = r * 0.18;

    for (int i = 0; i < bumps; i++) {
      final angle = (2 * pi * i / bumps) - pi / 2;
      final nextAngle = (2 * pi * (i + 1) / bumps) - pi / 2;
      if (i == 0) {
        path.moveTo(center.dx + r * cos(angle), center.dy + r * sin(angle));
      }
      path.arcToPoint(
        Offset(center.dx + r * cos(nextAngle), center.dy + r * sin(nextAngle)),
        radius: Radius.circular(bumpR * 1.1),
        clockwise: false,
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _draw4Star(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    final r = size * 0.5;
    final innerR = r * 0.35;

    for (int i = 0; i < 4; i++) {
      final outerAngle = (pi * 2 * i / 4) - pi / 4;
      final innerAngle1 = outerAngle + pi / 8;
      final innerAngle2 = outerAngle - pi / 8;

      final outerPt = Offset(center.dx + r * cos(outerAngle), center.dy + r * sin(outerAngle));
      final inner1 = Offset(center.dx + innerR * cos(innerAngle1), center.dy + innerR * sin(innerAngle1));
      final inner2 = Offset(center.dx + innerR * cos(innerAngle2), center.dy + innerR * sin(innerAngle2));

      if (i == 0) path.moveTo(inner2.dx, inner2.dy);
      path.quadraticBezierTo(outerPt.dx, outerPt.dy, inner1.dx, inner1.dy);

      final nextInnerAngle = (pi * 2 * (i + 1) / 4) - pi / 4 - pi / 8;
      final nextInner = Offset(
        center.dx + innerR * cos(nextInnerAngle),
        center.dy + innerR * sin(nextInnerAngle),
      );
      path.lineTo(nextInner.dx, nextInner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawBlob(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final r = size * 0.5;
    final path = Path()
      ..addOval(Rect.fromCenter(center: center, width: r * 1.6, height: r * 2.0));
    canvas.drawPath(path, paint);
  }

  void _drawPlus(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size * 0.22
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Hero İllüstrasyon ─────────────────────────────────────────────────────────

class _HeroIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Büyük renkli scallop shape (arka plan)
          CustomPaint(
            size: const Size(240, 240),
            painter: _ScallopShapePainter(color: _coral.withValues(alpha: 0.13), bumps: 12),
          ),
          // Orta daire
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pink.withValues(alpha: 0.18),
            ),
          ),
          // Lottie animasyonu
          ClipOval(
            child: SizedBox(
              width: 170,
              height: 170,
              child: Lottie.asset(
                'assets/animations/cat.json',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Text('🐱', style: TextStyle(fontSize: 100)),
                ),
              ),
            ),
          ),
          // Sağ üst mini dekorasyon
          Positioned(
            top: 12,
            right: 16,
            child: CustomPaint(
              size: const Size(40, 40),
              painter: _StarPainter(color: _gold),
            ),
          ),
          // Sol alt mini dekorasyon
          Positioned(
            bottom: 18,
            left: 20,
            child: CustomPaint(
              size: const Size(30, 30),
              painter: _StarPainter(color: _green.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scallop Shape Painter (hero arka planı için) ───────────────────────────────

class _ScallopShapePainter extends CustomPainter {
  final Color color;
  final int bumps;
  const _ScallopShapePainter({required this.color, required this.bumps});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.44;
    final bumpR = r * 0.12;
    final path = Path();

    for (int i = 0; i < bumps; i++) {
      final angle = (2 * pi * i / bumps) - pi / 2;
      final nextAngle = (2 * pi * (i + 1) / bumps) - pi / 2;
      if (i == 0) {
        path.moveTo(center.dx + r * cos(angle), center.dy + r * sin(angle));
      }
      path.arcToPoint(
        Offset(center.dx + r * cos(nextAngle), center.dy + r * sin(nextAngle)),
        radius: Radius.circular(bumpR),
        clockwise: false,
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── 4-Nokta Yıldız Painter ─────────────────────────────────────────────────────

class _StarPainter extends CustomPainter {
  final Color color;
  const _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.5;
    final inner = r * 0.35;
    final path = Path();

    for (int i = 0; i < 4; i++) {
      final outerA = (pi * 2 * i / 4) - pi / 4;
      final inner1A = outerA + pi / 8;
      final inner2A = outerA - pi / 8;

      final outerPt = Offset(center.dx + r * cos(outerA), center.dy + r * sin(outerA));
      final in1 = Offset(center.dx + inner * cos(inner1A), center.dy + inner * sin(inner1A));
      final in2 = Offset(center.dx + inner * cos(inner2A), center.dy + inner * sin(inner2A));

      if (i == 0) path.moveTo(in2.dx, in2.dy);
      path.quadraticBezierTo(outerPt.dx, outerPt.dy, in1.dx, in1.dy);

      final nextIn2A = (pi * 2 * (i + 1) / 4) - pi / 4 - pi / 8;
      path.lineTo(
        center.dx + inner * cos(nextIn2A),
        center.dy + inner * sin(nextIn2A),
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Groovy Chip ───────────────────────────────────────────────────────────────

class _GroovyChip extends StatelessWidget {
  final String label;
  const _GroovyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _navy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _navy.withValues(alpha: 0.12), width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _navy,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}

// ── Solid Button ──────────────────────────────────────────────────────────────

class _SolidButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _SolidButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_SolidButton> createState() => _SolidButtonState();
}

class _SolidButtonState extends State<_SolidButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: widget.textColor,
                fontFamily: 'Nunito',
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
