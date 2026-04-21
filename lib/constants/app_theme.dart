import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_colors_extension.dart';

/// Yozu ilovasining light/dark theme konfiguratsiyasi.
///
/// `ColorScheme.fromSeed` + Material Design 3. Brand ranglari
/// (`AppColors.orange`, `purple`, `lightBlue`) `AppColorsExtension` orqali
/// `Theme.of(context).extension<AppColorsExtension>()` bilan olinadi.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.light,
    ).copyWith(
      surfaceContainerHighest: AppColors.cream,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: GoogleFonts.rubikTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      extensions: const [AppColorsExtension.light],
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.dark,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: GoogleFonts.rubikTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      extensions: const [AppColorsExtension.dark],
    );
  }
}
