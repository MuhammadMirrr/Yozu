import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uz_converter/services/history_service.dart';

void main() {
  late HistoryService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = HistoryService.newForTesting();
  });

  group('HistoryService CRUD', () {
    test('bo\'sh holatda getRecords() bo\'sh ro\'yxat qaytaradi', () async {
      final records = await service.getRecords();
      expect(records, isEmpty);
    });

    test('addRecord() qo\'shilgan yozuvni saqlaydi', () async {
      await service.addRecord(
        inputText: 'salom',
        outputText: 'салом',
        isLatinToCyrillic: true,
      );
      final records = await service.getRecords();
      expect(records.length, 1);
      expect(records.first.inputText, 'salom');
      expect(records.first.outputText, 'салом');
      expect(records.first.isLatinToCyrillic, true);
    });

    test('3 belgidan kichik input saqlanmaydi', () async {
      await service.addRecord(
        inputText: 'ab',
        outputText: 'аб',
        isLatinToCyrillic: true,
      );
      final records = await service.getRecords();
      expect(records, isEmpty);
    });

    test('deleteRecord() yozuvni o\'chiradi', () async {
      await service.addRecord(
        inputText: 'salom',
        outputText: 'салом',
        isLatinToCyrillic: true,
      );
      final records = await service.getRecords();
      await service.deleteRecord(records.first.id);
      final after = await service.getRecords();
      expect(after, isEmpty);
    });

    test('clearAll() hammasini tozalaydi', () async {
      for (var i = 0; i < 3; i++) {
        await service.addRecord(
          inputText: 'test$i',
          outputText: 'тест$i',
          isLatinToCyrillic: true,
        );
      }
      await service.clearAll();
      final records = await service.getRecords();
      expect(records, isEmpty);
    });
  });

  group('HistoryService favorites', () {
    test('toggleFavorite() favorite holatini almashtiradi', () async {
      await service.addRecord(
        inputText: 'salom',
        outputText: 'салом',
        isLatinToCyrillic: true,
      );
      final record = (await service.getRecords()).first;
      expect(record.isFavorite, false);

      await service.toggleFavorite(record.id);
      final updated = (await service.getRecords()).first;
      expect(updated.isFavorite, true);

      await service.toggleFavorite(record.id);
      final untoggled = (await service.getRecords()).first;
      expect(untoggled.isFavorite, false);
    });

    test('getFavorites() faqat favoritelarni qaytaradi', () async {
      for (var i = 0; i < 3; i++) {
        await service.addRecord(
          inputText: 'test$i' * 2,
          outputText: 'тест$i' * 2,
          isLatinToCyrillic: true,
        );
      }
      final records = await service.getRecords();
      await service.toggleFavorite(records[0].id);
      await service.toggleFavorite(records[2].id);

      final favorites = await service.getFavorites();
      expect(favorites.length, 2);
      expect(favorites.every((r) => r.isFavorite), true);
    });
  });

  group('HistoryService limits', () {
    test('100 ta yozuvdan ortig\'i saqlanmaydi', () async {
      for (var i = 0; i < 110; i++) {
        await service.addRecord(
          inputText: 'matn-$i',
          outputText: 'матн-$i',
          isLatinToCyrillic: true,
        );
      }
      final records = await service.getRecords();
      expect(records.length, 100);
      // Eng yangilari birinchi — matn-109 eng tepada
      expect(records.first.inputText, 'matn-109');
    });
  });

  group('HistoryService insert', () {
    test('insertRecord() berilgan indexga qo\'shadi', () async {
      await service.addRecord(
        inputText: 'birinchi',
        outputText: 'биринчи',
        isLatinToCyrillic: true,
      );
      await service.addRecord(
        inputText: 'ikkinchi',
        outputText: 'иккинчи',
        isLatinToCyrillic: true,
      );
      final existing = (await service.getRecords()).first;
      await service.deleteRecord(existing.id);
      await service.insertRecord(existing, 0);
      final records = await service.getRecords();
      expect(records.first.id, existing.id);
    });
  });
}
