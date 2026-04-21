import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uz_converter/constants/ad_ids.dart';
import 'package:uz_converter/constants/feature_flags.dart';

class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoadingAd = false;

  static const _maxDailyViews = 3;
  static const _todayCountKey = 'rewarded_today_count';
  static const _todayDateKey = 'rewarded_today_date';
  static const _totalCountKey = 'rewarded_total_count';

  static const _thankYouMessages = [
    'Rahmat!',
    'Siz ajoyibsiz!',
    'Loyiha siz tufayli rivojlanadi!',
    'Katta rahmat, do\'stim!',
    'Sizning yordamingiz bebaho!',
    'Har bir ko\'mak muhim — rahmat!',
  ];

  bool get _isSupported =>
      FeatureFlags.adsEnabled && !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  void loadAd() {
    if (!_isSupported || _isLoadingAd || _rewardedAd != null) return;
    _isLoadingAd = true;

    RewardedAd.load(
      adUnitId: AdIds.rewardedAd,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingAd = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _isLoadingAd = false;
        },
      ),
    );
  }

  bool get isAdReady => _rewardedAd != null;

  Future<int> getTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_todayDateKey) ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (savedDate != today) {
      await prefs.setString(_todayDateKey, today);
      await prefs.setInt(_todayCountKey, 0);
      return 0;
    }
    return prefs.getInt(_todayCountKey) ?? 0;
  }

  Future<int> getTotalCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalCountKey) ?? 0;
  }

  Future<bool> canShowToday() async {
    final count = await getTodayCount();
    return count < _maxDailyViews;
  }

  Future<void> _incrementCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString(_todayDateKey, today);
      final todayCount = prefs.getInt(_todayCountKey) ?? 0;
      await prefs.setInt(_todayCountKey, todayCount + 1);
      final totalCount = prefs.getInt(_totalCountKey) ?? 0;
      await prefs.setInt(_totalCountKey, totalCount + 1);
    } catch (e) {
      debugPrint('RewardedAdService _incrementCounts error: $e');
    }
  }

  String getRandomThankYou() {
    return _thankYouMessages[Random().nextInt(_thankYouMessages.length)];
  }

  void showAd({required VoidCallback onRewarded}) {
    if (!FeatureFlags.adsEnabled || _rewardedAd == null) return;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadAd();
      },
    );

    try {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) async {
          await _incrementCounts();
          onRewarded();
        },
      );
    } catch (e) {
      debugPrint('RewardedAd show error: $e');
      _rewardedAd?.dispose();
      _rewardedAd = null;
      loadAd();
    }
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
