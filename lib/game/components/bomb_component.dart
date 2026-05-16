import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../catch_food_game.dart';
import 'basket_component.dart';

class BombComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<CatchFoodGame> {
  final double speed;
  bool _exploded = false;

  BombComponent({this.speed = 200.0}) : super(size: Vector2(52, 52));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_exploded) return;
    position.y += speed * dt;
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BasketComponent && !_exploded) {
      _exploded = true;
      game.onBombCaught();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final tp = TextPainter(
      text: const TextSpan(text: '💣', style: TextStyle(fontSize: 38)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.x / 2 - tp.width / 2, size.y / 2 - tp.height / 2),
    );
  }
}
