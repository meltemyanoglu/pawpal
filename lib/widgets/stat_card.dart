import 'package:flutter/material.dart';
import '../core/theme.dart';

class StatCard extends StatefulWidget {
  final String icon;
  final String label;
  final double value; // 0–100
  final Color color;
  final List<Color> gradient;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.gradient,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _pulseScale = Tween<double>(begin: 1.0, end: 1.03)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _checkPulse();
  }

  @override
  void didUpdateWidget(StatCard old) {
    super.didUpdateWidget(old);
    _checkPulse();
  }

  void _checkPulse() {
    if (widget.value < 25) {
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
      _pulseCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color get _valueColor {
    if (widget.value < 25) return const Color(0xFFFF4C6A);
    if (widget.value < 50) return Colors.orange;
    return widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseScale,
      builder: (_, child) =>
          Transform.scale(scale: _pulseScale.value, child: child),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
          border: widget.value < 25
              ? Border.all(
                  color: const Color(0xFFFF4C6A).withValues(alpha: 0.4),
                  width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon bubble
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child:
                        Text(widget.icon, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                // Value (big, colored)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: widget.value),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (_, v, _) => Text(
                    v.toInt().toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _valueColor,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                    fontFamily: 'Nunito',
                  ),
                ),
                if (widget.value < 25)
                  const Text('⚠️', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: widget.value / 100),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.55),
                  valueColor: AlwaysStoppedAnimation<Color>(_valueColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
