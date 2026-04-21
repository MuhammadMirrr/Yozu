import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../models/conversion_record.dart';
import '../services/dictionary_service.dart';
import '../services/file_import_service.dart';
import '../services/history_service.dart';
import '../services/share_handler_service.dart';
import '../utils/uzbek_converter.dart';
import '../widgets/action_buttons_row.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/input_area_widget.dart';
import '../widgets/language_pill.dart';
import '../widgets/output_area_widget.dart';
import '../widgets/recent_section.dart';
import '../widgets/swap_row.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  final _historyService = HistoryService.instance;
  final _dictionaryService = DictionaryService.instance;
  Map<String, String> _latinDict = const {};
  Map<String, String> _cyrillicDict = const {};
  bool _isLatinToCyrillic = true;
  Timer? _debounceTimer;
  StreamSubscription<String>? _shareSubscription;

  @override
  void initState() {
    super.initState();
    _shareSubscription =
        ShareHandlerService.instance.textStream.listen(_onSharedText);
    _dictionaryService.addListener(_reloadDictionary);
    _reloadDictionary();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _shareSubscription?.cancel();
    _dictionaryService.removeListener(_reloadDictionary);
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  Future<void> _reloadDictionary() async {
    final latin = await _dictionaryService.getLatinToCyrillicMap();
    final cyrillic = await _dictionaryService.getCyrillicToLatinMap();
    if (!mounted) return;
    setState(() {
      _latinDict = latin;
      _cyrillicDict = cyrillic;
    });
    // Agar input matni bor bo'lsa, yangi dictionary bilan qayta konvert
    if (_inputController.text.isNotEmpty) {
      _onInputChanged(_inputController.text);
    }
  }

  void _onSharedText(String text) {
    if (!mounted || text.isEmpty) return;
    _inputController.text = text;
    _onInputChanged(text);
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
    try {
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
    } catch (e) {
      debugPrint('ConverterScreen onboarding error: $e');
    }
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
      if (mounted) _showSnack('Clipboard xatosi yuz berdi');
    }
  }

  void _onInputChanged(String text) {
    final output = _isLatinToCyrillic
        ? UzbekConverter.latinToCyrillicWithDict(text, _latinDict)
        : UzbekConverter.cyrillicToLatinWithDict(text, _cyrillicDict);
    _outputController.text = output;

    _debounceTimer?.cancel();
    if (text.trim().length >= 3) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _historyService.addRecord(
          inputText: text,
          outputText: output,
          isLatinToCyrillic: _isLatinToCyrillic,
        );
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
          ? UzbekConverter.latinToCyrillicWithDict(oldOutput, _latinDict)
          : UzbekConverter.cyrillicToLatinWithDict(oldOutput, _cyrillicDict);
    });
  }

  void _clearAll() {
    HapticFeedback.selectionClick();
    _inputController.clear();
    _outputController.clear();
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

    if (mounted) _showSnack('Saqlandi!');
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

  Future<void> _importFile() async {
    HapticFeedback.selectionClick();
    final result = await FileImportService.pickAndReadFile();
    if (!mounted) return;
    if (result.isCancelled) return;
    if (result.isError) {
      _showSnack(result.errorMessage ?? 'Fayl xatosi');
      return;
    }
    final text = result.text!;
    _inputController.text = text;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    _onInputChanged(text);
    _showSnack('Fayl yuklandi');
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
      });
      _inputController.text = result.inputText;
      _outputController.text = result.outputText;
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _openStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatsScreen()),
    );
  }

  void _onRecentTap(ConversionRecord record) {
    setState(() {
      _isLatinToCyrillic = record.isLatinToCyrillic;
    });
    _inputController.text = record.inputText;
    _outputController.text = record.outputText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              Icons.bar_chart_rounded,
              color: isDark ? Colors.white70 : AppColors.textLight,
            ),
            tooltip: 'Statistika',
            onPressed: _openStats,
          ),
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
                  LanguagePill(
                    label: _isLatinToCyrillic ? 'Lotin' : 'Кирилл',
                    color: AppColors.purple,
                  ),
                  const SizedBox(height: 8),
                  InputAreaWidget(
                    controller: _inputController,
                    isLatinToCyrillic: _isLatinToCyrillic,
                    onChanged: _onInputChanged,
                    onPaste: _pasteText,
                    onClear: _clearAll,
                    onImport: _importFile,
                  ),
                  const SizedBox(height: 4),
                  SwapRow(onSwap: _swapDirection),
                  const SizedBox(height: 4),
                  LanguagePill(
                    label: _isLatinToCyrillic ? 'Кирилл' : 'Lotin',
                    color: AppColors.lightBlue,
                  ),
                  const SizedBox(height: 8),
                  OutputAreaWidget(controller: _outputController),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _outputController,
                    builder: (context, _) {
                      return ActionButtonsRow(
                        hasOutput: _outputController.text.isNotEmpty,
                        onCopy: _copyOutput,
                        onShare: _shareResult,
                        onSave: _saveToFavorites,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  RecentSection(onTap: _onRecentTap),
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
}
