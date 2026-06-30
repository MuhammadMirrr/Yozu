import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';
import 'providers/theme_provider.dart';
import 'services/share_handler_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await themeProvider.loadTheme();
  await ShareHandlerService.instance.init();
  runApp(const YozuApp());
}
