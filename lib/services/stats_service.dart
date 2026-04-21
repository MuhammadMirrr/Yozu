import '../models/conversion_record.dart';
import 'history_service.dart';

/// Statistika metriklari.
class StatsData {
  const StatsData({
    required this.totalCount,
    required this.latinToCyrillicCount,
    required this.cyrillicToLatinCount,
    required this.favoritesCount,
    required this.totalChars,
    required this.longestConversion,
    required this.dailyCounts,
  });

  /// Umumiy konvertatsiyalar soni.
  final int totalCount;

  /// Lotin → Kirill yo'nalishi soni.
  final int latinToCyrillicCount;

  /// Kirill → Lotin yo'nalishi soni.
  final int cyrillicToLatinCount;

  /// Sevimlilar soni.
  final int favoritesCount;

  /// Jami konvertatsiya qilingan belgilar (input).
  final int totalChars;

  /// Eng uzun konvertatsiya (belgi soni).
  final int longestConversion;

  /// Oxirgi 7 kun bo'yicha kunlik konvertatsiya soni (bugundan 6 kun oldingacha).
  ///
  /// Ro'yxatning [0]-elementi bugungi kun, [6] — 6 kun oldingi.
  final List<int> dailyCounts;

  bool get isEmpty => totalCount == 0;
}

class StatsService {
  StatsService._();

  static Future<StatsData> compute() async {
    final records = await HistoryService.instance.getRecords();
    if (records.isEmpty) {
      return const StatsData(
        totalCount: 0,
        latinToCyrillicCount: 0,
        cyrillicToLatinCount: 0,
        favoritesCount: 0,
        totalChars: 0,
        longestConversion: 0,
        dailyCounts: [0, 0, 0, 0, 0, 0, 0],
      );
    }

    final totalCount = records.length;
    final latinCount = records.where((r) => r.isLatinToCyrillic).length;
    final cyrillicCount = totalCount - latinCount;
    final favoritesCount = records.where((r) => r.isFavorite).length;
    final totalChars =
        records.fold<int>(0, (sum, r) => sum + r.inputText.length);
    final longestConversion = records.fold<int>(
        0, (max, r) => r.inputText.length > max ? r.inputText.length : max);

    // Oxirgi 7 kun
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dailyCounts = List<int>.filled(7, 0);
    for (final record in records) {
      final recordDate = DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(record.id) ?? now.millisecondsSinceEpoch);
      final recordDay =
          DateTime(recordDate.year, recordDate.month, recordDate.day);
      final diff = today.difference(recordDay).inDays;
      if (diff >= 0 && diff < 7) {
        dailyCounts[diff]++;
      }
    }

    return StatsData(
      totalCount: totalCount,
      latinToCyrillicCount: latinCount,
      cyrillicToLatinCount: cyrillicCount,
      favoritesCount: favoritesCount,
      totalChars: totalChars,
      longestConversion: longestConversion,
      dailyCounts: dailyCounts,
    );
  }

  static StatsData sync(List<ConversionRecord> records) {
    if (records.isEmpty) {
      return const StatsData(
        totalCount: 0,
        latinToCyrillicCount: 0,
        cyrillicToLatinCount: 0,
        favoritesCount: 0,
        totalChars: 0,
        longestConversion: 0,
        dailyCounts: [0, 0, 0, 0, 0, 0, 0],
      );
    }
    final totalCount = records.length;
    final latinCount = records.where((r) => r.isLatinToCyrillic).length;
    final cyrillicCount = totalCount - latinCount;
    final favoritesCount = records.where((r) => r.isFavorite).length;
    final totalChars =
        records.fold<int>(0, (sum, r) => sum + r.inputText.length);
    final longestConversion = records.fold<int>(
        0, (max, r) => r.inputText.length > max ? r.inputText.length : max);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dailyCounts = List<int>.filled(7, 0);
    for (final record in records) {
      final recordDate = DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(record.id) ?? now.millisecondsSinceEpoch);
      final recordDay =
          DateTime(recordDate.year, recordDate.month, recordDate.day);
      final diff = today.difference(recordDay).inDays;
      if (diff >= 0 && diff < 7) {
        dailyCounts[diff]++;
      }
    }

    return StatsData(
      totalCount: totalCount,
      latinToCyrillicCount: latinCount,
      cyrillicToLatinCount: cyrillicCount,
      favoritesCount: favoritesCount,
      totalChars: totalChars,
      longestConversion: longestConversion,
      dailyCounts: dailyCounts,
    );
  }
}
