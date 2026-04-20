import 'package:flutter_test/flutter_test.dart';
import 'package:uz_converter/utils/uzbek_converter.dart';

void main() {
  group('Lotin → Kirill', () {
    // Oddiy so'zlar
    test('salom → салом', () {
      expect(UzbekConverter.latinToCyrillic('salom'), 'салом');
    });

    test('dunyo → дунё', () {
      expect(UzbekConverter.latinToCyrillic('dunyo'), 'дунё');
    });

    // E harfi — eng muhim testlar
    test('men → мен (е, э EMAS)', () {
      expect(UzbekConverter.latinToCyrillic('men'), 'мен');
    });

    test('keldi → келди', () {
      expect(UzbekConverter.latinToCyrillic('keldi'), 'келди');
    });

    test('emas → эмас (so\'z boshidagi e → э)', () {
      expect(UzbekConverter.latinToCyrillic('emas'), 'эмас');
    });

    test('ekan → экан', () {
      expect(UzbekConverter.latinToCyrillic('ekan'), 'экан');
    });

    test('element → элемент', () {
      expect(UzbekConverter.latinToCyrillic('element'), 'элемент');
    });

    // Digraflar
    test('o\'zbek → ўзбек', () {
      expect(UzbekConverter.latinToCyrillic("o'zbek"), 'ўзбек');
    });

    test('g\'alaba → ғалаба', () {
      expect(UzbekConverter.latinToCyrillic("g'alaba"), 'ғалаба');
    });

    test('Toshkent → Тошкент', () {
      expect(UzbekConverter.latinToCyrillic('Toshkent'), 'Тошкент');
    });

    test('Shaxriyor → Шахриёр', () {
      expect(UzbekConverter.latinToCyrillic('Shaxriyor'), 'Шахриёр');
    });

    test('choy → чой', () {
      expect(UzbekConverter.latinToCyrillic('choy'), 'чой');
    });

    test('tong → тонг', () {
      expect(UzbekConverter.latinToCyrillic('tong'), 'тонг');
    });

    // Yo, Yu, Ya
    test('yomon → ёмон', () {
      expect(UzbekConverter.latinToCyrillic('yomon'), 'ёмон');
    });

    test('yurak → юрак', () {
      expect(UzbekConverter.latinToCyrillic('yurak'), 'юрак');
    });

    test('yaxshi → яхши', () {
      expect(UzbekConverter.latinToCyrillic('yaxshi'), 'яхши');
    });

    // Ye holatlari
    test('yer → ер', () {
      expect(UzbekConverter.latinToCyrillic('yer'), 'ер');
    });

    test('yetti → етти', () {
      expect(UzbekConverter.latinToCyrillic('yetti'), 'етти');
    });

    // Apostrof variantlari
    test('o\u2019zbek → ўзбек (right quote apostrof)', () {
      expect(UzbekConverter.latinToCyrillic('o\u2019zbek'), 'ўзбек');
    });

    test('o\u02BBzbek → ўзбек (modifier letter)', () {
      expect(UzbekConverter.latinToCyrillic('o\u02BBzbek'), 'ўзбек');
    });

    // Tutuq belgisi (mustaqil apostrof → ъ)
    test('san\'at → санъат', () {
      expect(UzbekConverter.latinToCyrillic("san'at"), 'санъат');
    });

    test('ma\'no → маъно', () {
      expect(UzbekConverter.latinToCyrillic("ma'no"), 'маъно');
    });

    // Katta harflar
    test('O\'ZBEKISTON → ЎЗБЕКИСТОН', () {
      expect(UzbekConverter.latinToCyrillic("O'ZBEKISTON"), 'ЎЗБЕКИСТОН');
    });

    test('SALOM → САЛОМ', () {
      expect(UzbekConverter.latinToCyrillic('SALOM'), 'САЛОМ');
    });

    // Gaplar
    test('To\'liq gap konvertatsiyasi', () {
      expect(
        UzbekConverter.latinToCyrillic("O'zbekiston — buyuk kelajak mamlakati!"),
        'Ўзбекистон — буюк келажак мамлакати!',
      );
    });

    test('Raqamlar va belgilar o\'zgarmaydi', () {
      expect(UzbekConverter.latinToCyrillic('2024-yil, 15-mart'), '2024-йил, 15-март');
    });

    // Bo'sh satr
    test("bo'sh satr", () {
      expect(UzbekConverter.latinToCyrillic(''), '');
    });
  });

  group('Kirill → Lotin', () {
    test('салом → salom', () {
      expect(UzbekConverter.cyrillicToLatin('салом'), 'salom');
    });

    test('мен → men', () {
      expect(UzbekConverter.cyrillicToLatin('мен'), 'men');
    });

    test('ўзбек → o\'zbek', () {
      expect(UzbekConverter.cyrillicToLatin('ўзбек'), "o'zbek");
    });

    test('Тошкент → Toshkent', () {
      expect(UzbekConverter.cyrillicToLatin('Тошкент'), 'Toshkent');
    });

    test('экан → ekan', () {
      expect(UzbekConverter.cyrillicToLatin('экан'), 'ekan');
    });

    test('етти → yetti', () {
      expect(UzbekConverter.cyrillicToLatin('етти'), 'yetti');
    });

    test('келди → keldi', () {
      expect(UzbekConverter.cyrillicToLatin('келди'), 'keldi');
    });

    test('санъат → san\'at', () {
      expect(UzbekConverter.cyrillicToLatin('санъат'), "san'at");
    });

    test('ЎЗБЕКИСТОН → O\'ZBEKISTON', () {
      expect(UzbekConverter.cyrillicToLatin('ЎЗБЕКИСТОН'), "O'ZBEKISTON");
    });

    test("bo'sh satr", () {
      expect(UzbekConverter.cyrillicToLatin(''), '');
    });
  });

  group('Ikki tomonlama (roundtrip)', () {
    final testWords = [
      'salom', 'dunyo', "o'zbek", 'Toshkent', 'choy', 'shaxar',
      "g'alaba", 'yaxshi', 'yurak', 'tong', "san'at", "ma'no",
    ];

    for (final word in testWords) {
      test('$word → kirill → lotin = $word', () {
        final cyrillic = UzbekConverter.latinToCyrillic(word);
        final backToLatin = UzbekConverter.cyrillicToLatin(cyrillic);
        expect(backToLatin, word);
      });
    }
  });
}
