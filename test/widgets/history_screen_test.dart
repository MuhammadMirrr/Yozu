import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uz_converter/screens/history_screen.dart';
import 'package:uz_converter/services/history_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    HistoryService.instance.invalidateCache();
  });

  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('Bo\'sh tarix holatida "Tarix bo\'sh" matni ko\'rinadi',
      (tester) async {
    await tester.pumpWidget(wrap(const HistoryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tarix bo\'sh'), findsOneWidget);
  });

  testWidgets('AppBar\'da "Tarix" sarlavhasi va TabBar 2 ta tab bor',
      (tester) async {
    await tester.pumpWidget(wrap(const HistoryScreen()));
    await tester.pumpAndSettle();

    // AppBar title + Tab label 'Tarix' — 2 ta topiladi
    expect(find.text('Tarix'), findsNWidgets(2));
    expect(find.text('Sevimlilar'), findsOneWidget);
  });

  testWidgets('Sevimlilar tabida bo\'sh holat "Sevimlilar bo\'sh"',
      (tester) async {
    await tester.pumpWidget(wrap(const HistoryScreen()));
    await tester.pumpAndSettle();

    // Sevimlilar tab'ini bosish
    await tester.tap(find.text('Sevimlilar'));
    await tester.pumpAndSettle();

    expect(find.text('Sevimlilar bo\'sh'), findsOneWidget);
  });

  testWidgets('Qo\'shilgan record tarixda ko\'rinadi', (tester) async {
    final service = HistoryService.instance;
    await service.addRecord(
      inputText: 'salom',
      outputText: 'салом',
      isLatinToCyrillic: true,
    );

    await tester.pumpWidget(wrap(const HistoryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('salom'), findsOneWidget);
    expect(find.text('салом'), findsOneWidget);
  });

  testWidgets('Favorite toggle tugmasini bosish', (tester) async {
    final service = HistoryService.instance;
    await service.addRecord(
      inputText: 'salom dunyo',
      outputText: 'салом дунё',
      isLatinToCyrillic: true,
    );

    await tester.pumpWidget(wrap(const HistoryScreen()));
    await tester.pumpAndSettle();

    // Favorite icon (border) mavjud
    expect(find.byIcon(Icons.star_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pumpAndSettle();

    // To'ldirilgan star icon paydo bo'ladi
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
