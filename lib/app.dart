import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

class YozuApp extends StatelessWidget {
  const YozuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeProvider,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Yozu',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const SplashScreen(),
        );
      },
    );
  }
}
