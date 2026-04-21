import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/feature_flags.dart';
import '../providers/theme_provider.dart';
import '../services/rewarded_ad_service.dart';
import 'dictionary_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _clipboardAutoDetect = true;
  final _rewardedAdService = RewardedAdService();
  int _todayCount = 0;
  int _totalCount = 0;
  bool _canShow = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    if (FeatureFlags.adsEnabled) {
      _rewardedAdService.loadAd();
      _loadRewardCounts();
    }
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = '${info.version}+${info.buildNumber}';
        });
      }
    } catch (e) {
      debugPrint('SettingsScreen: PackageInfo error: $e');
    }
  }

  @override
  void dispose() {
    _rewardedAdService.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _clipboardAutoDetect =
            prefs.getBool('clipboard_auto_detect') ?? false;
      });
    } catch (e) {
      debugPrint('SettingsScreen: $e');
    }
  }

  Future<void> _loadRewardCounts() async {
    final todayCount = await _rewardedAdService.getTodayCount();
    final totalCount = await _rewardedAdService.getTotalCount();
    final canShow = await _rewardedAdService.canShowToday();
    if (mounted) {
      setState(() {
        _todayCount = todayCount;
        _totalCount = totalCount;
        _canShow = canShow;
      });
    }
  }

  Future<void> _setClipboardAutoDetect(bool value) async {
    setState(() => _clipboardAutoDetect = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('clipboard_auto_detect', value);
    } catch (e) {
      debugPrint('SettingsScreen: $e');
    }
  }

  void _onSupportTap() {
    if (!_canShow) return;

    if (!_rewardedAdService.isAdReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reklama yuklanmoqda, biroz kuting...'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    _rewardedAdService.showAd(
      onRewarded: () {
        _loadRewardCounts();
        if (mounted) {
          _showThankYouDialog();
        }
      },
    );
  }

  void _showThankYouDialog() {
    final message = _rewardedAdService.getRandomThankYou();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(
          Icons.favorite_rounded,
          size: 48,
          color: AppColors.orange,
        ),
        title: Text(message),
        content: const Text(
          'Sizning qo\'llab-quvvatlashingiz ilovani\nyaxshilashga yordam beradi!',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.orange),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sozlamalar'),
      ),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeProvider,
        builder: (context, currentMode, _) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Ko\'rinish',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode),
                      label: Text('Yorug\''),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode),
                      label: Text('Qorong\'u'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.phone_android),
                      label: Text('Tizim'),
                    ),
                  ],
                  selected: {currentMode},
                  onSelectionChanged: (selected) {
                    themeProvider.setTheme(selected.first);
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Funksiyalar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Clipboard avtomatik aniqlash'),
                subtitle: const Text(
                    'Ilova ochilganda clipboard dagi matnni taklif qilish'),
                value: _clipboardAutoDetect,
                onChanged: _setClipboardAutoDetect,
              ),
              ListTile(
                leading: const Icon(Icons.book_outlined),
                title: const Text('Shaxsiy lug\'at'),
                subtitle: const Text(
                    'Maxsus so\'zlar — ismlar, brendlar, dialekt'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DictionaryScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              // Qo'llab-quvvatlash bo'limi (faqat reklama yoqilganda)
              if (FeatureFlags.adsEnabled) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Qo\'llab-quvvatlash',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSupportCard(isDark, colorScheme),
                ),
                const Divider(height: 32),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Ilova haqida',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Versiya'),
                trailing: Text(
                  _appVersion.isNotEmpty ? _appVersion : '...',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _buildDeveloperCard(isDark, colorScheme),
              ),
              ListTile(
                leading: const Icon(Icons.star_rate_outlined),
                title: const Text('Baho bering'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
                onTap: () async {
                  try {
                    final inAppReview = InAppReview.instance;
                    await inAppReview.openStoreListing(
                      appStoreId: 'com.uzbapps.converter',
                    );
                  } catch (e) {
                    debugPrint('InAppReview error: $e');
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Baholashda xatolik yuz berdi'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openTelegram() async {
    final uri = Uri.parse('https://t.me/mirqobilov_mm');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        _showSnack('Telegram ochib bo\'lmadi');
      }
    } catch (e) {
      debugPrint('Telegram launch error: $e');
      if (mounted) _showSnack('Telegram ochib bo\'lmadi');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDeveloperCard(bool isDark, ColorScheme colorScheme) {
    const telegramBlue = Color(0xFF229ED9);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.orange.withValues(alpha: isDark ? 0.18 : 0.1),
            AppColors.purple.withValues(alpha: isDark ? 0.12 : 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.orange.withValues(alpha: isDark ? 0.25 : 0.18),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.orange, AppColors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'MM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ishlab chiqaruvchi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : AppColors.textLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Muhammad Mirqobilov',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          InkWell(
            onTap: _openTelegram,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: telegramBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.send_rounded,
                      color: telegramBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Telegram',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@mirqobilov_mm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: isDark ? Colors.white38 : AppColors.textLight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(bool isDark, ColorScheme colorScheme) {
    final remaining = 3 - _todayCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: _canShow
              ? [
                  AppColors.orange.withValues(alpha: isDark ? 0.2 : 0.1),
                  AppColors.purple.withValues(alpha: isDark ? 0.15 : 0.08),
                ]
              : [
                  (isDark ? Colors.white10 : Colors.grey.shade100),
                  (isDark ? Colors.white10 : Colors.grey.shade100),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: _canShow
              ? AppColors.orange.withValues(alpha: isDark ? 0.3 : 0.2)
              : (isDark ? Colors.white12 : Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: _canShow
                    ? AppColors.orange
                    : (isDark ? Colors.white38 : Colors.grey),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dasturchini qo\'llab-quvvatlash',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _canShow
                        ? (isDark ? Colors.white : AppColors.textDark)
                        : (isDark ? Colors.white38 : Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Qisqa video ko\'rish orqali loyihani rivojlantirishga hissa qo\'shing.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : AppColors.textLight,
            ),
          ),
          if (_totalCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Jami $_totalCount marta yordam berdingiz',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _canShow
                    ? AppColors.purple
                    : (isDark ? Colors.white38 : Colors.grey),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _canShow ? _onSupportTap : null,
              icon: Icon(
                _canShow ? Icons.play_circle_outline_rounded : Icons.check_circle_outline_rounded,
                size: 20,
              ),
              label: Text(
                _canShow
                    ? 'Video ko\'rish ($remaining/3 qoldi)'
                    : 'Bugun yetarli, rahmat!',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _canShow ? AppColors.orange : null,
                disabledBackgroundColor:
                    isDark ? Colors.white12 : Colors.grey.shade300,
                disabledForegroundColor:
                    isDark ? Colors.white38 : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
