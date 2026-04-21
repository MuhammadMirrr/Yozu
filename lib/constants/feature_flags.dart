/// Ilova funksiyalari uchun global feature flaglar.
///
/// Launch'da reklama yo'q — foydalanuvchilarni yig'ib bo'lgach `adsEnabled = true`
/// qilinsa, barcha AdMob integratsiyasi avtomatik qayta yoqiladi.
class FeatureFlags {
  FeatureFlags._();

  /// AdMob reklamalari (banner, app open, rewarded) yoqilgan/o'chirilgan.
  static const bool adsEnabled = false;
}
