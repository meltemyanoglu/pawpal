import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class BasketComponent extends PositionComponent with CollisionCallbacks {
  BasketComponent() : super(size: Vector2(90, 56));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFF8FAB)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(14),
    );
    canvas.drawRRect(rrect, paint);

    // Lighter stripe for depth
    final stripePaint = Paint()
      ..color = const Color(0xFFFF6B9D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, stripePaint);

    // Basket emoji
    final tp = TextPainter(
      text: const TextSpan(text: '🧺', style: TextStyle(fontSize: 38)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.x / 2 - tp.width / 2, size.y / 2 - tp.height / 2),
    );
  }
}
