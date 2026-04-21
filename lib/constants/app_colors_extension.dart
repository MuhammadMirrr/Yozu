import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Brand (Quari-inspired) accent ranglari uchun `ThemeExtension`.
///
/// Foydalanish:
/// ```dart
/// final brand = Theme.of(context).extension<AppColorsExtension>()!;
/// final orange = brand.orange;
/// ```
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.orange,
    required this.purple,
    required this.lightBlue,
    required this.cream,
  });

  final Color orange;
  final Color purple;
  final Color lightBlue;
  final Color cream;

  static const light = AppColorsExtension(
    orange: AppColors.orange,
    purple: AppColors.purple,
    lightBlue: AppColors.lightBlue,
    cream: AppColors.cream,
  );

  // Dark mode uchun oz ozgina yumshatilgan ranglar
  static const dark = AppColorsExtension(
    orange: AppColors.orange,
    purple: AppColors.purple,
    lightBlue: AppColors.lightBlue,
    cream: Color(0xFF2A2A2A),
  );

  @override
  AppColorsExtension copyWith({
    Color? orange,
    Color? purple,
    Color? lightBlue,
    Color? cream,
  }) {
    return AppColorsExtension(
      orange: orange ?? this.orange,
      purple: purple ?? this.purple,
      lightBlue: lightBlue ?? this.lightBlue,
      cream: cream ?? this.cream,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      orange: Color.lerp(orange, other.orange, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      lightBlue: Color.lerp(lightBlue, other.lightBlue, t)!,
      cream: Color.lerp(cream, other.cream, t)!,
    );
  }
}
