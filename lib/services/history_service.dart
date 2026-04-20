import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversion_record.dart';

class HistoryService {
  static const _key = 'conversion_history';
  static const _maxRecords = 100;

  Future<List<ConversionRecord>> getRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) return [];
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((e) => ConversionRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('HistoryService: $e');
      return [];
    }
  }

  Future<void> _saveRecords(List<ConversionRecord> records) async {
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

    final records = await getRecords();
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
    final records = await getRecords();
    records.removeWhere((r) => r.id == id);
    await _saveRecords(records);
  }

  Future<void> insertRecord(ConversionRecord record, int index) async {
    final records = await getRecords();
    if (index > records.length) index = records.length;
    records.insert(index, record);
    if (records.length > _maxRecords) {
      records.removeRange(_maxRecords, records.length);
    }
    await _saveRecords(records);
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('HistoryService: $e');
    }
  }

  Future<void> toggleFavorite(String id) async {
    final records = await getRecords();
    final index = records.indexWhere((r) => r.id == id);
    if (index != -1) {
      records[index] = records[index].copyWith(isFavorite: !records[index].isFavorite);
      await _saveRecords(records);
    }
  }

  Future<List<ConversionRecord>> getFavorites() async {
    final records = await getRecords();
    return records.where((r) => r.isFavorite).toList();
  }
}
