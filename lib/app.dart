import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_colors.dart';
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
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.orange,
              brightness: Brightness.light,
            ),
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
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.orange,
              brightness: Brightness.dark,
            ),
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
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
