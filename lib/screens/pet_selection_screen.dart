import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';

class PetSelectionScreen extends ConsumerStatefulWidget {
  const PetSelectionScreen({super.key});

  @override
  ConsumerState<PetSelectionScreen> createState() =>
      _PetSelectionScreenState();
}

class _PetSelectionScreenState extends ConsumerState<PetSelectionScreen> {
  PetType _selected = PetType.cat;
  late final PageController _pageCtrl;

  static const _pets = [PetType.cat, PetType.dog, PetType.rabbit];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.75, initialPage: 0);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F5), Color(0xFFFFF8F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildPageView(),
              const SizedBox(height: 32),
              _buildDots(),
              const SizedBox(height: 32),
              _buildStats(),
              const Spacer(),
              _buildConfirmButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose your', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16)),
          Text('companion ✨',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 34)),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _pageCtrl,
        itemCount: _pets.length,
        onPageChanged: (i) => setState(() => _selected = _pets[i]),
        itemBuilder: (context, i) {
          final type = _pets[i];
          final isSelected = type == _selected;
          return AnimatedScale(
            scale: isSelected ? 1.0 : 0.88,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: _PetCard(type: type, isSelected: isSelected),
          );
        },
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _pets.asMap().entries.map((e) {
        final active = _pets[e.key] == _selected;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStats() {
    final pet = Pet(type: _selected);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pet.name,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(pet.personality,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    )),
            const SizedBox(height: 10),
            Text(pet.description,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: GestureDetector(
        onTap: _confirm,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: AppTheme.glowShadow(AppTheme.primary),
          ),
          child: Center(
            child: Text(
              'Adopt ${Pet(type: _selected).name}! 🐾',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirm() {
    ref.read(petProvider.notifier).selectPet(_selected);
    Navigator.pushReplacementNamed(context, Routes.main);
  }
}

// ── Pet Card ──────────────────────────────────────────────────────────────────

class _PetCard extends StatelessWidget {
  final PetType type;
  final bool isSelected;

  const _PetCard({required this.type, required this.isSelected});

  static const _gradients = {
    PetType.cat: [Color(0xFFFFD6E7), Color(0xFFFFF0F5)],
    PetType.dog: [Color(0xFFD6EEFF), Color(0xFFF0F8FF)],
    PetType.rabbit: [Color(0xFFD6FFE8), Color(0xFFF0FFF4)],
  };

  @override
  Widget build(BuildContext context) {
    final pet = Pet(type: type);
    final colors = _gradients[type]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(32),
        border: isSelected
            ? Border.all(color: AppTheme.primary, width: 3)
            : null,
        boxShadow: isSelected
            ? AppTheme.glowShadow(AppTheme.primary)
            : AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BreathingEmoji(emoji: pet.emoji),
          const SizedBox(height: 16),
          Text(pet.name,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(pet.personality,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMid,
                    )),
          ),
        ],
      ),
    );
  }
}

class _BreathingEmoji extends StatefulWidget {
  final String emoji;
  const _BreathingEmoji({required this.emoji});

  @override
  State<_BreathingEmoji> createState() => _BreathingEmojiState();
}

class _BreathingEmojiState extends State<_BreathingEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _scale = Tween<double>(begin: 0.95, end: 1.05)
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
      animation: _scale,
      builder: (_,  _) => Transform.scale(
        scale: _scale.value,
        child: Text(widget.emoji, style: const TextStyle(fontSize: 80)),
      ),
    );
  }
}
