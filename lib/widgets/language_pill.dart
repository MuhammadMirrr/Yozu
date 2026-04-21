import 'package:flutter/material.dart';

/// Kichik yumaloq rangli indikator — manba yoki manzil tilini ko'rsatish uchun.
class LanguagePill extends StatelessWidget {
  const LanguagePill({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: '$label tili tanlangan',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.2 : 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? color.withValues(alpha: 0.9) : color,
          ),
        ),
      ),
    );
  }
}
