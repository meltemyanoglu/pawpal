import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pet.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  Spotify-Pets-inspired flat illustration painters for each animal type.
//  Each painter draws a cute character that reacts to the pet's mood.
// ═══════════════════════════════════════════════════════════════════════════════

/// Main entry point — returns the correct painter widget for a pet.
class PetIllustration extends StatelessWidget {
  final PetType type;
  final PetMood mood;
  final double size;

  const PetIllustration({
    super.key,
    required this.type,
    required this.mood,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: switch (type) {
          PetType.cat => _CatPainter(mood),
          PetType.dog => _DogPainter(mood),
          PetType.bird => _BirdPainter(mood),
          PetType.hamster => _HamsterPainter(mood),
          PetType.iguana => _IguanaPainter(mood),
        },
      ),
    );
  }
}

// ── Helper mixins ────────────────────────────────────────────────────────────

mixin _EyeHelper {
  void drawEyes(
    Canvas canvas,
    Offset left,
    Offset right,
    double radius,
    PetMood mood,
  ) {
    final white = Paint()..color = Colors.white;
    final black = Paint()..color = const Color(0xFF2D2D2D);
    final pupilR = radius * 0.45;

    switch (mood) {
      case PetMood.sleeping:
        // Closed line eyes
        final p = Paint()
          ..color = const Color(0xFF2D2D2D)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawArc(
          Rect.fromCenter(center: left, width: radius * 2, height: radius),
          0, pi, false, p,
        );
        canvas.drawArc(
          Rect.fromCenter(center: right, width: radius * 2, height: radius),
          0, pi, false, p,
        );
      case PetMood.ecstatic:
        // Happy ^^ eyes
        final p = Paint()
          ..color = const Color(0xFF2D2D2D)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawArc(
          Rect.fromCenter(center: left, width: radius * 2, height: radius * 1.5),
          pi, pi, false, p,
        );
        canvas.drawArc(
          Rect.fromCenter(center: right, width: radius * 2, height: radius * 1.5),
          pi, pi, false, p,
        );
      case PetMood.sad:
        // Droopy round eyes with top cut
        canvas.drawCircle(left, radius, white);
        canvas.drawCircle(right, radius, white);
        canvas.drawCircle(left + Offset(0, 1), pupilR, black);
        canvas.drawCircle(right + Offset(0, 1), pupilR, black);
        // Sad eyebrows
        final brow = Paint()
          ..color = const Color(0xFF2D2D2D)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          left + Offset(-radius, -radius * 0.9),
          left + Offset(radius, -radius * 0.5),
          brow,
        );
        canvas.drawLine(
          right + Offset(-radius, -radius * 0.5),
          right + Offset(radius, -radius * 0.9),
          brow,
        );
      case PetMood.exhausted:
        // X eyes
        final p = Paint()
          ..color = const Color(0xFF2D2D2D)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        final s = radius * 0.7;
        canvas.drawLine(left + Offset(-s, -s), left + Offset(s, s), p);
        canvas.drawLine(left + Offset(s, -s), left + Offset(-s, s), p);
        canvas.drawLine(right + Offset(-s, -s), right + Offset(s, s), p);
        canvas.drawLine(right + Offset(s, -s), right + Offset(-s, s), p);
      default:
        // Normal big round eyes (neutral, happy)
        canvas.drawCircle(left, radius, white);
        canvas.drawCircle(right, radius, white);
        final outline = Paint()
          ..color = const Color(0xFF2D2D2D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(left, radius, outline);
        canvas.drawCircle(right, radius, outline);
        // Pupils — shift based on mood
        final shift = mood == PetMood.happy ? Offset(1, -1) : Offset.zero;
        canvas.drawCircle(left + shift, pupilR, black);
        canvas.drawCircle(right + shift, pupilR, black);
        // Highlight dot
        final highlight = Paint()..color = Colors.white;
        canvas.drawCircle(left + shift + Offset(-pupilR * 0.4, -pupilR * 0.4), pupilR * 0.35, highlight);
        canvas.drawCircle(right + shift + Offset(-pupilR * 0.4, -pupilR * 0.4), pupilR * 0.35, highlight);
    }
  }

  void drawShadow(Canvas canvas, Offset center, double rx, double ry) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  CAT — coral/red body, triangle ears, curved tail, whiskers
// ═══════════════════════════════════════════════════════════════════════════════

class _CatPainter extends CustomPainter with _EyeHelper {
  final PetMood mood;
  _CatPainter(this.mood);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final u = s.width / 100; // unit for scaling

    final body = Paint()..color = const Color(0xFFEF6C5B); // coral red
    final dark = Paint()..color = const Color(0xFF2D2D2D);
    final stripe = Paint()..color = const Color(0xFF2D2D2D)..strokeWidth = 2.5 * u..strokeCap = StrokeCap.round;
    final pink = Paint()..color = const Color(0xFFFF9B8E);

    // Shadow
    drawShadow(canvas, Offset(cx, cy + 32 * u), 28 * u, 6 * u);

    // Tail
    final tailPath = Path();
    if (mood == PetMood.ecstatic || mood == PetMood.happy) {
      tailPath.moveTo(cx + 25 * u, cy + 5 * u);
      tailPath.cubicTo(cx + 42 * u, cy - 15 * u, cx + 38 * u, cy - 35 * u, cx + 28 * u, cy - 40 * u);
    } else if (mood == PetMood.sad || mood == PetMood.exhausted) {
      tailPath.moveTo(cx + 25 * u, cy + 15 * u);
      tailPath.cubicTo(cx + 38 * u, cy + 20 * u, cx + 42 * u, cy + 28 * u, cx + 35 * u, cy + 30 * u);
    } else {
      tailPath.moveTo(cx + 25 * u, cy + 5 * u);
      tailPath.cubicTo(cx + 40 * u, cy - 5 * u, cx + 42 * u, cy - 25 * u, cx + 32 * u, cy - 30 * u);
    }
    canvas.drawPath(tailPath, Paint()..color = const Color(0xFFEF6C5B)..style = PaintingStyle.stroke..strokeWidth = 8 * u..strokeCap = StrokeCap.round);

    // Body (rounded sitting cat)
    final bodyPath = Path();
    bodyPath.addOval(Rect.fromCenter(center: Offset(cx, cy + 12 * u), width: 52 * u, height: 44 * u));
    canvas.drawPath(bodyPath, body);

    // Head
    canvas.drawCircle(Offset(cx, cy - 12 * u), 22 * u, body);

    // Ears (triangles)
    final earL = Path()
      ..moveTo(cx - 18 * u, cy - 28 * u)
      ..lineTo(cx - 10 * u, cy - 44 * u)
      ..lineTo(cx - 4 * u, cy - 24 * u)
      ..close();
    final earR = Path()
      ..moveTo(cx + 18 * u, cy - 28 * u)
      ..lineTo(cx + 10 * u, cy - 44 * u)
      ..lineTo(cx + 4 * u, cy - 24 * u)
      ..close();
    canvas.drawPath(earL, body);
    canvas.drawPath(earR, body);

    // Inner ear pink
    final earInL = Path()
      ..moveTo(cx - 16 * u, cy - 29 * u)
      ..lineTo(cx - 10 * u, cy - 40 * u)
      ..lineTo(cx - 6 * u, cy - 26 * u)
      ..close();
    final earInR = Path()
      ..moveTo(cx + 16 * u, cy - 29 * u)
      ..lineTo(cx + 10 * u, cy - 40 * u)
      ..lineTo(cx + 6 * u, cy - 26 * u)
      ..close();
    canvas.drawPath(earInL, pink);
    canvas.drawPath(earInR, pink);

    // Stripes on body
    canvas.drawLine(Offset(cx - 8 * u, cy + 2 * u), Offset(cx - 18 * u, cy + 8 * u), stripe);
    canvas.drawLine(Offset(cx - 6 * u, cy + 8 * u), Offset(cx - 16 * u, cy + 16 * u), stripe);
    canvas.drawLine(Offset(cx + 8 * u, cy + 2 * u), Offset(cx + 18 * u, cy + 8 * u), stripe);

    // Eyes
    drawEyes(
      canvas,
      Offset(cx - 8 * u, cy - 14 * u),
      Offset(cx + 8 * u, cy - 14 * u),
      5 * u,
      mood,
    );

    // Nose
    final nosePath = Path()
      ..moveTo(cx, cy - 5 * u)
      ..lineTo(cx - 3 * u, cy - 2 * u)
      ..lineTo(cx + 3 * u, cy - 2 * u)
      ..close();
    canvas.drawPath(nosePath, pink);

    // Whiskers
    final whisker = Paint()..color = const Color(0xFF2D2D2D)..strokeWidth = 1.2..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 5 * u, cy - 3 * u), Offset(cx - 22 * u, cy - 7 * u), whisker);
    canvas.drawLine(Offset(cx - 5 * u, cy - 1 * u), Offset(cx - 22 * u, cy + 1 * u), whisker);
    canvas.drawLine(Offset(cx + 5 * u, cy - 3 * u), Offset(cx + 22 * u, cy - 7 * u), whisker);
    canvas.drawLine(Offset(cx + 5 * u, cy - 1 * u), Offset(cx + 22 * u, cy + 1 * u), whisker);

    // Mouth
    if (mood == PetMood.ecstatic || mood == PetMood.happy) {
      final smile = Paint()
        ..color = const Color(0xFF2D2D2D)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: 10 * u, height: 6 * u),
        0, pi, false, smile,
      );
    }

    // Paws
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 12 * u, cy + 32 * u), width: 12 * u, height: 6 * u), dark);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 12 * u, cy + 32 * u), width: 12 * u, height: 6 * u), dark);
  }

  @override
  bool shouldRepaint(_CatPainter old) => old.mood != mood;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  DOG — white body, floppy ears, red collar, spots
// ═══════════════════════════════════════════════════════════════════════════════

class _DogPainter extends CustomPainter with _EyeHelper {
  final PetMood mood;
  _DogPainter(this.mood);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final u = s.width / 100;

    final white = Paint()..color = const Color(0xFFF5F0EB);
    final dark = Paint()..color = const Color(0xFF2D2D2D);
    final red = Paint()..color = const Color(0xFFEF6C5B);
    final spot = Paint()..color = const Color(0xFFEF6C5B).withValues(alpha: 0.7);

    // Shadow
    drawShadow(canvas, Offset(cx, cy + 34 * u), 30 * u, 6 * u);

    // Tail
    final tailP = Paint()..color = const Color(0xFFEF6C5B)..style = PaintingStyle.stroke..strokeWidth = 6 * u..strokeCap = StrokeCap.round;
    final tail = Path()..moveTo(cx + 22 * u, cy + 2 * u);
    if (mood == PetMood.ecstatic || mood == PetMood.happy) {
      tail.cubicTo(cx + 38 * u, cy - 20 * u, cx + 42 * u, cy - 40 * u, cx + 30 * u, cy - 42 * u);
    } else {
      tail.cubicTo(cx + 35 * u, cy - 5 * u, cx + 40 * u, cy - 18 * u, cx + 32 * u, cy - 25 * u);
    }
    canvas.drawPath(tail, tailP);

    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 10 * u), width: 50 * u, height: 40 * u), white);

    // Spots on body
    canvas.drawCircle(Offset(cx + 5 * u, cy + 8 * u), 6 * u, spot);

    // Head
    canvas.drawCircle(Offset(cx, cy - 12 * u), 24 * u, white);

    // Floppy ears (black)
    final earL = Path()
      ..moveTo(cx - 20 * u, cy - 18 * u)
      ..cubicTo(cx - 34 * u, cy - 22 * u, cx - 38 * u, cy - 5 * u, cx - 28 * u, cy + 5 * u);
    canvas.drawPath(earL, dark);
    final earR = Path()
      ..moveTo(cx + 20 * u, cy - 18 * u)
      ..cubicTo(cx + 34 * u, cy - 22 * u, cx + 38 * u, cy - 5 * u, cx + 28 * u, cy + 5 * u);
    canvas.drawPath(earR, dark);

    // Eye patch (black marking around left eye area, like in the reference)
    canvas.drawCircle(Offset(cx - 6 * u, cy - 18 * u), 10 * u, dark);

    // Eyes
    drawEyes(
      canvas,
      Offset(cx - 8 * u, cy - 16 * u),
      Offset(cx + 8 * u, cy - 16 * u),
      5.5 * u,
      mood,
    );

    // Red collar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 2 * u), width: 30 * u, height: 6 * u),
        Radius.circular(3 * u),
      ),
      red,
    );

    // Nose
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 5 * u), width: 8 * u, height: 5 * u),
      dark,
    );
    // Nose highlight
    canvas.drawCircle(Offset(cx - 1.5 * u, cy - 6 * u), 1.5 * u, Paint()..color = Colors.white.withValues(alpha: 0.5));

    // Mouth
    if (mood == PetMood.ecstatic || mood == PetMood.happy) {
      final smile = Paint()
        ..color = const Color(0xFF2D2D2D)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy - 1 * u), width: 12 * u, height: 6 * u),
        0, pi, false, smile,
      );
    }

    // Legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 16 * u, cy + 24 * u, 10 * u, 12 * u), Radius.circular(4 * u)),
      dark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 6 * u, cy + 24 * u, 10 * u, 12 * u), Radius.circular(4 * u)),
      dark,
    );
  }

  @override
  bool shouldRepaint(_DogPainter old) => old.mood != mood;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  BIRD — black round body, orange beak, coral legs
// ═══════════════════════════════════════════════════════════════════════════════

class _BirdPainter extends CustomPainter with _EyeHelper {
  final PetMood mood;
  _BirdPainter(this.mood);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final u = s.width / 100;

    final black = Paint()..color = const Color(0xFF2D2D2D);
    final orange = Paint()..color = const Color(0xFFEF6C5B);
    final wingLine = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5 * u..strokeCap = StrokeCap.round;

    // Shadow
    drawShadow(canvas, Offset(cx, cy + 34 * u), 18 * u, 5 * u);

    // Legs
    canvas.drawLine(Offset(cx - 6 * u, cy + 22 * u), Offset(cx - 6 * u, cy + 32 * u), Paint()..color = const Color(0xFFEF6C5B)..strokeWidth = 2.5 * u..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(cx + 6 * u, cy + 22 * u), Offset(cx + 6 * u, cy + 32 * u), Paint()..color = const Color(0xFFEF6C5B)..strokeWidth = 2.5 * u..strokeCap = StrokeCap.round);
    // Feet
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 6 * u, cy + 34 * u), width: 8 * u, height: 4 * u), orange);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 6 * u, cy + 34 * u), width: 8 * u, height: 4 * u), orange);

    // Body (round)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 4 * u), width: 42 * u, height: 46 * u), black);

    // Wing curve (white line on body)
    final wingArc = Path()
      ..moveTo(cx + 6 * u, cy - 10 * u);
    wingArc.cubicTo(cx + 22 * u, cy - 5 * u, cx + 22 * u, cy + 18 * u, cx + 4 * u, cy + 22 * u);
    canvas.drawPath(wingArc, wingLine);

    // Head (slightly above body)
    canvas.drawCircle(Offset(cx - 2 * u, cy - 16 * u), 16 * u, black);

    // Beak
    final beakPath = Path()
      ..moveTo(cx - 18 * u, cy - 20 * u)
      ..lineTo(cx - 26 * u, cy - 16 * u)
      ..lineTo(cx - 18 * u, cy - 14 * u)
      ..close();
    canvas.drawPath(beakPath, orange);

    // Eye (single, visible from side view)
    final eyeCenter = Offset(cx - 4 * u, cy - 18 * u);
    if (mood == PetMood.sleeping) {
      final p = Paint()..color = Colors.white..strokeWidth = 2 * u..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCenter(center: eyeCenter, width: 8 * u, height: 5 * u), 0, pi, false, p);
    } else {
      canvas.drawCircle(eyeCenter, 5 * u, Paint()..color = Colors.white);
      canvas.drawCircle(eyeCenter, 5 * u, Paint()..color = const Color(0xFF2D2D2D)..style = PaintingStyle.stroke..strokeWidth = 1.2);
      canvas.drawCircle(eyeCenter + Offset(mood == PetMood.happy ? -1 : 0, 0), 2.5 * u, Paint()..color = const Color(0xFF2D2D2D));
      canvas.drawCircle(eyeCenter + Offset(-1.5 * u, -1.5 * u), 1.2 * u, Paint()..color = Colors.white);
    }

    // Crest / top feather
    final crest = Path()
      ..moveTo(cx - 2 * u, cy - 32 * u)
      ..cubicTo(cx + 2 * u, cy - 38 * u, cx + 8 * u, cy - 38 * u, cx + 4 * u, cy - 32 * u);
    canvas.drawPath(crest, orange);
  }

  @override
  bool shouldRepaint(_BirdPainter old) => old.mood != mood;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  HAMSTER — chubby white/red body, round ears, big cheeks
// ═══════════════════════════════════════════════════════════════════════════════

class _HamsterPainter extends CustomPainter with _EyeHelper {
  final PetMood mood;
  _HamsterPainter(this.mood);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final u = s.width / 100;

    final white = Paint()..color = const Color(0xFFF5F0EB);
    final red = Paint()..color = const Color(0xFFEF6C5B);
    final dark = Paint()..color = const Color(0xFF2D2D2D);

    // Shadow
    drawShadow(canvas, Offset(cx, cy + 34 * u), 22 * u, 5 * u);

    // Body (egg shape — wider at bottom)
    final bodyPath = Path();
    bodyPath.addOval(Rect.fromCenter(center: Offset(cx, cy + 6 * u), width: 48 * u, height: 52 * u));
    canvas.drawPath(bodyPath, white);

    // Red patches on sides
    final patchL = Path()
      ..moveTo(cx - 24 * u, cy - 4 * u)
      ..cubicTo(cx - 30 * u, cy + 8 * u, cx - 26 * u, cy + 24 * u, cx - 14 * u, cy + 28 * u);
    canvas.drawPath(patchL, Paint()..color = const Color(0xFFEF6C5B)..style = PaintingStyle.stroke..strokeWidth = 12 * u..strokeCap = StrokeCap.round);

    final patchR = Path()
      ..moveTo(cx + 24 * u, cy - 4 * u)
      ..cubicTo(cx + 30 * u, cy + 8 * u, cx + 26 * u, cy + 24 * u, cx + 14 * u, cy + 28 * u);
    canvas.drawPath(patchR, Paint()..color = const Color(0xFFEF6C5B)..style = PaintingStyle.stroke..strokeWidth = 12 * u..strokeCap = StrokeCap.round);

    // Ears
    canvas.drawCircle(Offset(cx - 18 * u, cy - 28 * u), 10 * u, red);
    canvas.drawCircle(Offset(cx + 18 * u, cy - 28 * u), 10 * u, red);
    canvas.drawCircle(Offset(cx - 18 * u, cy - 28 * u), 6 * u, Paint()..color = const Color(0xFFFF9B8E));
    canvas.drawCircle(Offset(cx + 18 * u, cy - 28 * u), 6 * u, Paint()..color = const Color(0xFFFF9B8E));

    // Face area (white overlay)
    canvas.drawCircle(Offset(cx, cy - 8 * u), 20 * u, white);

    // Eyes
    drawEyes(
      canvas,
      Offset(cx - 8 * u, cy - 12 * u),
      Offset(cx + 8 * u, cy - 12 * u),
      4.5 * u,
      mood,
    );

    // Nose
    canvas.drawCircle(Offset(cx, cy - 3 * u), 2.5 * u, dark);

    // Mouth (cute "w" shape)
    final mouth = Paint()..color = const Color(0xFF2D2D2D)..strokeWidth = 1.2..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy - 1 * u), Offset(cx - 4 * u, cy + 2 * u), mouth);
    canvas.drawLine(Offset(cx, cy - 1 * u), Offset(cx + 4 * u, cy + 2 * u), mouth);

    // Cheek blush
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 14 * u, cy - 2 * u), width: 8 * u, height: 5 * u),
      Paint()..color = const Color(0xFFFF9B8E).withValues(alpha: 0.5),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 14 * u, cy - 2 * u), width: 8 * u, height: 5 * u),
      Paint()..color = const Color(0xFFFF9B8E).withValues(alpha: 0.5),
    );

    // Belly marking "U U"
    final bellyText = Paint()..color = const Color(0xFF2D2D2D)..strokeWidth = 1.8..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx - 6 * u, cy + 12 * u), width: 7 * u, height: 8 * u), 0, pi, false, bellyText);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx + 6 * u, cy + 12 * u), width: 7 * u, height: 8 * u), 0, pi, false, bellyText);

    // Tiny feet
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 10 * u, cy + 32 * u), width: 10 * u, height: 5 * u), dark);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 10 * u, cy + 32 * u), width: 10 * u, height: 5 * u), dark);
  }

  @override
  bool shouldRepaint(_HamsterPainter old) => old.mood != mood;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  IGUANA — green body, spiky back, curled tail
// ═══════════════════════════════════════════════════════════════════════════════

class _IguanaPainter extends CustomPainter with _EyeHelper {
  final PetMood mood;
  _IguanaPainter(this.mood);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final u = s.width / 100;

    final green = Paint()..color = const Color(0xFF2EBD7E);
    final darkGreen = Paint()..color = const Color(0xFF1A8A5C);
    final dark = Paint()..color = const Color(0xFF2D2D2D);
    final red = Paint()..color = const Color(0xFFEF6C5B);

    // Shadow
    drawShadow(canvas, Offset(cx, cy + 34 * u), 32 * u, 5 * u);

    // Curled tail
    final tailP = Paint()..color = const Color(0xFF2EBD7E)..style = PaintingStyle.stroke..strokeWidth = 7 * u..strokeCap = StrokeCap.round;
    final tail = Path()..moveTo(cx + 22 * u, cy + 12 * u);
    tail.cubicTo(cx + 38 * u, cy + 8 * u, cx + 44 * u, cy - 10 * u, cx + 34 * u, cy - 18 * u);
    tail.cubicTo(cx + 28 * u, cy - 22 * u, cx + 22 * u, cy - 16 * u, cx + 26 * u, cy - 10 * u);
    canvas.drawPath(tail, tailP);

    // Body (horizontal oval)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 10 * u), width: 52 * u, height: 34 * u), green);

    // Belly (lighter)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 2 * u, cy + 14 * u), width: 32 * u, height: 18 * u), Paint()..color = const Color(0xFF45D99A));

    // Spikes on back
    for (int i = -3; i <= 3; i++) {
      final sx = cx + i * 6 * u;
      final spike = Path()
        ..moveTo(sx - 3 * u, cy - 4 * u)
        ..lineTo(sx, cy - 14 * u - (i.abs() < 2 ? 4 * u : 0))
        ..lineTo(sx + 3 * u, cy - 4 * u)
        ..close();
      canvas.drawPath(spike, darkGreen);
    }

    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 20 * u, cy + 2 * u), width: 28 * u, height: 22 * u), green);

    // Eyes
    final eyeC = Offset(cx - 22 * u, cy - 2 * u);
    if (mood == PetMood.sleeping) {
      final p = Paint()..color = const Color(0xFF2D2D2D)..strokeWidth = 2 * u..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCenter(center: eyeC, width: 8 * u, height: 5 * u), 0, pi, false, p);
    } else {
      canvas.drawCircle(eyeC, 5 * u, Paint()..color = Colors.white);
      canvas.drawCircle(eyeC, 5 * u, Paint()..color = const Color(0xFF2D2D2D)..style = PaintingStyle.stroke..strokeWidth = 1.2);
      canvas.drawCircle(eyeC, 2.5 * u, dark);
      canvas.drawCircle(eyeC + Offset(-1.5 * u, -1.5 * u), 1.2 * u, Paint()..color = Colors.white);
    }

    // Nose dot
    canvas.drawCircle(Offset(cx - 34 * u, cy + 2 * u), 2 * u, red);

    // Mouth line
    final mouthP = Paint()..color = const Color(0xFF1A8A5C)..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 34 * u, cy + 4 * u), Offset(cx - 28 * u, cy + 6 * u), mouthP);

    // Legs
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 16 * u, cy + 22 * u, 8 * u, 12 * u), Radius.circular(3 * u)), dark);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 6 * u, cy + 22 * u, 8 * u, 12 * u), Radius.circular(3 * u)), dark);
    // Toes
    for (var lx in [cx - 16 * u, cx + 6 * u]) {
      for (var t = 0; t < 3; t++) {
        canvas.drawCircle(Offset(lx + 2 * u + t * 2 * u, cy + 34 * u), 1.5 * u, Paint()..color = const Color(0xFF1A8A5C));
      }
    }
  }

  @override
  bool shouldRepaint(_IguanaPainter old) => old.mood != mood;
}
