import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';
import '../widgets/stat_bar.dart';
import '../widgets/action_button.dart';
import '../widgets/pet_display.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petProvider);
    if (pet == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, Routes.onboarding);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _MainBody(pet: pet);
  }
}

// ── Body (stateful for animations & particles) ────────────────────────────────

class _MainBody extends ConsumerStatefulWidget {
  final Pet pet;
  const _MainBody({required this.pet});

  @override
  ConsumerState<_MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends ConsumerState<_MainBody>
    with TickerProviderStateMixin {
  // Particle system – each entry is an emoji that floats up
  final List<String> _particles = [];
  Timer? _particleCleanup;

  late final AnimationController _bgCtrl;
  late final Animation<Color?> _bg1;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8));
    _bg1 = ColorTween(
      begin: const Color(0xFFFFF8F0),
      end: const Color(0xFFF8F0FF),
    ).animate(_bgCtrl);
    _bgCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _particleCleanup?.cancel();
    _bgCtrl.dispose();
    super.dispose();
  }

  void _emitParticle(String emoji) {
    setState(() => _particles.add(emoji));
    _particleCleanup?.cancel();
    _particleCleanup = Timer(const Duration(milliseconds: 950), () {
      if (mounted) setState(() => _particles.clear());
    });
  }

  void _handleAction(String action) {
    final notifier = ref.read(petProvider.notifier);
    switch (action) {
      case 'feed':
        notifier.feed();
        _emitParticle('🍎');
      case 'wash':
        notifier.wash();
        _emitParticle('💧');
      case 'play':
        Navigator.pushNamed(context, Routes.miniGame);
        return;
      case 'sleep':
        notifier.toggleSleep();
        _emitParticle('💤');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider)!;
    final isSleeping = pet.isSleeping;

    return AnimatedBuilder(
      animation: _bg1,
      builder: (_, child) => Scaffold(
        backgroundColor: _bg1.value,
        body: child,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            child: Column(
              children: [
                _buildTopBar(context, pet),
                const SizedBox(height: 16),
                _buildPetArea(pet),
                const SizedBox(height: 12),
                _buildMoodChip(context, pet),
                const SizedBox(height: 20),
                _buildStatCard(context, pet),
                const Spacer(),
                _buildActionRow(context, pet, isSleeping),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, Pet pet) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My pet 🐾',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                        fontSize: 13,
                      )),
              Text(pet.name,
                  style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          _HealthBadge(health: pet.overallHealth),
        ],
      ),
    );
  }

  // ── Pet display ──────────────────────────────────────────────────────────

  Widget _buildPetArea(Pet pet) {
    return Center(
      child: PetDisplay(pet: pet, particles: List.from(_particles)),
    );
  }

  // ── Mood chip ────────────────────────────────────────────────────────────

  Widget _buildMoodChip(BuildContext context, Pet pet) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(pet.moodText),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Text(
          '${pet.moodEmoji}  ${pet.moodText}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textMid,
              ),
        ),
      ),
    );
  }

  // ── Stat bars card ───────────────────────────────────────────────────────

  Widget _buildStatCard(BuildContext context, Pet pet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            StatBar(
                icon: '🍎',
                label: 'Hunger',
                value: pet.hunger,
                color: AppTheme.hungerColor),
            StatBar(
                icon: '😊',
                label: 'Happy',
                value: pet.happiness,
                color: AppTheme.happinessColor),
            StatBar(
                icon: '🛁',
                label: 'Clean',
                value: pet.cleanliness,
                color: AppTheme.cleanlinessColor),
            StatBar(
                icon: '⚡',
                label: 'Energy',
                value: pet.energy,
                color: AppTheme.energyColor),
          ],
        ),
      ),
    );
  }

  // ── Action buttons ───────────────────────────────────────────────────────

  Widget _buildActionRow(BuildContext context, Pet pet, bool isSleeping) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ActionButton(
              icon: '🍎',
              label: 'Feed',
              color: AppTheme.hungerColor,
              enabled: !isSleeping && pet.hunger < 95,
              onTap: () => _handleAction('feed'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ActionButton(
              icon: '🛁',
              label: 'Wash',
              color: AppTheme.cleanlinessColor,
              enabled: !isSleeping && pet.cleanliness < 95,
              onTap: () => _handleAction('wash'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ActionButton(
              icon: '🎮',
              label: 'Play',
              color: AppTheme.happinessColor,
              enabled: !isSleeping && pet.energy >= 15,
              onTap: () => _handleAction('play'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ActionButton(
              icon: isSleeping ? '☀️' : '😴',
              label: isSleeping ? 'Wake' : 'Sleep',
              color: AppTheme.energyColor,
              enabled: true,
              onTap: () => _handleAction('sleep'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Health badge ──────────────────────────────────────────────────────────────

class _HealthBadge extends StatelessWidget {
  final double health;
  const _HealthBadge({required this.health});

  Color get _color {
    if (health >= 70) return AppTheme.accent;
    if (health >= 40) return Colors.orange;
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('❤️', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            '${health.toInt()}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _color,
                  fontSize: 15,
                ),
          ),
        ],
      ),
    );
  }
}
