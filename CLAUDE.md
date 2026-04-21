# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Yozu — O'zbek tili uchun Lotin ↔ Kirill real-time matn konverter Flutter ilovasi.
Package: `com.uzbapps.converter`, Dart package name: `uz_converter`.

## Common Commands

```bash
flutter pub get              # Dependencylarni yuklash
flutter test                 # Barcha testlarni ishga tushirish
flutter test test/widget_test.dart  # Bitta test faylni ishga tushirish
flutter analyze lib/         # Statik analiz (faqat lib/)
flutter run                  # Debug rejimda ishga tushirish
flutter build appbundle      # Release AAB yaratish (Google Play uchun)

# Icon va splash regeneratsiya (assets/icon/ o'zgarganda)
dart run flutter_launcher_icons       # Android/iOS launcher iconlari
dart run flutter_native_splash:create # Splash screen (android_12 ham)
dart run tool/generate_icon.dart      # assets/icon/app_icon.png ni dasturiy qayta yaratish
```

## Architecture

Multi-screen ilova, `setState` + global `ValueNotifier` (ThemeProvider) bilan state management. Tashqi state management paketi ishlatilmaydi.

### Konvertatsiya logikasi
- **`lib/utils/uzbek_converter.dart`** — Static utility class, greedy longest-match algoritm. Avval 2-belgilik digraphlar (sh, ch, ng, o', g', yo, yu, ya, ye), keyin yakka harflar. Kontekstga bog'liq qoidalar: `ye` so'z boshida → `е`, o'rtada → `йе`; `e` so'z boshida → `э`, o'rtada → `е`; Kirill→Lotin da `е` undoshdan keyin → `e`, aks holda → `ye`. Apostrofning barcha Unicode variantlari normalizatsiya qilinadi.

### Ekranlar va navigatsiya
- **`lib/app.dart`** — `MaterialApp` konfiguratsiyasi. `ValueListenableBuilder<ThemeMode>` orqali light/dark/system theme. `ColorScheme.fromSeed(seedColor: AppColors.orange)`. Google Fonts Rubik.
- **`lib/screens/converter_screen.dart`** — Asosiy ekran. Input/output TextEditingController, `onChanged` orqali real-time konvertatsiya. Debounced (500ms) tarixga saqlash. Clipboard auto-detect, onboarding dialog, share_plus integratsiyasi. Navigator.push orqali History va Settings ekranlariga o'tish.
- **`lib/screens/history_screen.dart`** — TabBarView: Tarix va Sevimlilar. Elementni tanlash natijani ConverterScreen ga `Navigator.pop(context, record)` orqali qaytaradi. Dismissible orqali o'chirish.
- **`lib/screens/settings_screen.dart`** — Theme tanlash (SegmentedButton), clipboard auto-detect toggle. SharedPreferences orqali persist.

### Data layer
- **`lib/models/conversion_record.dart`** — `ConversionRecord` model. JSON serialization, `id` = millisecondsSinceEpoch.
- **`lib/services/history_service.dart`** — SharedPreferences-based storage, max 100 yozuv. CRUD + favorites + clearAll.
- **`lib/providers/theme_provider.dart`** — Global singleton `themeProvider` (ValueNotifier<ThemeMode>), SharedPreferences da persist.

### Widgets
- **`lib/widgets/`** — `SwapButton` (yo'nalish almashtirish), `BannerAdWidget` (AdMob, faqat Android/iOS — `FeatureFlags.adsEnabled` orqali disabled launch'da).

### Rang palitrassi
- **`lib/constants/app_colors.dart`** — Quari-inspired: orange #FF865E (primary accent), purple #9685FF, lightBlue #A2D2FF, cream #FEF9EF. O'zbek bayrog'i ranglari ham saqlanadi (branding uchun).

## Key Conventions

- UI matni O'zbek tilida hardcoded (i18n framework ishlatilmaydi)
- AdMob hozircha Google rasmiy test ID lari bilan ishlaydi
- Android namespace va applicationId: `com.uzbapps.converter` (build.gradle.kts va MainActivity.kt sinxron bo'lishi shart)
- Material Design 3, `ColorScheme.fromSeed`
- Persistentsiya faqat `shared_preferences` orqali (SQLite/Hive ishlatilmaydi)
- Theme global singleton pattern: `final themeProvider = ThemeProvider()` top-level, DI framework yo'q
- Versiya ma'lumoti `package_info_plus` orqali olinadi; "Ilovani baholash" `in_app_review` orqali (Play/App Store native dialog)
- Splash va launcher iconlar `pubspec.yaml` dagi `flutter_native_splash:` / `flutter_launcher_icons:` bloklari orqali sozlanadi
