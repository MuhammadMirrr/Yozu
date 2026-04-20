import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../models/conversion_record.dart';
import '../services/history_service.dart';
import '../utils/uzbek_converter.dart';
import '../widgets/swap_button.dart';
import '../widgets/banner_ad_widget.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  final _historyService = HistoryService();
  bool _isLatinToCyrillic = true;
  Timer? _debounceTimer;
  List<ConversionRecord> _recentRecords = [];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() => setState(() {}));
    _loadRecentRecords();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentRecords() async {
    try {
      final records = await _historyService.getRecords();
      if (mounted) {
        setState(() {
          _recentRecords = records.take(6).toList();
        });
      }
    } catch (e) {
      debugPrint('ConverterScreen: $e');
    }
  }

  Future<void> _checkOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shown = prefs.getBool('onboarding_shown') ?? false;
      if (!shown && mounted) {
        await _showOnboarding();
        await prefs.setBool('onboarding_shown', true);
      }
      if (mounted) {
        await _checkClipboard();
      }
    } catch (e) {
      debugPrint('ConverterScreen: $e');
    }
  }

  Future<void> _showOnboarding() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(
          Icons.translate_rounded,
          size: 48,
          color: AppColors.orange,
        ),
        title: const Text('Yozu ga xush kelibsiz!'),
        content: const Text(
          'Lotincha matn yozing — avtomatik kirillchaga aylanadi.\n\n'
          'Teskari yo\'nalish uchun ↕ tugmani bosing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.orange),
            child: const Text('Boshlash'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkClipboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final autoDetect = prefs.getBool('clipboard_auto_detect') ?? false;
      if (!autoDetect || !mounted) return;

      final data = await Clipboard.getData('text/plain');
      if (data?.text != null && data!.text!.trim().length >= 3 && mounted) {
        final preview = data.text!.length > 50
            ? '${data.text!.substring(0, 50)}...'
            : data.text!;

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            title: const Text('Clipboard da matn bor'),
            content: Text('$preview\n\nKonvert qilsinmi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Yo\'q'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.orange),
                child: const Text('Ha'),
              ),
            ],
          ),
        );

        if (confirmed == true && mounted) {
          _inputController.text = data.text!;
          _onInputChanged(data.text!);
        }
      }
    } catch (e) {
      debugPrint('ConverterScreen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Clipboard xatosi yuz berdi'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _onInputChanged(String text) {
    final output = _isLatinToCyrillic
        ? UzbekConverter.latinToCyrillic(text)
        : UzbekConverter.cyrillicToLatin(text);

    setState(() {
      _outputController.text = output;
    });

    _debounceTimer?.cancel();
    if (text.trim().length >= 3) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _historyService.addRecord(
          inputText: text,
          outputText: output,
          isLatinToCyrillic: _isLatinToCyrillic,
        );
        _loadRecentRecords();
      });
    }
  }

  void _swapDirection() {
    HapticFeedback.selectionClick();
    setState(() {
      _isLatinToCyrillic = !_isLatinToCyrillic;
      final oldOutput = _outputController.text;
      _inputController.text = oldOutput;
      _outputController.text = _isLatinToCyrillic
          ? UzbekConverter.latinToCyrillic(oldOutput)
          : UzbekConverter.cyrillicToLatin(oldOutput);
    });
  }

  void _clearAll() {
    HapticFeedback.selectionClick();
    setState(() {
      _inputController.clear();
      _outputController.clear();
    });
  }

  void _copyOutput() {
    if (_outputController.text.isNotEmpty) {
      HapticFeedback.lightImpact();
      Clipboard.setData(ClipboardData(text: _outputController.text));
      FocusScope.of(context).unfocus();
      _showSnack('Nusxalandi!');
    }
  }

  void _shareResult() {
    final text = _outputController.text;
    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      FocusScope.of(context).unfocus();
      Share.share(text);
    }
  }

  Future<void> _saveToFavorites() async {
    final input = _inputController.text.trim();
    final output = _outputController.text.trim();
    if (input.isEmpty || output.isEmpty) return;

    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();

    final records = await _historyService.getRecords();
    final match = records
        .where((r) => r.inputText == input && r.outputText == output)
        .toList();
    if (match.isNotEmpty) {
      await _historyService.toggleFavorite(match.first.id);
    } else {
      await _historyService.addRecord(
        inputText: input,
        outputText: output,
        isLatinToCyrillic: _isLatinToCyrillic,
      );
      final updated = await _historyService.getRecords();
      if (updated.isNotEmpty) {
        await _historyService.toggleFavorite(updated.first.id);
      }
    }

    if (mounted) {
      _showSnack('Saqlandi!');
      _loadRecentRecords();
    }
  }

  Future<void> _pasteText() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      _inputController.text = data.text!;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: _inputController.text.length),
      );
      _onInputChanged(_inputController.text);
    } else {
      if (mounted) _showSnack('Clipboard bo\'sh');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openHistory() async {
    final result = await Navigator.push<ConversionRecord>(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _isLatinToCyrillic = result.isLatinToCyrillic;
        _inputController.text = result.inputText;
        _outputController.text = result.outputText;
      });
    }
    _loadRecentRecords();
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _onRecentTap(ConversionRecord record) {
    setState(() {
      _isLatinToCyrillic = record.isLatinToCyrillic;
      _inputController.text = record.inputText;
      _outputController.text = record.outputText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Yozu ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const Text(
              'Konverter',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 22,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history_rounded,
              color: isDark ? Colors.white70 : AppColors.textLight,
            ),
            tooltip: 'Tarix',
            onPressed: _openHistory,
          ),
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: isDark ? Colors.white70 : AppColors.textLight,
            ),
            tooltip: 'Sozlamalar',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  // Source language pill
                  _buildLanguagePill(
                    label: _isLatinToCyrillic ? 'Lotin' : 'Кирилл',
                    color: AppColors.purple,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  // Input area
                  _buildInputArea(isDark, colorScheme),
                  const SizedBox(height: 4),
                  // Swap row
                  _buildSwapRow(isDark, colorScheme),
                  const SizedBox(height: 4),
                  // Target language pill
                  _buildLanguagePill(
                    label: _isLatinToCyrillic ? 'Кирилл' : 'Lotin',
                    color: AppColors.lightBlue,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  // Output area
                  _buildOutputArea(isDark, colorScheme),
                  const SizedBox(height: 20),
                  // Action circles (Quari-style)
                  _buildActionCircles(isDark),
                  // Recent conversions
                  if (_recentRecords.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildRecentSection(isDark, colorScheme),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const BannerAdWidget(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildLanguagePill({
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Semantics(
      label: '$label tili tanlangan',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? color.withValues(alpha: 0.9) : color,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark, ColorScheme colorScheme) {
    final bgColor = isDark
        ? colorScheme.surfaceContainerHighest
        : AppColors.cream;
    final inputText = _inputController.text;
    final charCount = inputText.length;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          TextFormField(
            controller: _inputController,
            onChanged: _onInputChanged,
            maxLines: 4,
            minLines: 2,
            maxLength: 10000,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            buildCounter: (context,
                {required currentLength,
                required isFocused,
                required maxLength}) {
              if (currentLength > 9000) {
                return Text('$currentLength / $maxLength');
              }
              return null;
            },
            keyboardType: TextInputType.multiline,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.textDark,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: _isLatinToCyrillic
                  ? 'Lotincha yozing...'
                  : 'Кириллча ёзинг...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : AppColors.textLight,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // Paste icon
              _buildMiniAction(
                icon: Icons.content_paste_rounded,
                onTap: _pasteText,
                isDark: isDark,
                tooltip: 'Qo\'yish',
              ),
              const SizedBox(width: 8),
              // Clear icon
              _buildMiniAction(
                icon: Icons.close_rounded,
                onTap: inputText.isNotEmpty ? _clearAll : null,
                isDark: isDark,
                tooltip: 'Tozalash',
              ),
              const Spacer(),
              // Character count
              AnimatedOpacity(
                opacity: inputText.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$charCount ta belgi',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAction({
    required IconData icon,
    VoidCallback? onTap,
    required bool isDark,
    String? tooltip,
  }) {
    final color = onTap != null
        ? (isDark ? Colors.white54 : AppColors.textLight)
        : (isDark ? Colors.white24 : AppColors.cardBorder);
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      splashRadius: 20,
    );
  }

  Widget _buildSwapRow(bool isDark, ColorScheme colorScheme) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDark ? Colors.white12 : AppColors.cardBorder,
            ),
          ),
          const SizedBox(width: 12),
          SwapButton(onTap: _swapDirection),
          const SizedBox(width: 12),
          Icon(
            Icons.translate_rounded,
            size: 14,
            color: isDark ? Colors.white38 : AppColors.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            'Konvert',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: isDark ? Colors.white12 : AppColors.cardBorder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputArea(bool isDark, ColorScheme colorScheme) {
    final bgColor = isDark
        ? colorScheme.surfaceContainerHighest
        : AppColors.cream;
    final outputText = _outputController.text;
    final charCount = outputText.length;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextFormField(
            controller: _outputController,
            readOnly: true,
            maxLines: 4,
            minLines: 2,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.textDark,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Natija shu yerda ko\'rinadi',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : AppColors.textLight,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: outputText.isNotEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              '$charCount ta belgi',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCircles(bool isDark) {
    final hasOutput = _outputController.text.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nusxa (Copy) — light purple
        _buildActionCircle(
          icon: Icons.copy_rounded,
          label: 'Nusxa',
          color: AppColors.lightBlue,
          size: 48,
          iconSize: 20,
          onTap: hasOutput ? _copyOutput : null,
          isDark: isDark,
        ),
        const SizedBox(width: 24),
        // Ulashish (Share) — orange, bigger (Quari center button)
        _buildActionCircle(
          icon: Icons.share_rounded,
          label: 'Ulashish',
          color: AppColors.orange,
          size: 58,
          iconSize: 24,
          onTap: hasOutput ? _shareResult : null,
          isDark: isDark,
        ),
        const SizedBox(width: 24),
        // Saqlash (Save) — purple
        _buildActionCircle(
          icon: Icons.star_rounded,
          label: 'Saqlash',
          color: AppColors.purple,
          size: 48,
          iconSize: 20,
          onTap: hasOutput ? _saveToFavorites : null,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildActionCircle({
    required IconData icon,
    required String label,
    required Color color,
    required double size,
    required double iconSize,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    final isDisabled = onTap == null;
    final circleColor = isDisabled
        ? (isDark ? Colors.white12 : AppColors.cardBorder)
        : color;

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: isDisabled
                      ? circleColor
                      : circleColor.withValues(alpha: isDark ? 0.25 : 1.0),
                  shape: BoxShape.circle,
                  boxShadow: isDisabled
                      ? null
                      : [
                          BoxShadow(
                            color: circleColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: isDisabled
                      ? (isDark ? Colors.white24 : AppColors.textLight)
                      : (isDark ? color : Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? (isDark ? Colors.white24 : AppColors.textLight)
                      : (isDark ? Colors.white70 : AppColors.textDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSection(bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Oxirgi konvertatsiyalar',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white38 : AppColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentRecords.map((record) {
            final input = record.inputText.length > 12
                ? '${record.inputText.substring(0, 12)}…'
                : record.inputText;
            final output = record.outputText.length > 12
                ? '${record.outputText.substring(0, 12)}…'
                : record.outputText;

            return GestureDetector(
              onTap: () => _onRecentTap(record),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.cream,
                  border: Border.all(
                    color: isDark ? Colors.white12 : AppColors.cardBorder,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '$input → $output',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppColors.textDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
