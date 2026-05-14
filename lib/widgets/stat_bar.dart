import 'package:flutter/material.dart';
import '../core/theme.dart';

class StatBar extends StatelessWidget {
  final String icon;
  final String label;
  final double value; // 0–100
  final Color color;

  const StatBar({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMid,
                    )),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: value / 100),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (_, v,  _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 10,
                  backgroundColor: color.withValues(alpha: 0.18),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _colorForValue(value, color),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 32,
            child: Text(
              '${value.toInt()}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _colorForValue(value, color),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForValue(double v, Color base) {
    if (v < 25) return const Color(0xFFFF4C6A);
    if (v < 50) return Colors.orange;
    return base;
  }
}
