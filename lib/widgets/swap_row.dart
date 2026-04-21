import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'swap_button.dart';

/// Input va output orasidagi chiziqli ajratgich + swap button.
class SwapRow extends StatelessWidget {
  const SwapRow({super.key, required this.onSwap});

  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDark ? Colors.white12 : AppColors.cardBorder,
            ),
          ),
          const SizedBox(width: 12),
          SwapButton(onTap: onSwap),
          const SizedBox(width: 12),
          Icon(
            Icons.translate_rounded,
            size: 14,
            color: isDark ? Colors.white38 : AppColors.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            'Konvert',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: isDark ? Colors.white12 : AppColors.cardBorder,
            ),
          ),
        ],
      ),
    );
  }
}
