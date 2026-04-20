<div align="center">

<img src="assets/icon/app_icon.png" alt="Yozu" width="120" />

# Yozu

**O'zbek Lotin ↔ Kirill real-time matn konverter**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](#)

[English](#english) • [O'zbekcha](#ozbekcha) • [Русский](#русский) • [العربية](#عربي)

</div>

---

## English

**Yozu** is an offline, real-time Uzbek Latin ↔ Cyrillic text converter built with Flutter. Type or paste in one script and instantly see the result in the other.

### Features

- ⚡ Real-time conversion while typing
- 🔁 Bidirectional: Latin → Cyrillic and Cyrillic → Latin
- 📋 Clipboard auto-detect (optional)
- 🕘 History with favorites (up to 100 records)
- 🌓 Light / Dark / System themes (Material 3)
- 📤 Share and copy with one tap
- 🔤 Character & word counter
- 📴 Fully offline — no internet required

### Conversion rules

Greedy longest-match algorithm: 2-letter digraphs first (`sh`, `ch`, `ng`, `o'`, `g'`, `yo`, `yu`, `ya`, `ye`), then single letters. Context-aware: `ye`/`e` at word start vs. mid-word; `е` after consonants in Cyrillic → `e` in Latin, otherwise → `ye`. All Unicode apostrophe variants are normalized.

### Getting started

```bash
flutter pub get
flutter run
```

Build a release AAB for Google Play:

```bash
flutter build appbundle
```

See [CLAUDE.md](CLAUDE.md) for architecture and [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

---

## Oʻzbekcha

**Yozu** — Flutter asosidagi offline, real-time Oʻzbek Lotin ↔ Kirill matn konverteri. Bir yozuvda yozing yoki joylashtiring — natijani ikkinchi yozuvda darhol koʻring.

### Imkoniyatlar

- ⚡ Yozish paytida real-time konvertatsiya
- 🔁 Ikki tomonlama: Lotin → Kirill va Kirill → Lotin
- 📋 Buferni avtomatik aniqlash (ixtiyoriy)
- 🕘 Tarix va sevimlilar (100 tagacha yozuv)
- 🌓 Yorugʻ / Qorongʻu / Tizim mavzulari (Material 3)
- 📤 Bir tegish bilan ulashish va nusxalash
- 🔤 Belgi va soʻzlar sanagichi
- 📴 Toʻliq offline — internet talab qilmaydi

### Konvertatsiya qoidalari

Greedy longest-match algoritmi: avval 2-belgilik digraphlar (`sh`, `ch`, `ng`, `oʻ`, `gʻ`, `yo`, `yu`, `ya`, `ye`), keyin yakka harflar. Kontekstga bogʻliq: `ye`/`e` soʻz boshida va oʻrtasida farqli; Kirilldagi `е` undoshdan keyin → `e`, aks holda → `ye`. Apostrofning barcha Unicode variantlari normalizatsiya qilinadi.

### Boshlash

```bash
flutter pub get
flutter run
```

Google Play uchun release AAB:

```bash
flutter build appbundle
```

Arxitektura — [CLAUDE.md](CLAUDE.md), hissa qoʻshish — [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Русский

**Yozu** — офлайн-конвертер узбекского текста между латиницей и кириллицей в реальном времени, написанный на Flutter. Вводите или вставляйте текст в одной системе письма — результат в другой появится мгновенно.

### Возможности

- ⚡ Конвертация в реальном времени во время ввода
- 🔁 Двунаправленно: латиница → кириллица и кириллица → латиница
- 📋 Автоматическое определение буфера обмена (опционально)
- 🕘 История и избранное (до 100 записей)
- 🌓 Светлая / Тёмная / Системная темы (Material 3)
- 📤 Обмен и копирование в одно касание
- 🔤 Счётчик символов и слов
- 📴 Полностью офлайн — интернет не требуется

### Правила конвертации

Жадный алгоритм с приоритетом длинных совпадений: сначала двубуквенные диграфы (`sh`, `ch`, `ng`, `oʻ`, `gʻ`, `yo`, `yu`, `ya`, `ye`), затем отдельные буквы. Контекстно-зависимые правила: `ye`/`e` в начале и середине слова ведут себя по-разному; кириллическая `е` после согласной → `e` в латинице, иначе → `ye`. Все варианты апострофа Unicode нормализуются.

### Начало работы

```bash
flutter pub get
flutter run
```

Release AAB для Google Play:

```bash
flutter build appbundle
```

Архитектура — [CLAUDE.md](CLAUDE.md), вклад — [CONTRIBUTING.md](CONTRIBUTING.md).

---

## عربي

<div dir="rtl">

**Yozu** هو محوّل نصوص أوزبكي فوري بين الحروف اللاتينية والسيريلية، مبني بواسطة Flutter ويعمل دون اتصال بالإنترنت. اكتب أو الصق نصًا بأحد الخطّين لترى النتيجة بالآخر فورًا.

### المميزات

- ⚡ تحويل فوري أثناء الكتابة
- 🔁 اتجاهين: لاتيني ← → سيريلي
- 📋 اكتشاف تلقائي للحافظة (اختياري)
- 🕘 السجل والمفضلة (حتى 100 سجل)
- 🌓 ثيمات فاتح / داكن / حسب النظام (Material 3)
- 📤 مشاركة ونسخ بضغطة واحدة
- 🔤 عدّاد الأحرف والكلمات
- 📴 يعمل بالكامل دون اتصال — لا يحتاج إنترنت

### قواعد التحويل

خوارزمية جشعة بأطول تطابق: أولاً ثنائيات الحروف (`sh`, `ch`, `ng`, `oʻ`, `gʻ`, `yo`, `yu`, `ya`, `ye`) ثم الحروف المفردة. قواعد حساسة للسياق: `ye`/`e` في بداية الكلمة تختلف عن منتصفها؛ الحرف السيريلي `е` بعد صامت → `e` باللاتيني وإلا → `ye`. جميع أشكال الفاصلة العليا في Unicode مُوحَّدة.

### البدء

```bash
flutter pub get
flutter run
```

بناء AAB للإصدار لـ Google Play:

```bash
flutter build appbundle
```

البنية المعمارية — [CLAUDE.md](CLAUDE.md)، المساهمة — [CONTRIBUTING.md](CONTRIBUTING.md).

</div>

---

## License

MIT © [MuhammadMirrr](https://github.com/MuhammadMirrr) — see [LICENSE](LICENSE).
