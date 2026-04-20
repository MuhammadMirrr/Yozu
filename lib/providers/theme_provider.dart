import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ValueNotifier<ThemeMode> {
  static const _key = 'theme_mode';

  ThemeProvider() : super(ThemeMode.system);

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_key);
      if (value != null) {
        switch (value) {
          case 'light':
            this.value = ThemeMode.light;
          case 'dark':
            this.value = ThemeMode.dark;
          default:
            this.value = ThemeMode.system;
        }
      }
    } catch (e) {
      debugPrint('ThemeProvider: $e');
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString(_key, name);
    } catch (e) {
      debugPrint('ThemeProvider: $e');
    }
  }
}

final themeProvider = ThemeProvider();
