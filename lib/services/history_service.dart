import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversion_record.dart';

/// Konvertatsiya tarixi. Singleton + ChangeNotifier + memory cache.
///
/// `HistoryService.instance` orqali global foydalaniladi. `ListenableBuilder`
/// yoki `AnimatedBuilder(animation: HistoryService.instance)` orqali
/// o'zgarishlarga reaktiv subscribe qilish mumkin.
///
/// Test uchun `HistoryService.newForTesting()` yangi mustaqil instansiya
/// qaytaradi (cache alohida).
class HistoryService extends ChangeNotifier {
  HistoryService._internal();

  static final HistoryService instance = HistoryService._internal();

  /// Testlar uchun yangi mustaqil instansiya (global cache bilan aralashmaydi).
  @visibleForTesting
  factory HistoryService.newForTesting() => HistoryService._internal();

  static const _key = 'conversion_history';
  static const _maxRecords = 100;

  List<ConversionRecord>? _cache;

  Future<List<ConversionRecord>> getRecords() async {
    if (_cache != null) return List.unmodifiable(_cache!);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) {
        _cache = [];
        return List.unmodifiable(_cache!);
      }
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cache = jsonList
          .map((e) => ConversionRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      return List.unmodifiable(_cache!);
    } catch (e) {
      debugPrint('HistoryService: $e');
      _cache = [];
      return List.unmodifiable(_cache!);
    }
  }

  Future<void> _saveRecords(List<ConversionRecord> records) async {
    _cache = List.of(records);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(records.map((e) => e.toJson()).toList());
      await prefs.setString(_key, jsonString);
    } catch (e) {
      debugPrint('HistoryService: $e');
    }
  }

  Future<void> addRecord({
    required String inputText,
    required String outputText,
    required bool isLatinToCyrillic,
  }) async {
    if (inputText.trim().length < 3) return;

    final records = List<ConversionRecord>.from(await getRecords());
    final record = ConversionRecord.create(
      inputText: inputText,
      outputText: outputText,
      isLatinToCyrillic: isLatinToCyrillic,
    );
    records.insert(0, record);

    if (records.length > _maxRecords) {
      records.removeRange(_maxRecords, records.length);
    }

    await _saveRecords(records);
  }

  Future<void> deleteRecord(String id) async {
    final records = List<ConversionRecord>.from(await getRecords());
    records.removeWhere((r) => r.id == id);
    await _saveRecords(records);
  }

  Future<void> insertRecord(ConversionRecord record, int index) async {
    final records = List<ConversionRecord>.from(await getRecords());
    if (index > records.length) index = records.length;
    records.insert(index, record);
    if (records.length > _maxRecords) {
      records.removeRange(_maxRecords, records.length);
    }
    await _saveRecords(records);
  }

  Future<void> clearAll() async {
    _cache = [];
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('HistoryService: $e');
    }
  }

  Future<void> toggleFavorite(String id) async {
    final records = List<ConversionRecord>.from(await getRecords());
    final index = records.indexWhere((r) => r.id == id);
    if (index != -1) {
      records[index] =
          records[index].copyWith(isFavorite: !records[index].isFavorite);
      await _saveRecords(records);
    }
  }

  Future<List<ConversionRecord>> getFavorites() async {
    final records = await getRecords();
    return records.where((r) => r.isFavorite).toList();
  }

  /// Cache'ni bo'shatish (testlar va foydalanuvchi logout/reset uchun).
  @visibleForTesting
  void invalidateCache() {
    _cache = null;
  }
}
