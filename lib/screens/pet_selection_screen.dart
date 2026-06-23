import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';
import '../widgets/pet_painters.dart';

// ── Per-pet color schemes ────────────────────────────────────────────────────

const _petColors = {
  PetType.cat: (
    bg: Color(0xFFB8C8D8),     // steel blue-grey (like Spotify cat bg)
    accent: Color(0xFFEF6C5B), // coral red
    card: Color(0xFFF5E6E0),
  ),
  PetType.dog: (
    bg: Color(0xFFB8C8D8),     // steel blue-grey
    accent: Color(0xFFEF6C5B), // red-coral
    card: Color(0xFFF0EDE8),
  ),
  PetType.bird: (
    bg: Color(0xFF44D6A0),     // vibrant green
    accent: Color(0xFF2D2D2D), // black
    card: Color(0xFFD4F5E6),
  ),
  PetType.hamster: (
    bg: Color(0xFF44D6A0),     // vibrant green
    accent: Color(0xFFEF6C5B), // coral
    card: Color(0xFFE8F8EE),
  ),
  PetType.iguana: (
    bg: Color(0xFFEF6C5B),     // coral red
    accent: Color(0xFF2EBD7E), // green
    card: Color(0xFFF5E0DC),
  ),
};

class PetSelectionScreen extends ConsumerStatefulWidget {
  const PetSelectionScreen({super.key});

  @override
  ConsumerState<PetSelectionScreen> createState() => _PetSelectionScreenState();
}

class _PetSelectionScreenState extends ConsumerState<PetSelectionScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final PageController _pageCtrl;
  late final AnimationController _enterCtrl;
  late final Animation<double> _fadeIn;

  static const _types = PetType.values;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.65, initialPage: 0);
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeIn = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 100),
        () => mounted ? _enterCtrl.forward() : null);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  void _adopt() {
    HapticFeedback.mediumImpact();
    ref.read(petProvider.notifier).selectPet(_types[_selectedIndex]);
    Navigator.pushReplacementNamed(context, Routes.main);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _petColors[_types[_selectedIndex]]!;
    final pet = Pet(type: _types[_selectedIndex]);
    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      color: colors.bg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FadeTransition(
          opacity: _fadeIn,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  'Pick your pet',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 36,
                        color: const Color(0xFF2D2D2D),
                        letterSpacing: -1.5,
                      ),
                ),
                const SizedBox(height: 8),

                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_types.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _selectedIndex ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _selectedIndex
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFF2D2D2D).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Pet carousel
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      // Wave background
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: size.height * 0.18,
                        child: CustomPaint(
                          painter: _WavePainter(colors.accent.withValues(alpha: 0.2)),
                          size: Size.infinite,
                        ),
                      ),

                      // PageView carousel
                      PageView.builder(
                        controller: _pageCtrl,
                        itemCount: _types.length,
                        onPageChanged: (i) => setState(() => _selectedIndex = i),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _pageCtrl,
                            builder: (context, child) {
                              double value = 0;
                              if (_pageCtrl.position.haveDimensions) {
                                value = index - (_pageCtrl.page ?? 0);
                              }
                              final scale = (1 - (value.abs() * 0.25)).clamp(0.7, 1.0);
                              final opacity = (1 - (value.abs() * 0.5)).clamp(0.4, 1.0);

                              return Transform.scale(
                                scale: scale,
                                child: Opacity(
                                  opacity: opacity,
                                  child: _PetCard(
                                    type: _types[index],
                                    isSelected: index == _selectedIndex,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Pet info
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(_selectedIndex),
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 38,
                              color: const Color(0xFF2D2D2D),
                              letterSpacing: -1,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          pet.personality,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: const Color(0xFF2D2D2D).withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 44),
                        child: Text(
                          pet.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.5,
                            color: const Color(0xFF2D2D2D).withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Adopt button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _AdoptButton(
                    petName: pet.name,
                    accentColor: colors.accent,
                    onTap: _adopt,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pet Card in carousel ────────────────────────────────────────────────────

class _PetCard extends StatelessWidget {
  final PetType type;
  final bool isSelected;

  const _PetCard({required this.type, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pet illustration
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSelected ? 200 : 160,
            height: isSelected ? 200 : 160,
            child: PetIllustration(
              type: type,
              mood: PetMood.happy,
              size: isSelected ? 200 : 160,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wave background painter ──────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  final Color color;
  _WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..cubicTo(
        size.width * 0.25, size.height * 0.1,
        size.width * 0.75, size.height * 0.6,
        size.width, size.height * 0.3,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.color != color;
}

// ── Adopt button ────────────────────────────────────────────────────────────

class _AdoptButton extends StatefulWidget {
  final String petName;
  final Color accentColor;
  final VoidCallback onTap;
  const _AdoptButton({
    required this.petName,
    required this.accentColor,
    required this.onTap,
  });

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(29),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D2D2D).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'ADOPT ${widget.petName.toUpperCase()}',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
