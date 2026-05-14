import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

class ActionButton extends StatefulWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.enabled || widget.onTap == null) return;
    HapticFeedback.lightImpact();
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final effective = widget.enabled && widget.onTap != null;

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Opacity(
          opacity: effective ? 1.0 : 0.45,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(widget.icon,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMid,
                        fontSize: 12,
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
