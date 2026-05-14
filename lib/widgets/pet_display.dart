import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../core/theme.dart';
import '../models/pet.dart';

// Dosyayı assets/animations/ klasörüne ekledikçe true yap
const _lottieReady = {
  PetType.cat: true,
  PetType.dog: false,
  PetType.rabbit: false,
};

const _lottiePaths = {
  PetType.cat: 'assets/animations/cat.json',
  PetType.dog: 'assets/animations/dog.json',
  PetType.rabbit: 'assets/animations/rabbit.json',
};

/// Animated pet avatar. Lottie varsa Lottie, yoksa emoji gösterir.
/// Particle effects are managed by the parent via [particles].
class PetDisplay extends StatefulWidget {
  final Pet pet;
  final List<String> particles;

  const PetDisplay({
    super.key,
    required this.pet,
    this.particles = const [],
  });

  @override
  State<PetDisplay> createState() => _PetDisplayState();
}

class _PetDisplayState extends State<PetDisplay> with TickerProviderStateMixin {
  // Emoji fallback animasyonları
  late final AnimationController _breathCtrl;
  late final Animation<double> _breathScale;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceY;

  // Lottie playback controller
  late final AnimationController _lottieCtrl;
  bool _lottieLoaded = false;

  static const _bgGradients = {
    PetType.cat: [Color(0xFFFFD6E7), Color(0xFFFFF0F5)],
    PetType.dog: [Color(0xFFD6EEFF), Color(0xFFF0F8FF)],
    PetType.rabbit: [Color(0xFFD6FFE8), Color(0xFFF0FFF4)],
  };

  @override
  void initState() {
    super.initState();

    _breathCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _breathScale = Tween<double>(begin: 0.96, end: 1.04)
        .animate(CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut));
    _breathCtrl.repeat(reverse: true);

    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    _bounceY = Tween<double>(begin: 0, end: -6)
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
    _bounceCtrl.repeat(reverse: true);

    // Lottie controller başlangıçta boş — onLoaded'da duration set edilir
    _lottieCtrl = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(PetDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pet.mood != widget.pet.mood) {
      _bounceCtrl.forward(from: 0);
      if (_lottieLoaded) _applyMoodSpeed();
    }
  }

  // Mood'a göre Lottie hız çarpanı
  void _applyMoodSpeed() {
    final base = _lottieCtrl.duration ?? const Duration(seconds: 1);
    final multiplier = switch (widget.pet.mood) {
      PetMood.ecstatic  => 1.6,
      PetMood.happy     => 1.2,
      PetMood.neutral   => 1.0,
      PetMood.sad       => 0.6,
      PetMood.exhausted => 0.4,
      PetMood.sleeping  => 0.25,
    };
    _lottieCtrl.duration =
        Duration(milliseconds: (base.inMilliseconds / multiplier).round());
    if (!_lottieCtrl.isAnimating) _lottieCtrl.repeat();
  }

  void _onLottieComposition(LottieComposition composition) {
    _lottieCtrl.duration = composition.duration;
    _lottieLoaded = true;
    _applyMoodSpeed();
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _bounceCtrl.dispose();
    _lottieCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _bgGradients[widget.pet.type]!;
    final hasLottie = _lottieReady[widget.pet.type] ?? false;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dış glow halkası
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                colors[0].withValues(alpha: 0.55),
                colors[1].withValues(alpha: 0.05),
              ]),
            ),
          ),
          // Pet dairesi
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.5),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: Center(
                child: hasLottie ? _buildLottie() : _buildEmoji(),
              ),
            ),
          ),
          // Mood bubble
          Positioned(
            top: 14,
            right: 14,
            child: _MoodBubble(mood: widget.pet.moodEmoji),
          ),
          // Floating particles
          ...widget.particles.asMap().entries.map(
                (e) => _FloatingParticle(
                  key: ValueKey('p_${e.key}'),
                  emoji: e.value,
                ),
              ),
        ],
      ),
    );
  }

  // ── Lottie görünümü ───────────────────────────────────────────────────────

  Widget _buildLottie() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Lottie.asset(
          _lottiePaths[widget.pet.type]!,
          controller: _lottieCtrl,
          onLoaded: _onLottieComposition,
          width: 155,
          height: 155,
          fit: BoxFit.contain,
          // Lottie yoksa emoji'ye düş
          errorBuilder: (_, _, _) => _buildEmoji(),
        ),
        if (widget.pet.isSleeping) const _SleepingZzz(),
      ],
    );
  }

  // ── Emoji fallback ────────────────────────────────────────────────────────

  Widget _buildEmoji() {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathScale, _bounceY]),
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _bounceY.value),
        child: Transform.scale(scale: _breathScale.value, child: child),
      ),
      child: widget.pet.isSleeping
          ? _SleepingEmoji(emoji: widget.pet.emoji)
          : Text(widget.pet.emoji, style: const TextStyle(fontSize: 80)),
    );
  }
}

// ── 💤 overlay (Lottie üstüne) ───────────────────────────────────────────────

class _SleepingZzz extends StatefulWidget {
  const _SleepingZzz();

  @override
  State<_SleepingZzz> createState() => _SleepingZzzState();
}

class _SleepingZzzState extends State<_SleepingZzz>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.7, -0.7),
      child: AnimatedBuilder(
        animation: _fade,
        builder: (_, child) => Opacity(opacity: _fade.value, child: child),
        child: const Text('💤', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}

// ── Sleeping emoji (Lottie yokken) ───────────────────────────────────────────

class _SleepingEmoji extends StatefulWidget {
  final String emoji;
  const _SleepingEmoji({required this.emoji});

  @override
  State<_SleepingEmoji> createState() => _SleepingEmojiState();
}

class _SleepingEmojiState extends State<_SleepingEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0.35, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Text(widget.emoji, style: const TextStyle(fontSize: 80)),
        AnimatedBuilder(
          animation: _fade,
          builder: (_, child) =>
              Opacity(opacity: _fade.value, child: child),
          child: const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text('💤', style: TextStyle(fontSize: 28)),
          ),
        ),
      ],
    );
  }
}

// ── Mood bubble ───────────────────────────────────────────────────────────────

class _MoodBubble extends StatelessWidget {
  final String mood;
  const _MoodBubble({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Text(mood, style: const TextStyle(fontSize: 20)),
    );
  }
}

// ── Floating particle ─────────────────────────────────────────────────────────

class _FloatingParticle extends StatefulWidget {
  final String emoji;
  const _FloatingParticle({super.key, required this.emoji});

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _y;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _y = Tween<double>(begin: 0, end: -90)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 1.0, end: 0.0)
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
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _y.value),
        child: Opacity(opacity: _opacity.value, child: child),
      ),
      child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
    );
  }
}
