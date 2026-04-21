class UzbekConverter {
  /// Custom dictionary bilan Lotin → Kirill konvertatsiya.
  ///
  /// Avval [userDict] dagi eng uzun matchni qidiradi (greedy), keyin standart
  /// algoritm qolgan matnni konvert qiladi.
  static String latinToCyrillicWithDict(
      String input, Map<String, String> userDict) {
    if (userDict.isEmpty) return latinToCyrillic(input);
    final keys = userDict.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final buffer = StringBuffer();
    int i = 0;
    while (i < input.length) {
      String? matched;
      for (final key in keys) {
        if (key.isEmpty) continue;
        if (i + key.length <= input.length &&
            input.substring(i, i + key.length).toLowerCase() ==
                key.toLowerCase()) {
          matched = key;
          break;
        }
      }
      if (matched != null) {
        buffer.write(userDict[matched]);
        i += matched.length;
      } else {
        // Keyingi so'zgacha yoki bitta harfgacha standart konverter
        buffer.write(latinToCyrillic(input[i]));
        i++;
      }
    }
    return buffer.toString();
  }

  static String cyrillicToLatinWithDict(
      String input, Map<String, String> userDict) {
    if (userDict.isEmpty) return cyrillicToLatin(input);
    final keys = userDict.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final buffer = StringBuffer();
    int i = 0;
    while (i < input.length) {
      String? matched;
      for (final key in keys) {
        if (key.isEmpty) continue;
        if (i + key.length <= input.length &&
            input.substring(i, i + key.length).toLowerCase() ==
                key.toLowerCase()) {
          matched = key;
          break;
        }
      }
      if (matched != null) {
        buffer.write(userDict[matched]);
        i += matched.length;
      } else {
        buffer.write(cyrillicToLatin(input[i]));
        i++;
      }
    }
    return buffer.toString();
  }

  // Apostrof variantlarini normalizatsiya qilish
  static const _apostrophes = ["'", "\u2018", "\u2019", "\u02BB", "\u02BC", "\u0060", "\u00B4"];

  static bool _isApostrophe(String ch) => _apostrophes.contains(ch);

  // Katta harf tekshirish yordamchisi
  static bool _isUpperCase(String ch) => ch == ch.toUpperCase() && ch != ch.toLowerCase();

  // So'z boshidami tekshirish
  static bool _isWordStart(String input, int index) {
    if (index == 0) return true;
    final prev = input[index - 1];
    return !RegExp(r"[a-zA-Z\u0400-\u04FF]").hasMatch(prev);
  }

  // Kirill undosh harflar
  static const _cyrillicConsonants = {
    'б', 'в', 'г', 'д', 'ж', 'з', 'й', 'к', 'л', 'м', 'н',
    'п', 'р', 'с', 'т', 'ф', 'х', 'ц', 'ч', 'ш', 'ғ', 'қ', 'ҳ',
  };

  static bool _isAfterCyrillicConsonant(String input, int index) {
    if (index == 0) return false;
    return _cyrillicConsonants.contains(input[index - 1].toLowerCase());
  }

  // All-caps kontekst: qo'shni harf ham upper bo'lsa true
  static bool _isAllCapsContext(String input, int index) {
    final prev = index > 0 ? input[index - 1] : '';
    final next = index + 1 < input.length ? input[index + 1] : '';
    bool isLetterUpper(String ch) {
      if (ch.isEmpty) return false;
      return ch == ch.toUpperCase() && ch != ch.toLowerCase();
    }
    return isLetterUpper(prev) || isLetterUpper(next);
  }

  // Case ni saqlash yordamchisi
  static String _applyCase(String result, bool firstUpper, [bool secondUpper = false]) {
    if (result.isEmpty) return result;
    if (firstUpper) {
      if (result.length == 1) {
        return result.toUpperCase();
      }
      if (secondUpper) {
        return result.toUpperCase();
      }
      return result[0].toUpperCase() + result.substring(1);
    }
    // `sH` kabi aralash case: ikkinchi harf upper bo'lsa, digraph natijasini upper qilamiz
    if (result.length == 1 && secondUpper) {
      return result.toUpperCase();
    }
    return result;
  }

  // ==================== LOTIN → KIRILL ====================
  static String latinToCyrillic(String input) {
    final buffer = StringBuffer();
    int i = 0;

    while (i < input.length) {
      // 2-belgi lookahead
      if (i + 1 < input.length) {
        final first = input[i];
        final second = input[i + 1];
        final pair = first.toLowerCase() + ((_isApostrophe(second)) ? "'" : second.toLowerCase());
        final firstUpper = _isUpperCase(first);
        final secondUpper = _isUpperCase(second);

        // sh → ш
        if (pair == 'sh') {
          buffer.write(_applyCase('ш', firstUpper, secondUpper));
          i += 2;
          continue;
        }
        // ch → ч
        if (pair == 'ch') {
          buffer.write(_applyCase('ч', firstUpper, secondUpper));
          i += 2;
          continue;
        }
        // ng → нг
        if (pair == 'ng') {
          buffer.write(_applyCase('нг', firstUpper, secondUpper));
          i += 2;
          continue;
        }
        // o' → ў
        if (pair == "o'") {
          buffer.write(_applyCase('ў', firstUpper, secondUpper));
          i += 2;
          continue;
        }
        // g' → ғ
        if (pair == "g'") {
          buffer.write(_applyCase('ғ', firstUpper, secondUpper));
          i += 2;
          continue;
        }
        // yo → ё
        if (pair == 'yo') {
          buffer.write(_applyCase('ё', firstUpper, secondUpper));
          i += 2;
          continue;
        }
        // yu → ю
        if (pair == 'yu') {
          buffer.write(_applyCase('ю', firstUpper, secondUpper));
          i += 2;
          continue;
        }
        // ya → я
        if (pair == 'ya') {
          buffer.write(_applyCase('я', firstUpper, secondUpper));
          i += 2;
          continue;
        }
        // ye → е (so'z boshida) yoki йе (o'rtada)
        if (pair == 'ye') {
          if (_isWordStart(input, i)) {
            buffer.write(_applyCase('е', firstUpper, secondUpper));
          } else {
            buffer.write(_applyCase('йе', firstUpper, secondUpper));
          }
          i += 2;
          continue;
        }
        // ts → ц
        if (pair == 'ts') {
          buffer.write(_applyCase('ц', firstUpper, secondUpper));
          i += 2;
          continue;
        }
      }

      // Yakka harf
      final ch = input[i];
      final lower = ch.toLowerCase();
      final isUpper = _isUpperCase(ch);

      // Context-dependent 'e'
      if (lower == 'e') {
        if (_isWordStart(input, i)) {
          buffer.write(_applyCase('э', isUpper));
        } else {
          buffer.write(_applyCase('е', isUpper));
        }
        i++;
        continue;
      }

      final cyrillicChar = _singleLatinToCyrillic[lower];
      if (cyrillicChar != null) {
        buffer.write(_applyCase(cyrillicChar, isUpper));
      } else if (_isApostrophe(ch)) {
        buffer.write('ъ');
      } else {
        buffer.write(ch);
      }
      i++;
    }

    return buffer.toString();
  }

  // ==================== KIRILL → LOTIN ====================
  static String cyrillicToLatin(String input) {
    final buffer = StringBuffer();
    int i = 0;

    while (i < input.length) {
      // 2-belgi lookahead: нг → ng
      if (i + 1 < input.length) {
        final first = input[i];
        final second = input[i + 1];
        final pair = first.toLowerCase() + second.toLowerCase();
        final firstUpper = _isUpperCase(first);
        final secondUpper = _isUpperCase(second);

        if (pair == 'нг') {
          buffer.write(_applyCase('ng', firstUpper, secondUpper));
          i += 2;
          continue;
        }
      }

      // Yakka harf
      final ch = input[i];
      final lower = ch.toLowerCase();
      final isUpper = _isUpperCase(ch);
      // Kirill yakka → Lotin ko'p harfli (sh/ch/yo/...) uchun all-caps kontekst
      final allCaps = isUpper && _isAllCapsContext(input, i);

      // Context-dependent 'е'
      if (lower == 'е') {
        if (_isAfterCyrillicConsonant(input, i)) {
          buffer.write(_applyCase('e', isUpper));
        } else {
          buffer.write(allCaps ? 'YE' : _applyCase('ye', isUpper));
        }
        i++;
        continue;
      }

      final latinChar = _singleCyrillicToLatin[lower];
      if (latinChar != null) {
        if (allCaps && latinChar.length > 1) {
          buffer.write(latinChar.toUpperCase());
        } else {
          buffer.write(_applyCase(latinChar, isUpper));
        }
      } else {
        buffer.write(ch);
      }
      i++;
    }

    return buffer.toString();
  }

  // Yakka harf maplari
  static const _singleLatinToCyrillic = {
    'a': 'а',
    'b': 'б',
    'd': 'д',
    'f': 'ф',
    'g': 'г',
    'h': 'ҳ',
    'i': 'и',
    'j': 'ж',
    'k': 'к',
    'l': 'л',
    'm': 'м',
    'n': 'н',
    'o': 'о',
    'p': 'п',
    'q': 'қ',
    'r': 'р',
    's': 'с',
    't': 'т',
    'u': 'у',
    'v': 'в',
    'x': 'х',
    'y': 'й',
    'z': 'з',
  };

  static const _singleCyrillicToLatin = {
    'а': 'a',
    'б': 'b',
    'в': 'v',
    'г': 'g',
    'д': 'd',
    'ё': 'yo',
    'ж': 'j',
    'з': 'z',
    'и': 'i',
    'й': 'y',
    'к': 'k',
    'л': 'l',
    'м': 'm',
    'н': 'n',
    'о': 'o',
    'п': 'p',
    'р': 'r',
    'с': 's',
    'т': 't',
    'у': 'u',
    'ф': 'f',
    'х': 'x',
    'ц': 'ts',
    'ч': 'ch',
    'ш': 'sh',
    'ъ': "'",
    'э': 'e',
    'ю': 'yu',
    'я': 'ya',
    'ў': "o'",
    'ғ': "g'",
    'қ': 'q',
    'ҳ': 'h',
  };
}
