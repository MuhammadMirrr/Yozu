import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Konvertatsiya natijasi uchun 3 ta dumaloq action tugma: Nusxa, Ulashish, Saqlash.
class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({
    super.key,
    required this.hasOutput,
    required this.onCopy,
    required this.onShare,
    required this.onSave,
  });

  final bool hasOutput;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionCircle(
          icon: Icons.copy_rounded,
          label: 'Nusxa',
          color: AppColors.lightBlue,
          size: 48,
          iconSize: 20,
          onTap: hasOutput ? onCopy : null,
        ),
        const SizedBox(width: 24),
        _ActionCircle(
          icon: Icons.share_rounded,
          label: 'Ulashish',
          color: AppColors.orange,
          size: 58,
          iconSize: 24,
          onTap: hasOutput ? onShare : null,
        ),
        const SizedBox(width: 24),
        _ActionCircle(
          icon: Icons.star_rounded,
          label: 'Saqlash',
          color: AppColors.purple,
          size: 48,
          iconSize: 20,
          onTap: hasOutput ? onSave : null,
        ),
      ],
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = onTap == null;
    final circleColor = isDisabled
        ? (isDark ? Colors.white12 : AppColors.cardBorder)
        : color;

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: isDisabled
                      ? circleColor
                      : circleColor.withValues(alpha: isDark ? 0.25 : 1.0),
                  shape: BoxShape.circle,
                  boxShadow: isDisabled
                      ? null
                      : [
                          BoxShadow(
                            color: circleColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: isDisabled
                      ? (isDark ? Colors.white24 : AppColors.textLight)
                      : (isDark ? color : Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? (isDark ? Colors.white24 : AppColors.textLight)
                      : (isDark ? Colors.white70 : AppColors.textDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
