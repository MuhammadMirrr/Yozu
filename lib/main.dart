import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'constants/feature_flags.dart';
import 'providers/theme_provider.dart';
import 'services/share_handler_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  if (FeatureFlags.adsEnabled) {
    try {
      MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('MobileAds init error: $e');
    }
  }
  await themeProvider.loadTheme();
  await ShareHandlerService.instance.init();
  runApp(const YozuApp());
}
