import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/basket_component.dart';
import 'components/food_item_component.dart';

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

    // Background decoration circles
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

    // Ground line
    add(RectangleComponent(
      position: Vector2(0, size.y - 80),
      size: Vector2(size.x, 2),
      paint: Paint()..color = const Color(0xFFEEEEEE),
    ));

    // Basket
    _basket = BasketComponent();
    _basket.position = Vector2(size.x / 2 - _basket.size.x / 2, size.y - 100);
    add(_basket);

    // HUD – score
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

    // HUD – timer
    _timerLabel = TextComponent(
      text: '⏱ 30',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF3D3D3D),
          fontFamily: 'Nunito',
        ),
      ),
    );
    _timerLabel.position = Vector2(
        size.x - _timerLabel.size.x - 18, 52);
    add(_timerLabel);

    // Instruction text
    final hint = TextComponent(
      text: 'Drag to catch the food!',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFFAAAAAA),
          fontFamily: 'Nunito',
        ),
      ),
    );
    hint.position = Vector2(size.x / 2 - 90, size.y - 48);
    add(hint);

    _startTimers();
  }

  void _startTimers() {
    _gameTimer =
        async.Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _spawnTimer = async.Timer.periodic(
        const Duration(milliseconds: 1100), (_) => _spawnFood());
  }

  void _tick() {
    if (_ended) return;
    _timeLeft--;
    _timerLabel.text = '⏱ $_timeLeft';

    // Increase difficulty over time
    if (_timeLeft % 10 == 0 && _timeLeft > 0) {
      _spawnTimer?.cancel();
      final interval = (1100 - (30 - _timeLeft) * 20).clamp(600, 1100);
      _spawnTimer = async.Timer.periodic(
          Duration(milliseconds: interval), (_) => _spawnFood());
    }

    if (_timeLeft <= 0) {
      _end();
    }
  }

  void _spawnFood() {
    if (_ended) return;
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

  void onFoodCaught() {
    if (_ended) return;
    _score++;
    _scoreLabel.text = '🍎 $_score';
  }

  void _end() {
    if (_ended) return;
    _ended = true;
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    Future.delayed(const Duration(milliseconds: 400), () {
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
