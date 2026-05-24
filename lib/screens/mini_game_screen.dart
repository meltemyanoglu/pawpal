import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../core/constants.dart';
import '../providers/pet_provider.dart';
import '../game/catch_food_game.dart';

class MiniGameScreen extends ConsumerStatefulWidget {
  const MiniGameScreen({super.key});

  @override
  ConsumerState<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends ConsumerState<MiniGameScreen> {
  late final CatchFoodGame _game;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _game = CatchFoodGame(onGameEnd: _onGameEnd);
  }

  void _onGameEnd(int score) {
    if (_navigated || !mounted) return;
    _navigated = true;

    // Reward the pet with happiness
    final happiness = (score * Constants.gameHappinessPerCatch).clamp(0, 40);
    ref.read(petProvider.notifier).addHappiness(happiness.toDouble());

    // Record game result for XP, achievements, missions
    ref.read(petProvider.notifier).recordGameResult(score);

    Navigator.pushReplacementNamed(
      context,
      Routes.gameResult,
      arguments: score,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Flame game fills the whole screen
          GameWidget(game: _game),
          // Floating top bar overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _BackButton(onTap: () {
                    if (!_navigated) {
                      _navigated = true;
                      Navigator.pop(context);
                    }
                  }),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Text(
                      'Catch the Food!',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: AppTheme.cardShadow,
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: AppTheme.textDark),
      ),
    );
  }
}
