import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Output maydoni — read-only, `AnimatedBuilder` orqali controller o'zgarishiga
/// reaktiv.
class OutputAreaWidget extends StatelessWidget {
  const OutputAreaWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = isDark
        ? colorScheme.surfaceContainerHighest
        : AppColors.cream;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final outputText = controller.text;
        final charCount = outputText.length;
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                controller: controller,
                readOnly: true,
                maxLines: 4,
                minLines: 2,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.textDark,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'Natija shu yerda ko\'rinadi',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : AppColors.textLight,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedOpacity(
                opacity: outputText.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$charCount ta belgi',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
