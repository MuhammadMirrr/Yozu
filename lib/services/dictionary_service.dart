import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/dictionary_entry.dart';

/// Foydalanuvchining custom dictionary'i — SQLite + ChangeNotifier singleton.
///
/// `UzbekConverter.latinToCyrillicWithDict()` ga `entries` uzatiladi va
/// algoritm har so'zni lug'atdan qidiradi; topilsa — almashtiradi, aks holda
/// standart algoritm ishlaydi.
class DictionaryService extends ChangeNotifier {
  DictionaryService._internal();
  static final DictionaryService instance = DictionaryService._internal();

  @visibleForTesting
  factory DictionaryService.newForTesting() => DictionaryService._internal();

  Database? _db;
  List<DictionaryEntry>? _cache;

  Future<Database> _database() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'yozu_dictionary.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latin TEXT NOT NULL UNIQUE,
            cyrillic TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_latin ON entries(latin)');
      },
    );
    return _db!;
  }

  Future<List<DictionaryEntry>> getAll() async {
    if (_cache != null) return List.unmodifiable(_cache!);
    try {
      final db = await _database();
      final rows = await db.query('entries', orderBy: 'created_at DESC');
      _cache = rows.map(DictionaryEntry.fromMap).toList();
      return List.unmodifiable(_cache!);
    } catch (e) {
      debugPrint('DictionaryService.getAll: $e');
      _cache = [];
      return List.unmodifiable(_cache!);
    }
  }

  Future<Map<String, String>> getLatinToCyrillicMap() async {
    final all = await getAll();
    return {for (final e in all) e.latin: e.cyrillic};
  }

  Future<Map<String, String>> getCyrillicToLatinMap() async {
    final all = await getAll();
    return {for (final e in all) e.cyrillic: e.latin};
  }

  Future<void> add(String latin, String cyrillic) async {
    if (latin.trim().isEmpty || cyrillic.trim().isEmpty) return;
    try {
      final db = await _database();
      await db.insert(
        'entries',
        {
          'latin': latin.trim(),
          'cyrillic': cyrillic.trim(),
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _cache = null;
      notifyListeners();
    } catch (e) {
      debugPrint('DictionaryService.add: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      final db = await _database();
      await db.delete('entries', where: 'id = ?', whereArgs: [id]);
      _cache = null;
      notifyListeners();
    } catch (e) {
      debugPrint('DictionaryService.delete: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final db = await _database();
      await db.delete('entries');
      _cache = null;
      notifyListeners();
    } catch (e) {
      debugPrint('DictionaryService.clearAll: $e');
    }
  }

  @visibleForTesting
  void invalidateCache() {
    _cache = null;
  }
}
