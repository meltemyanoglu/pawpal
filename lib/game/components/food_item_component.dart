import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../catch_food_game.dart';
import 'basket_component.dart';

class FoodItemComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<CatchFoodGame> {
  final String emoji;
  final double speed;
  bool _caught = false;

  FoodItemComponent({required this.emoji, this.speed = 220.0})
      : super(size: Vector2(52, 52));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_caught) return;
    position.y += speed * dt;
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BasketComponent && !_caught) {
      _caught = true;
      game.onFoodCaught();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 38)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.x / 2 - tp.width / 2, size.y / 2 - tp.height / 2),
    );
  }
}
