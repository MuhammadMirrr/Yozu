import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uz_converter/constants/ad_ids.dart';

class AppOpenAdService {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isLoadingAd = false;
  DateTime? _lastBackgroundTime;

  static const _backgroundThreshold = Duration(seconds: 30);

  bool get _isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  void loadAd() {
    if (!_isSupported || _isLoadingAd || _appOpenAd != null) return;
    _isLoadingAd = true;

    AppOpenAd.load(
      adUnitId: AdIds.appOpenAd,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isLoadingAd = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
          _isLoadingAd = false;
        },
      ),
    );
  }

  void onBackground() {
    _lastBackgroundTime = DateTime.now();
  }

  void onForeground() {
    if (_lastBackgroundTime == null) return;

    final elapsed = DateTime.now().difference(_lastBackgroundTime!);
    _lastBackgroundTime = null;

    if (elapsed >= _backgroundThreshold) {
      showAdIfAvailable();
    }
  }

  void showAdIfAvailable() {
    if (_appOpenAd == null || _isShowingAd) return;
    _isShowingAd = true;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );

    try {
      _appOpenAd!.show();
    } catch (e) {
      debugPrint('AppOpenAd show error: $e');
      _isShowingAd = false;
      _appOpenAd?.dispose();
      _appOpenAd = null;
      loadAd();
    }
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}
