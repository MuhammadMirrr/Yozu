import 'dart:io';
import 'package:flutter/foundation.dart';

class AdIds {
  AdIds._();

  // App Open Ad
  static String get appOpenAd {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/9257395921' // Test ID
          : 'ca-app-pub-2977939261747724/3309826329';
    }
    if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/5575463023' // Test ID
          : 'ca-app-pub-XXXXX/XXXXX'; // TODO: iOS Production ID qo'yish
    }
    return '';
  }

  // Rewarded Ad
  static String get rewardedAd {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/5224354917' // Test ID
          : 'ca-app-pub-2977939261747724/8430157618';
    }
    if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/1712485313' // Test ID
          : 'ca-app-pub-XXXXX/XXXXX'; // TODO: iOS Production ID qo'yish
    }
    return '';
  }

  // Banner Ad
  static String get bannerAd {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111' // Test ID
          : 'ca-app-pub-2977939261747724/3369402629';
    }
    if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/2934735716' // Test ID
          : 'ca-app-pub-XXXXX/XXXXX'; // TODO: iOS Production ID qo'yish
    }
    return '';
  }
}
