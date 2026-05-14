import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/routes.dart';

class GameResultScreen extends StatefulWidget {
  final int score;
  const GameResultScreen({super.key, required this.score});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  int get _stars {
    if (widget.score >= 20) return 3;
    if (widget.score >= 10) return 2;
    if (widget.score >= 4) return 1;
    return 0;
  }

  String get _headline {
    switch (_stars) {
      case 3:
        return 'Amazing! 🎉';
      case 2:
        return 'Great job! 🙌';
      case 1:
        return 'Not bad! 👍';
      default:
        return 'Keep trying! 💪';
    }
  }

  String get _sub {
    switch (_stars) {
      case 3:
        return 'Your pet is over the moon!';
      case 2:
        return 'Your pet is very happy!';
      case 1:
        return 'Your pet liked playing!';
      default:
        return 'Practice makes perfect!';
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF0F5), Color(0xFFF0F8FF), Color(0xFFF0FFF4)],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => FadeTransition(
              opacity: _fade,
              child: child,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(),
                  // Score circle
                  ScaleTransition(
                    scale: _scale,
                    child: _ScoreCircle(score: widget.score),
                  ),
                  const SizedBox(height: 28),
                  Text(_headline,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 34,
                          )),
                  const SizedBox(height: 10),
                  Text(_sub,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                          )),
                  const SizedBox(height: 28),
                  // Stars
                  _StarRow(stars: _stars),
                  const SizedBox(height: 16),
                  // Happiness gained
                  _HappinessChip(score: widget.score),
                  const Spacer(),
                  // Buttons
                  _buildButtons(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () =>
              Navigator.pushReplacementNamed(context, Routes.miniGame),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppTheme.glowShadow(AppTheme.primary),
            ),
            child: Center(
              child: Text('Play Again 🎮',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 17,
                      )),
            ),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, Routes.main),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Center(
              child: Text('Back to ${_getPetName(context)} 🐾',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textDark,
                        fontSize: 17,
                      )),
            ),
          ),
        ),
      ],
    );
  }

  String _getPetName(BuildContext context) => 'my pet';
}

// ── Score circle ──────────────────────────────────────────────────────────────

class _ScoreCircle extends StatelessWidget {
  final int score;
  const _ScoreCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
        boxShadow: AppTheme.glowShadow(AppTheme.primary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍎', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Nunito',
            ),
          ),
          const Text(
            'caught',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Star row ──────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final int stars;
  const _StarRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedScale(
            scale: filled ? 1.2 : 1.0,
            duration: Duration(milliseconds: 300 + i * 100),
            child: Text(
              filled ? '⭐' : '☆',
              style: TextStyle(
                fontSize: filled ? 40 : 34,
                color: filled ? Colors.amber : Colors.grey.shade300,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Happiness chip ────────────────────────────────────────────────────────────

class _HappinessChip extends StatelessWidget {
  final int score;
  const _HappinessChip({required this.score});

  @override
  Widget build(BuildContext context) {
    final gained = (score * 0.8).clamp(0, 40).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😊', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            '+$gained Happiness',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.happinessColor,
                ),
          ),
        ],
      ),
    );
  }
}
