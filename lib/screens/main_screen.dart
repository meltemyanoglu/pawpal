import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_button.dart';
import '../widgets/pet_display.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petProvider);
    if (pet == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          Navigator.pushReplacementNamed(context, Routes.onboarding));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _MainBody(pet: pet);
  }
}

class _MainBody extends ConsumerStatefulWidget {
  final Pet pet;
  const _MainBody({required this.pet});

  @override
  ConsumerState<_MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends ConsumerState<_MainBody>
    with TickerProviderStateMixin {
  final List<String> _particles = [];
  int _particleGen = 0;
  Timer? _particleClear;

  void _emit(String emoji) {
    setState(() {
      _particles.clear();
      _particles.addAll([emoji, emoji, emoji]);
      _particleGen++;
    });
    _particleClear?.cancel();
    _particleClear = Timer(const Duration(milliseconds: 950),
        () => mounted ? setState(() => _particles.clear()) : null);
  }

  @override
  void dispose() {
    _particleClear?.cancel();
    super.dispose();
  }

  void _handleAction(String action) {
    final n = ref.read(petProvider.notifier);
    switch (action) {
      case 'feed':
        n.feed();
        _emit('🍎');
      case 'wash':
        n.wash();
        _emit('💧');
      case 'play':
        Navigator.pushNamed(context, Routes.miniGame);
        return;
      case 'sleep':
        n.toggleSleep();
        _emit('💤');
    }
  }

  static Color _moodBg(PetMood mood) => switch (mood) {
        PetMood.ecstatic => const Color(0xFFFFF0F5),
        PetMood.happy => const Color(0xFFFFF8F0),
        PetMood.neutral => const Color(0xFFF8F8FF),
        PetMood.sad => const Color(0xFFEEF4FF),
        PetMood.exhausted => const Color(0xFFFFEEEE),
        PetMood.sleeping => const Color(0xFFF2F0FF),
      };

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      color: _moodBg(pet.mood),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(pet: pet),
              const SizedBox(height: 8),
              _PetSection(
                pet: pet,
                particles: List.from(_particles),
                particleGen: _particleGen,
              ),
              const SizedBox(height: 10),
              _ThoughtBubble(pet: pet),
              const SizedBox(height: 14),
              _StatsGrid(pet: pet),
              const Spacer(),
              _ActionRow(
                pet: pet,
                onAction: _handleAction,
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final Pet pet;
  const _TopBar({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('My pet 🐾',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                      fontSize: 13,
                    )),
            Text(pet.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 28)),
          ]),
          _HealthBadge(health: pet.overallHealth),
        ],
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  final double health;
  const _HealthBadge({required this.health});

  Color get _color {
    if (health >= 70) return const Color(0xFF4CD97B);
    if (health >= 40) return Colors.orange;
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('❤️', style: TextStyle(fontSize: 15)),
        const SizedBox(width: 6),
        Text('${health.toInt()}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                )),
      ]),
    );
  }
}

// ── Pet section ───────────────────────────────────────────────────────────────

class _PetSection extends StatelessWidget {
  final Pet pet;
  final List<String> particles;
  final int particleGen;
  const _PetSection(
      {required this.pet, required this.particles, required this.particleGen});

  @override
  Widget build(BuildContext context) {
    return PetDisplay(
      pet: pet,
      particles: particles,
      particleGeneration: particleGen,
    );
  }
}

// ── Thought bubble ────────────────────────────────────────────────────────────

class _ThoughtBubble extends StatefulWidget {
  final Pet pet;
  const _ThoughtBubble({required this.pet});

  @override
  State<_ThoughtBubble> createState() => _ThoughtBubbleState();
}

class _ThoughtBubbleState extends State<_ThoughtBubble> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % widget.pet.thoughtMessages.length;
        });
      }
    });
  }

  @override
  void didUpdateWidget(_ThoughtBubble old) {
    super.didUpdateWidget(old);
    if (old.pet.mood != widget.pet.mood) {
      setState(() => _index = 0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.pet.thoughtMessages[_index];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
                  .animate(anim),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey('$_index${widget.pet.mood}'),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💭', style: TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Text(
              '"$msg"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMid,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 2×2 Stats grid ────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final Pet pet;
  const _StatsGrid({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: StatCard(
            icon: '🍎',
            label: 'Hunger',
            value: pet.hunger,
            color: AppTheme.hungerColor,
            gradient: const [Color(0xFFFFD6E7), Color(0xFFFFF0F5)],
          )),
          const SizedBox(width: 12),
          Expanded(
              child: StatCard(
            icon: '😊',
            label: 'Happiness',
            value: pet.happiness,
            color: AppTheme.happinessColor,
            gradient: const [Color(0xFFFFF4C2), Color(0xFFFFFBE6)],
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: StatCard(
            icon: '🛁',
            label: 'Cleanliness',
            value: pet.cleanliness,
            color: AppTheme.cleanlinessColor,
            gradient: const [Color(0xFFD6EEFF), Color(0xFFEEF6FF)],
          )),
          const SizedBox(width: 12),
          Expanded(
              child: StatCard(
            icon: '⚡',
            label: 'Energy',
            value: pet.energy,
            color: AppTheme.energyColor,
            gradient: const [Color(0xFFD6FFE8), Color(0xFFEEFFF4)],
          )),
        ]),
      ]),
    );
  }
}

// ── Action row ────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final Pet pet;
  final void Function(String) onAction;
  const _ActionRow({required this.pet, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final sleeping = pet.isSleeping;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Expanded(
            child: ActionButton(
          icon: '🍎',
          label: 'Feed',
          gradient: const [Color(0xFFFF8FAB), Color(0xFFFF6B9D)],
          enabled: !sleeping && pet.hunger < 95,
          onTap: () => onAction('feed'),
        )),
        const SizedBox(width: 10),
        Expanded(
            child: ActionButton(
          icon: '🛁',
          label: 'Wash',
          gradient: const [Color(0xFF74C7F0), Color(0xFF4AAAD4)],
          enabled: !sleeping && pet.cleanliness < 95,
          onTap: () => onAction('wash'),
        )),
        const SizedBox(width: 10),
        Expanded(
            child: ActionButton(
          icon: '🎮',
          label: 'Play',
          gradient: const [Color(0xFFFFD93D), Color(0xFFFFB800)],
          enabled: !sleeping && pet.energy >= 15,
          onTap: () => onAction('play'),
        )),
        const SizedBox(width: 10),
        Expanded(
            child: ActionButton(
          icon: sleeping ? '☀️' : '😴',
          label: sleeping ? 'Wake' : 'Sleep',
          gradient: const [Color(0xFFC3A8F5), Color(0xFF9B7FE8)],
          enabled: true,
          onTap: () => onAction('sleep'),
        )),
      ]),
    );
  }
}
