import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../services/storage_service.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF0F5), Color(0xFFF5F0FF), Color(0xFFF0FFF5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _Logo(),
                const SizedBox(height: 20),
                _Tagline(),
                const Spacer(flex: 2),
                _PetRow(),
                const Spacer(flex: 3),
                _StartButton(onTap: () => _onStart(context)),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStart(BuildContext context) {
    if (StorageService.hasSelectedPet) {
      Navigator.pushReplacementNamed(context, Routes.main);
    } else {
      Navigator.pushReplacementNamed(context, Routes.petSelection);
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppTheme.glowShadow(AppTheme.primary),
          ),
          child: const Center(
            child: Text('🐾', style: TextStyle(fontSize: 56)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'PawPal',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ],
    );
  }
}

class _Tagline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Your tiny friend needs you.\nFeed, play & love them every day.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            height: 1.7,
          ),
    );
  }
}

class _PetRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _FloatingPetBubble(emoji: '🐱', delay: 0),
        const SizedBox(width: 24),
        _FloatingPetBubble(emoji: '🐶', delay: 350),
        const SizedBox(width: 24),
        _FloatingPetBubble(emoji: '🐰', delay: 700),
      ],
    );
  }
}

class _FloatingPetBubble extends StatefulWidget {
  final String emoji;
  final int delay;
  const _FloatingPetBubble({required this.emoji, required this.delay});

  @override
  State<_FloatingPetBubble> createState() => _FloatingPetBubbleState();
}

class _FloatingPetBubbleState extends State<_FloatingPetBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _offset = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay),
        () => mounted ? _ctrl.repeat(reverse: true) : null);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (_,  _) => Transform.translate(
        offset: Offset(0, _offset.value),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppTheme.cardShadow,
          ),
          child: Center(
              child: Text(widget.emoji,
                  style: const TextStyle(fontSize: 38))),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: AppTheme.glowShadow(AppTheme.primary),
        ),
        child: Center(
          child: Text(
            "Let's Start! 🐾",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
          ),
        ),
      ),
    );
  }
}
