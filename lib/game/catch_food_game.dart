import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/basket_component.dart';
import 'components/food_item_component.dart';
import 'components/bomb_component.dart';

class CatchFoodGame extends FlameGame
    with HasCollisionDetection, DragCallbacks {
  final void Function(int score) onGameEnd;

  late BasketComponent _basket;
  late TextComponent _scoreLabel;
  late TextComponent _timerLabel;

  int _score = 0;
  int _timeLeft = 30;
  bool _ended = false;

  async.Timer? _gameTimer;
  async.Timer? _spawnTimer;

  static const _foods = ['🍎', '🍕', '🦴', '🐟', '🥕', '🫐', '🍗', '🧀'];
  final _rng = Random();

  CatchFoodGame({required this.onGameEnd});

  @override
  Color backgroundColor() => const Color(0xFFFFF8F0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(CircleComponent(
      radius: 120,
      position: Vector2(-40, -40),
      paint: Paint()..color = const Color(0xFFFFD6E7).withValues(alpha: 0.4),
    ));
    add(CircleComponent(
      radius: 80,
      position: Vector2(size.x - 60, size.y * 0.4),
      paint: Paint()..color = const Color(0xFFD6EEFF).withValues(alpha: 0.4),
    ));

    add(RectangleComponent(
      position: Vector2(0, size.y - 80),
      size: Vector2(size.x, 2),
      paint: Paint()..color = const Color(0xFFEEEEEE),
    ));

    _basket = BasketComponent();
    _basket.position = Vector2(size.x / 2 - _basket.size.x / 2, size.y - 100);
    add(_basket);

    _scoreLabel = TextComponent(
      text: '🍎 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF3D3D3D),
          fontFamily: 'Nunito',
        ),
      ),
      position: Vector2(18, 52),
    );
    add(_scoreLabel);

    // anchor: topRight avoids the size=0 bug before layout
    _timerLabel = TextComponent(
      text: '⏱ 30',
      anchor: Anchor.topRight,
      position: Vector2(size.x - 18, 52),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF3D3D3D),
          fontFamily: 'Nunito',
        ),
      ),
    );
    add(_timerLabel);

    final hint = TextComponent(
      text: 'Drag to catch food  •  Avoid 💣',
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y - 28),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFFAAAAAA),
          fontFamily: 'Nunito',
        ),
      ),
    );
    add(hint);

    _startTimers();
  }

  void _startTimers() {
    _gameTimer =
        async.Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _spawnTimer = async.Timer.periodic(
        const Duration(milliseconds: 1100), (_) => _spawnItem());
  }

  void _tick() {
    if (_ended) return;
    _timeLeft--;
    _timerLabel.text = '⏱ $_timeLeft';

    if (_timeLeft % 10 == 0 && _timeLeft > 0) {
      _spawnTimer?.cancel();
      final interval = (1100 - (30 - _timeLeft) * 20).clamp(600, 1100);
      _spawnTimer = async.Timer.periodic(
          Duration(milliseconds: interval), (_) => _spawnItem());
    }

    if (_timeLeft <= 0) {
      _end();
    }
  }

  void _spawnItem() {
    if (_ended) return;

    // 22% chance to spawn a bomb
    if (_rng.nextDouble() < 0.22) {
      final bomb = BombComponent(speed: 190 + _rng.nextDouble() * 60);
      bomb.position = Vector2(
        _rng.nextDouble() * (size.x - bomb.size.x),
        -bomb.size.y,
      );
      add(bomb);
    } else {
      final food = FoodItemComponent(
        emoji: _foods[_rng.nextInt(_foods.length)],
        speed: 200 + _rng.nextDouble() * 80,
      );
      food.position = Vector2(
        _rng.nextDouble() * (size.x - food.size.x),
        -food.size.y,
      );
      add(food);
    }
  }

  void onFoodCaught() {
    if (_ended) return;
    _score++;
    _scoreLabel.text = '🍎 $_score';
  }

  void onBombCaught() {
    if (_ended) return;
    _score = (_score - 2).clamp(0, 9999);
    _scoreLabel.text = '🍎 $_score';
    _showPenalty();
  }

  void _showPenalty() {
    final penalty = TextComponent(
      text: '💥 -2',
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Color(0xFFFF4C6A),
          fontFamily: 'Nunito',
        ),
      ),
    );
    add(penalty);
    async.Future.delayed(const Duration(milliseconds: 700),
        () => penalty.removeFromParent());
  }

  void _end() {
    if (_ended) return;
    _ended = true;
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    async.Future.delayed(const Duration(milliseconds: 400), () {
      onGameEnd(_score);
    });
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    final newX = event.canvasEndPosition.x - _basket.size.x / 2;
    _basket.position.x = newX.clamp(0, size.x - _basket.size.x);
    return true;
  }

  @override
  void onRemove() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.onRemove();
  }
}
