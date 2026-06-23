import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_button.dart';
import '../widgets/pet_display.dart';
import '../widgets/floating_particles.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/event_popup.dart';

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
  StreamSubscription<PetEventData>? _eventSub;

  // Event popup state
  final List<_PopupData> _pendingPopups = [];
  _PopupData? _currentPopup;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    // Listen to pet events (level-up, achievements, etc.)
    _eventSub = ref.read(petProvider.notifier).events.listen(_onEvent);
  }

  void _onEvent(PetEventData event) {
    _PopupData popup;
    switch (event.type) {
      case PetEvent.levelUp:
        popup = _PopupData(
          icon: '⭐',
          title: 'Level Up!',
          subtitle: 'You reached Level ${event.payload}!',
          color: const Color(0xFFFFD93D),
          showConfetti: true,
        );
      case PetEvent.achievementUnlocked:
        final achievement = Achievement.all
            .where((a) => a.id == event.payload)
            .firstOrNull;
        popup = _PopupData(
          icon: achievement?.icon ?? '🏅',
          title: 'Achievement Unlocked!',
          subtitle: achievement?.title ?? 'New achievement!',
          color: const Color(0xFFC3A8F5),
          showConfetti: true,
        );
      case PetEvent.streakReward:
        popup = _PopupData(
          icon: '🔥',
          title: '${event.payload}-Day Streak!',
          subtitle: 'Bonus coins earned!',
          color: const Color(0xFFFF6B9D),
          showConfetti: false,
        );
      case PetEvent.missionComplete:
        popup = _PopupData(
          icon: '✅',
          title: 'Mission Complete!',
          subtitle: '+15 coins & +30 XP',
          color: const Color(0xFF4CD97B),
          showConfetti: false,
        );
    }

    if (mounted) {
      setState(() {
        if (_currentPopup == null) {
          _currentPopup = popup;
          if (popup.showConfetti) _showConfetti = true;
        } else {
          _pendingPopups.add(popup);
        }
      });
    }
  }

  void _dismissPopup() {
    if (!mounted) return;
    setState(() {
      _showConfetti = false;
      if (_pendingPopups.isNotEmpty) {
        _currentPopup = _pendingPopups.removeAt(0);
        if (_currentPopup!.showConfetti) _showConfetti = true;
      } else {
        _currentPopup = null;
      }
    });
  }

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
    _eventSub?.cancel();
    super.dispose();
  }

  void _handleAction(String action) {
    final n = ref.read(petProvider.notifier);
    HapticFeedback.lightImpact();
    switch (action) {
      case 'feed':
        n.feed();
        _emit('🍎');
      case 'wash':
        n.wash();
        _emit('💧');
      case 'cuddle':
        n.play();
        _emit('💕');
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
        body: Stack(
          children: [
            // Floating ambient particles
            const Positioned.fill(child: FloatingParticles()),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // ── Scrollable upper content ──
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _TopBar(pet: pet),
                          const SizedBox(height: 4),
                          _XPBar(pet: pet),
                          const SizedBox(height: 4),
                          _PetSection(
                            pet: pet,
                            particles: List.from(_particles),
                            particleGen: _particleGen,
                          ),
                          const SizedBox(height: 4),
                          _ThoughtBubble(pet: pet),
                          const SizedBox(height: 16),
                          _StatsGrid(pet: pet),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  // ── Fixed bottom: actions + nav ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionRow(pet: pet, onAction: _handleAction),
                        const SizedBox(height: 8),
                        _BottomNav(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Confetti overlay
            if (_showConfetti)
              Positioned.fill(
                child: ConfettiOverlay(
                  onComplete: () {
                    if (mounted) setState(() => _showConfetti = false);
                  },
                ),
              ),

            // Event popup
            if (_currentPopup != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 0,
                right: 0,
                child: EventPopup(
                  icon: _currentPopup!.icon,
                  title: _currentPopup!.title,
                  subtitle: _currentPopup!.subtitle,
                  accentColor: _currentPopup!.color,
                  onDismiss: _dismissPopup,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PopupData {
  final String icon, title, subtitle;
  final Color color;
  final bool showConfetti;
  _PopupData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.showConfetti,
  });
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final Pet pet;
  const _TopBar({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Text('My pet 🐾',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        )),
                const SizedBox(width: 8),
                // Streak badge
                if (pet.streak > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFFF8FAB)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 3),
                        Text(
                          '${pet.streak}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Text(pet.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 26)),
          ]),
          Row(
            children: [
              // Coins
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('💰', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text('${pet.coins}',
                      style: const TextStyle(
                        color: Color(0xFFFFB800),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'Nunito',
                      )),
                ]),
              ),
              const SizedBox(width: 8),
              _HealthBadge(health: pet.overallHealth),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('❤️', style: TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        Text('${health.toInt()}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                )),
      ]),
    );
  }
}

// ── XP Bar ───────────────────────────────────────────────────────────────────

class _XPBar extends StatelessWidget {
  final Pet pet;
  const _XPBar({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Level badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC3A8F5), Color(0xFF9B7FE8)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Lv.${pet.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            const SizedBox(width: 10),
            // XP progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pet.levelTitle,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMid,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      Text(
                        '${pet.xp}/${pet.xpForNextLevel} XP',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textLight,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: pet.xpProgress),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (_, v, _) => LinearProgressIndicator(
                        value: v,
                        minHeight: 5,
                        backgroundColor:
                            const Color(0xFFC3A8F5).withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF9B7FE8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💭', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '"$msg"',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMid,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 2x2 Stats grid ────────────────────────────────────────────────────────────

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
          const SizedBox(width: 14),
          Expanded(
              child: StatCard(
            icon: '😊',
            label: 'Happiness',
            value: pet.happiness,
            color: AppTheme.happinessColor,
            gradient: const [Color(0xFFFFF4C2), Color(0xFFFFFBE6)],
          )),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: StatCard(
            icon: '🛁',
            label: 'Cleanliness',
            value: pet.cleanliness,
            color: AppTheme.cleanlinessColor,
            gradient: const [Color(0xFFD6EEFF), Color(0xFFEEF6FF)],
          )),
          const SizedBox(width: 14),
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
          icon: '💕',
          label: 'Cuddle',
          gradient: const [Color(0xFFFFD93D), Color(0xFFFFB800)],
          enabled: !sleeping && pet.energy >= 10,
          onTap: () => onAction('cuddle'),
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

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavIcon(
            icon: '🏆',
            label: 'Badges',
            onTap: () => Navigator.pushNamed(context, Routes.achievements),
          ),
          _NavIcon(
            icon: '🛍️',
            label: 'Shop',
            onTap: () => Navigator.pushNamed(context, Routes.shop),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatefulWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _NavIcon(
      {required this.icon, required this.label, required this.onTap});

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
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
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
