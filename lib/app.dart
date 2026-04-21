import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/app_open_ad_service.dart';

class YozuApp extends StatefulWidget {
  const YozuApp({super.key});

  @override
  State<YozuApp> createState() => _YozuAppState();
}

class _YozuAppState extends State<YozuApp> {
  final _appOpenAdService = AppOpenAdService();
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _appOpenAdService.loadAd();
    _lifecycleListener = AppLifecycleListener(
      onHide: _appOpenAdService.onBackground,
      onShow: _appOpenAdService.onForeground,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _appOpenAdService.dispose();
    super.dispose();
  }

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
