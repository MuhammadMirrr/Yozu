import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uz_converter/screens/settings_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('SettingsScreen AppBar\'da "Sozlamalar" matni bor', (tester) async {
    await tester.pumpWidget(wrap(const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Sozlamalar'), findsOneWidget);
  });

  testWidgets('Ko\'rinish bo\'limida 3 ta tema tugmasi bor', (tester) async {
    await tester.pumpWidget(wrap(const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Yorug\''), findsOneWidget);
    expect(find.text('Qorong\'u'), findsOneWidget);
    expect(find.text('Tizim'), findsOneWidget);
  });

  testWidgets('Clipboard auto-detect switch ko\'rinadi', (tester) async {
    await tester.pumpWidget(wrap(const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Clipboard avtomatik aniqlash'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
  });

  testWidgets('Clipboard switch bosilganda qiymat o\'zgaradi', (tester) async {
    await tester.pumpWidget(wrap(const SettingsScreen()));
    await tester.pumpAndSettle();

    final switchFinder = find.byType(SwitchListTile);
    final initialSwitch = tester.widget<SwitchListTile>(switchFinder);
    expect(initialSwitch.value, false); // default

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    final updatedSwitch = tester.widget<SwitchListTile>(switchFinder);
    expect(updatedSwitch.value, true);
  });

  testWidgets('Ilova haqida bo\'limida Versiya, Ishlab chiqaruvchi, Baho bering bor',
      (tester) async {
    await tester.pumpWidget(wrap(const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Versiya'), findsOneWidget);
    expect(find.text('Ishlab chiqaruvchi'), findsOneWidget);

    // "Baho bering" ListView pastida — skroll qilish
    await tester.scrollUntilVisible(
      find.text('Baho bering'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Baho bering'), findsOneWidget);
  });

  testWidgets('Developer card\'da Muhammad Mirqobilov va Telegram bor',
      (tester) async {
    await tester.pumpWidget(wrap(const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Muhammad Mirqobilov'), findsOneWidget);
    expect(find.text('@mirqobilov_mm'), findsOneWidget);
    expect(find.text('Ishlab chiqaruvchi'), findsOneWidget);
  });

  testWidgets('FeatureFlags.adsEnabled=false bo\'lganda Qo\'llab-quvvatlash yo\'q',
      (tester) async {
    await tester.pumpWidget(wrap(const SettingsScreen()));
    await tester.pumpAndSettle();

    // FeatureFlags.adsEnabled = false sabab "Qo'llab-quvvatlash" bo'limi ko'rinmaydi
    expect(find.text('Qo\'llab-quvvatlash'), findsNothing);
    expect(find.text('Dasturchini qo\'llab-quvvatlash'), findsNothing);
  });
}
