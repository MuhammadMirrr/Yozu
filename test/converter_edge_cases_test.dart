import 'package:flutter_test/flutter_test.dart';
import 'package:uz_converter/utils/uzbek_converter.dart';

void main() {
  group('All-caps digraphlar (Lotin → Kirill)', () {
    test('SHAHAR → ШАҲАР', () {
      expect(UzbekConverter.latinToCyrillic('SHAHAR'), 'ШАҲАР');
    });
    test('CHORSHANBA → ЧОРШАНБА', () {
      expect(UzbekConverter.latinToCyrillic('CHORSHANBA'), 'ЧОРШАНБА');
    });
    test('NG all-caps: TONG → ТОНГ', () {
      expect(UzbekConverter.latinToCyrillic('TONG'), 'ТОНГ');
    });
    test('YO all-caps: YOMON → ЁМОН', () {
      expect(UzbekConverter.latinToCyrillic('YOMON'), 'ЁМОН');
    });
    test('YU all-caps: YURAK → ЮРАК', () {
      expect(UzbekConverter.latinToCyrillic('YURAK'), 'ЮРАК');
    });
    test('YA all-caps: YAXSHI → ЯХШИ', () {
      expect(UzbekConverter.latinToCyrillic('YAXSHI'), 'ЯХШИ');
    });
    test('YE all-caps word-start: YER → ЕР', () {
      expect(UzbekConverter.latinToCyrillic('YER'), 'ЕР');
    });
    test('TS all-caps: TSEX → ЦЕХ', () {
      expect(UzbekConverter.latinToCyrillic('TSEX'), 'ЦЕХ');
    });
    test("O'ZBEKISTON → ЎЗБЕКИСТОН", () {
      expect(UzbekConverter.latinToCyrillic("O'ZBEKISTON"), 'ЎЗБЕКИСТОН');
    });
    test("G'ALABA → ҒАЛАБА", () {
      expect(UzbekConverter.latinToCyrillic("G'ALABA"), 'ҒАЛАБА');
    });
  });

  group('Aralash case digraphlar', () {
    test('Sh (S-upper, h-lower) → Ш', () {
      expect(UzbekConverter.latinToCyrillic('Shahar'), 'Шаҳар');
    });
    test('sH (s-lower, H-upper) → Ш (bug fix: aralash case)', () {
      // `sH` ni niyatga ko'ra digraph deb olamiz — natija Upper
      expect(UzbekConverter.latinToCyrillic('sHahar'), 'Шаҳар');
    });
    test("O'ZBek → ЎЗБек (Z va B upper, e lower)", () {
      expect(UzbekConverter.latinToCyrillic("O'ZBek"), 'ЎЗБек');
    });
    test("G'ali → Ғали", () {
      expect(UzbekConverter.latinToCyrillic("G'ali"), 'Ғали');
    });
    test('Ngo (N-upper, g-lower) → Нго', () {
      expect(UzbekConverter.latinToCyrillic('Ngo'), 'Нго');
    });
    test('NG all-caps inside: SINGLE → СИНГЛЕ', () {
      expect(UzbekConverter.latinToCyrillic('SINGLE'), 'СИНГЛЕ');
    });
  });

  group('Apostrof barcha Unicode variantlari', () {
    const expected = 'ўзбек';
    test("ASCII apostrof (')", () {
      expect(UzbekConverter.latinToCyrillic("o'zbek"), expected);
    });
    test('Left single quote (\u2018)', () {
      expect(UzbekConverter.latinToCyrillic('o\u2018zbek'), expected);
    });
    test('Right single quote (\u2019)', () {
      expect(UzbekConverter.latinToCyrillic('o\u2019zbek'), expected);
    });
    test('Modifier letter turned comma (\u02BB)', () {
      expect(UzbekConverter.latinToCyrillic('o\u02BBzbek'), expected);
    });
    test('Modifier letter apostrophe (\u02BC)', () {
      expect(UzbekConverter.latinToCyrillic('o\u02BCzbek'), expected);
    });
    test('Backtick (\u0060)', () {
      expect(UzbekConverter.latinToCyrillic('o\u0060zbek'), expected);
    });
    test('Acute accent (\u00B4)', () {
      expect(UzbekConverter.latinToCyrillic('o\u00B4zbek'), expected);
    });
  });

  group('Chegara holatlari', () {
    test('Bitta harf — a → а', () {
      expect(UzbekConverter.latinToCyrillic('a'), 'а');
    });
    test('Bitta harf — E → Э (so\'z boshi)', () {
      expect(UzbekConverter.latinToCyrillic('E'), 'Э');
    });
    test('Faqat probellar', () {
      expect(UzbekConverter.latinToCyrillic('   '), '   ');
    });
    test('Raqamlar va undoshlar aralash', () {
      expect(UzbekConverter.latinToCyrillic('Men 3ta olma yedim.'),
          'Мен 3та олма едим.');
    });
    test('Uzun matn (1000 belgi)', () {
      final input = 'salom ' * 200;
      final output = UzbekConverter.latinToCyrillic(input);
      expect(output.length, input.length);
      expect(output.startsWith('салом'), true);
    });
    test('Emoji matn bilan', () {
      expect(UzbekConverter.latinToCyrillic('salom 👋 dunyo'),
          'салом 👋 дунё');
    });
    test('Tire va qavs', () {
      expect(UzbekConverter.latinToCyrillic('(Toshkent-2026)'),
          '(Тошкент-2026)');
    });
  });

  group('All-caps digraphlar (Kirill → Lotin)', () {
    test('ШАҲАР → SHAHAR', () {
      expect(UzbekConverter.cyrillicToLatin('ШАҲАР'), 'SHAHAR');
    });
    test('ЧОРШАНБА → CHORSHANBA', () {
      expect(UzbekConverter.cyrillicToLatin('ЧОРШАНБА'), 'CHORSHANBA');
    });
    test('ЁМОН → YOMON', () {
      expect(UzbekConverter.cyrillicToLatin('ЁМОН'), 'YOMON');
    });
    test('ЮРАК → YURAK', () {
      expect(UzbekConverter.cyrillicToLatin('ЮРАК'), 'YURAK');
    });
    test('ЯХШИ → YAXSHI', () {
      expect(UzbekConverter.cyrillicToLatin('ЯХШИ'), 'YAXSHI');
    });
    test('ЦЕХ → TSEX', () {
      expect(UzbekConverter.cyrillicToLatin('ЦЕХ'), 'TSEX');
    });
    test("ҒАЛАБА → G'ALABA", () {
      expect(UzbekConverter.cyrillicToLatin('ҒАЛАБА'), "G'ALABA");
    });
  });

  group('Qo\'shimcha roundtriplar (konfliktli so\'zlar)', () {
    final testWords = [
      'YAXSHI',
      "O'QUVCHI",
      'SHAHAR',
      'CHORSHANBA',
      'TSEX',
      'YER',
      'ELLIK',
      'yomon',
      'yetti',
      'ekan',
      'element',
    ];

    for (final word in testWords) {
      test('$word → kirill → lotin = $word', () {
        final cyrillic = UzbekConverter.latinToCyrillic(word);
        final back = UzbekConverter.cyrillicToLatin(cyrillic);
        expect(back, word);
      });
    }
  });
}
