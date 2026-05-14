import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';

class PetSelectionScreen extends ConsumerStatefulWidget {
  const PetSelectionScreen({super.key});

  @override
  ConsumerState<PetSelectionScreen> createState() => _PetSelectionScreenState();
}

class _PetSelectionScreenState extends ConsumerState<PetSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _catSlide;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _catSlide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutBack));
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100),
        () => mounted ? _enterCtrl.forward() : null);
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  void _adopt() {
    ref.read(petProvider.notifier).selectPet(PetType.cat);
    Navigator.pushReplacementNamed(context, Routes.main);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pet = Pet(type: PetType.cat);

    return Scaffold(
      body: Stack(
        children: [
          // ── Arka plan gradyanı ─────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF0F5),
                  Color(0xFFFCEAF5),
                  Color(0xFFF4EFFE),
                ],
              ),
            ),
          ),

          // Dekoratif sol üst daire
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.10),
              ),
            ),
          ),
          // Dekoratif sağ alt daire
          Positioned(
            bottom: -40,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB5EAD7).withValues(alpha: 0.20),
              ),
            ),
          ),

          // ── Ana içerik ─────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SizedBox(
                height: size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    _buildTopLabel(context),
                    const Spacer(flex: 1),
                    SlideTransition(
                      position: _catSlide,
                      child: _CatShowcase(),
                    ),
                    const Spacer(flex: 1),
                    SlideTransition(
                      position: _textSlide,
                      child: _buildPetInfo(context, pet),
                    ),
                    const SizedBox(height: 24),
                    SlideTransition(
                      position: _textSlide,
                      child: _buildTraits(context),
                    ),
                    const Spacer(flex: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: _AdoptButton(petName: pet.name, onTap: _adopt),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopLabel(BuildContext context) {
    return Column(
      children: [
        Text(
          'Meet your friend',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
                fontSize: 14,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Waiting for you ✨',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontSize: 26),
        ),
      ],
    );
  }

  Widget _buildPetInfo(BuildContext context, Pet pet) {
    return Column(
      children: [
        Text(
          pet.name,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 44,
                letterSpacing: -1,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            pet.personality,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Text(
            pet.description,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(height: 1.65),
          ),
        ),
      ],
    );
  }

  Widget _buildTraits(BuildContext context) {
    const traits = [
      ('😴', 'Nap Lover'),
      ('🎯', 'Curious'),
      ('🌙', 'Mysterious'),
      ('🐾', 'Elegant'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: traits.map((t) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.$1, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                t.$2,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMid,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Cat showcase ──────────────────────────────────────────────────────────────

class _CatShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dış glow halkası
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.22),
                  AppTheme.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // İç pembe daire
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD6E7), Color(0xFFFFF4F9)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.35),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          // Lottie animasyon
          ClipOval(
            child: Lottie.asset(
              'assets/animations/cat.json',
              width: 190,
              height: 190,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Text('🐱', style: TextStyle(fontSize: 100)),
            ),
          ),
          // Işıltı efektleri
          Positioned(
            top: 42,
            left: 52,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
          Positioned(
            top: 56,
            left: 64,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Adopt button ──────────────────────────────────────────────────────────────

class _AdoptButton extends StatefulWidget {
  final String petName;
  final VoidCallback onTap;
  const _AdoptButton({required this.petName, required this.onTap});

  @override
  State<_AdoptButton> createState() => _AdoptButtonState();
}

class _AdoptButtonState extends State<_AdoptButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
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
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDark],
            ),
            borderRadius: BorderRadius.circular(31),
            boxShadow: AppTheme.glowShadow(AppTheme.primary),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🐾', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  'Start with ${widget.petName}!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
