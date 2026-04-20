# Contributing to Yozu

Yozu ochiq kodli loyiha — hissa qoʻshishdan mamnun boʻlamiz! Ushbu hujjat rivojlantirish tartibini tushuntiradi.

## Muloqot qoidalari

Ishtirokchilar [Code of Conduct](CODE_OF_CONDUCT.md) ga rioya qilishlari kutiladi.

## Muhitni sozlash

1. **Talablar**
   - Flutter SDK (pubspec.yaml dagi `sdk: ^3.10.7` ga mos)
   - Android Studio yoki VS Code + Flutter/Dart kengaytmalari
   - Android SDK (Android uchun), Xcode (iOS uchun)

2. **Oʻrnatish**
   ```bash
   git clone https://github.com/MuhammadMirrr/Yozu.git
   cd Yozu
   flutter pub get
   flutter run
   ```

3. **Keystore (faqat maintainer release build uchun)**
   `android/key.properties.example` ni `android/key.properties` ga nusxalang va oʻz qiymatlaringiz bilan toʻldiring. Fayl `.gitignore` da — hech qachon commit qilmang.

## Workflow

1. Issue yarating yoki mavjudini oling.
2. Fork qiling va branch oching: `feature/<qisqa-tavsif>` yoki `fix/<qisqa-tavsif>`.
3. Oʻzgartirishlar qiling va testlarni ishga tushiring:
   ```bash
   flutter analyze lib/
   flutter test
   ```
4. Commit xabarlaringiz tushunarli boʻlsin (ingliz yoki oʻzbek tilida).
5. PR ochib, bogʻliq issue'ni belgilang.

## Kod uslubi

- [analysis_options.yaml](analysis_options.yaml) va `flutter_lints` qoidalariga rioya qiling.
- State management uchun `setState` va `ValueNotifier` dan foydalaniladi — tashqi paket qoʻshmang.
- UI matni oʻzbek tilida hardcoded (hozircha i18n yoʻq).
- Persistentsiya faqat `shared_preferences` orqali (SQLite/Hive ishlatilmaydi).
- Arxitektura detallari — [CLAUDE.md](CLAUDE.md).

## Testlar

Mavjud testlar `test/` papkasida. Yangi funksional uchun test yozing:

```bash
flutter test                        # hammasi
flutter test test/widget_test.dart  # bitta fayl
```

## Xatolik va xavfsizlik

- Xatoliklar uchun [GitHub Issues](https://github.com/MuhammadMirrr/Yozu/issues) da ochiq yozing.
- Xavfsizlik zaifliklari uchun — [SECURITY.md](SECURITY.md) ga qarang (maxfiy bildirish).

## Litsenziya

Hissa qoʻshish orqali siz oʻz oʻzgartirishlaringizni [MIT License](LICENSE) ostida chiqarishga rozilik berasiz.
