import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../core/theme.dart';
import '../models/pet.dart';

const _lottieReady = {
  PetType.cat: true,
  PetType.dog: false,
};

const _lottiePaths = {
  PetType.cat: 'assets/animations/cat.json',
};

const _gifPaths = {
  PetType.dog: 'assets/animations/dog.gif',
  PetType.bird: 'assets/animations/bird.gif',
  PetType.hamster: 'assets/animations/hamster.gif',
  PetType.iguana: 'assets/animations/bukale.gif',
};

class PetDisplay extends StatefulWidget {
  final Pet pet;
  final List<String> particles;
  final int particleGeneration;

  const PetDisplay({
    super.key,
    required this.pet,
    this.particles = const [],
    this.particleGeneration = 0,
  });

  @override
  State<PetDisplay> createState() => _PetDisplayState();
}

class _PetDisplayState extends State<PetDisplay> with TickerProviderStateMixin {
  late final AnimationController _breathCtrl;
  late final Animation<double> _breathScale;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceY;
  late final AnimationController _lottieCtrl;

  Duration? _originalLottieDuration;
  bool _lottieLoaded = false;

  static const _bgGradients = {
    PetType.cat: [Color(0xFFFFD6E7), Color(0xFFFFF0F5)],
    PetType.dog: [Color(0xFFD6EEFF), Color(0xFFF0F8FF)],
    PetType.bird: [Color(0xFFD6FFD6), Color(0xFFF0FFF0)],
    PetType.hamster: [Color(0xFFFFEDD6), Color(0xFFFFF8F0)],
    PetType.iguana: [Color(0xFFFFD6D6), Color(0xFFFFF0F0)],
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

  void _applyMoodSpeed() {
    final base = _originalLottieDuration;
    if (base == null) return;
    final multiplier = switch (widget.pet.mood) {
      PetMood.ecstatic => 1.6,
      PetMood.happy => 1.2,
      PetMood.neutral => 1.0,
      PetMood.sad => 0.6,
      PetMood.exhausted => 0.4,
      PetMood.sleeping => 0.25,
    };
    _lottieCtrl.duration =
        Duration(milliseconds: (base.inMilliseconds / multiplier).round());
    if (!_lottieCtrl.isAnimating) _lottieCtrl.repeat();
  }

  void _onLottieComposition(LottieComposition composition) {
    _originalLottieDuration = composition.duration;
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
    final colors = _bgGradients[widget.pet.type] ?? [const Color(0xFFFFD6E7), const Color(0xFFFFF0F5)];
    final hasLottie = _lottieReady[widget.pet.type] ?? false;
    final hasGif = _gifPaths.containsKey(widget.pet.type);
    final accessory = widget.pet.equippedAccessory;
    final hasAccessory = accessory != null && accessory.isNotEmpty;

    // Map accessory IDs to emojis
    const accessoryEmojis = {
      'tophat': '🎩',
      'bowtie': '🎀',
      'sunglasses': '🕶️',
      'crown': '👑',
      'scarf': '🧣',
      'flower': '🌸',
      'headband': '💫',
      'wizard_hat': '🧙',
    };

    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsating glow ring
          _PulseGlow(color: colors[0]),
          Container(
            width: 148,
            height: 148,
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
                child: hasLottie ? _buildLottie() : hasGif ? _buildGif() : _buildEmoji(),
              ),
            ),
          ),
          // Equipped accessory
          if (hasAccessory)
            Positioned(
              top: 2,
              left: 55,
              child: _BounceAccessory(
                emoji: accessoryEmojis[accessory] ?? '🎁',
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: _MoodBubble(mood: widget.pet.moodEmoji),
          ),
          ...widget.particles.asMap().entries.map(
                (e) => _FloatingParticle(
                  key: ValueKey('p_${widget.particleGeneration}_${e.key}'),
                  emoji: e.value,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildLottie() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Lottie.asset(
          _lottiePaths[widget.pet.type]!,
          controller: _lottieCtrl,
          onLoaded: _onLottieComposition,
          width: 125,
          height: 125,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _buildEmoji(),
        ),
        if (widget.pet.isSleeping) const _SleepingZzz(),
      ],
    );
  }

  Widget _buildGif() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _bounceY,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, _bounceY.value),
            child: child,
          ),
          child: Image.asset(
            _gifPaths[widget.pet.type]!,
            width: 110,
            height: 110,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _buildEmoji(),
          ),
        ),
        if (widget.pet.isSleeping) const _SleepingZzz(),
      ],
    );
  }

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

// ── Pulsating glow ring ──────────────────────────────────────────────────────

class _PulseGlow extends StatefulWidget {
  final Color color;
  const _PulseGlow({required this.color});

  @override
  State<_PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<_PulseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
    _scale = Tween<double>(begin: 0.88, end: 1.08)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _opacity = Tween<double>(begin: 0.35, end: 0.12)
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
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              widget.color.withValues(alpha: _opacity.value),
              widget.color.withValues(alpha: 0.0),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Bouncing accessory ──────────────────────────────────────────────────────

class _BounceAccessory extends StatefulWidget {
  final String emoji;
  const _BounceAccessory({required this.emoji});

  @override
  State<_BounceAccessory> createState() => _BounceAccessoryState();
}

class _BounceAccessoryState extends State<_BounceAccessory>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _y;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _y = Tween<double>(begin: 0, end: -4)
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
    return AnimatedBuilder(
      animation: _y,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _y.value), child: child),
      child: Text(widget.emoji, style: const TextStyle(fontSize: 30)),
    );
  }
}

// ── Floating particle (random drift) ──────────────────────────────────────────

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
  late final double _xDrift;

  @override
  void initState() {
    super.initState();
    _xDrift = (Random().nextDouble() - 0.5) * 110;
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
        offset: Offset(_xDrift * _ctrl.value, _y.value),
        child: Opacity(opacity: _opacity.value, child: child),
      ),
      child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
    );
  }
}
