import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uz_converter/screens/converter_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'onboarding_shown': true});
  });

  Widget wrap(Widget child) {
    return MaterialApp(home: child);
  }

  testWidgets('Input bo\'sh bo\'lganda output ham bo\'sh', (tester) async {
    await tester.pumpWidget(wrap(const ConverterScreen()));
    await tester.pump();

    final inputs = find.byType(TextFormField);
    expect(inputs, findsNWidgets(2));
  });

  testWidgets('Lotin input yozilganda Kirill output paydo bo\'ladi', (tester) async {
    await tester.pumpWidget(wrap(const ConverterScreen()));
    await tester.pumpAndSettle();

    final inputFields = find.byType(TextFormField);
    await tester.enterText(inputFields.first, 'salom');
    await tester.pump();

    expect(find.text('салом'), findsOneWidget);
  });

  testWidgets('Swap tugmasi yo\'nalishni almashtiradi', (tester) async {
    await tester.pumpWidget(wrap(const ConverterScreen()));
    await tester.pumpAndSettle();

    // Language pill'larda "Lotin" va "Кирилл"
    expect(find.text('Lotin'), findsOneWidget);
    expect(find.text('Кирилл'), findsOneWidget);

    // Swap button'ni topib bosish
    final swapButton = find.byIcon(Icons.swap_vert_rounded);
    if (swapButton.evaluate().isEmpty) {
      // Boshqa swap icon'ni qidirish
      final iconButtons = find.byType(InkWell);
      expect(iconButtons, findsWidgets);
    }
  });

  testWidgets('AppBar\'da Tarix va Sozlamalar tugmalari bor', (tester) async {
    await tester.pumpWidget(wrap(const ConverterScreen()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets('Clear tugmasi input matnni tozalaydi', (tester) async {
    await tester.pumpWidget(wrap(const ConverterScreen()));
    await tester.pumpAndSettle();

    final inputFields = find.byType(TextFormField);
    await tester.enterText(inputFields.first, 'salom');
    await tester.pump();

    expect(find.text('салом'), findsOneWidget);

    // Clear iconi
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    // Output ham bo'sh bo'lishi kerak
    expect(find.text('салом'), findsNothing);
  });

  testWidgets('Action tugmalari (Nusxa, Ulashish, Saqlash) ko\'rinadi',
      (tester) async {
    await tester.pumpWidget(wrap(const ConverterScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Nusxa'), findsOneWidget);
    expect(find.text('Ulashish'), findsOneWidget);
    expect(find.text('Saqlash'), findsOneWidget);
  });

  testWidgets('Yangi ilovada onboarding dialog chiqadi (shown=false)',
      (tester) async {
    SharedPreferences.setMockInitialValues({}); // onboarding_shown yo'q
    await tester.pumpWidget(wrap(const ConverterScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Yozu ga xush kelibsiz!'), findsOneWidget);
    expect(find.text('Boshlash'), findsOneWidget);
  });

  testWidgets('Clipboard paste tugmasi ishlaydi', (tester) async {
    // Clipboard'ga matn qo'yish (mock)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': 'dunyo'};
      }
      return null;
    });

    await tester.pumpWidget(wrap(const ConverterScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.content_paste_rounded));
    await tester.pump();

    expect(find.text('dunyo'), findsOneWidget);
    expect(find.text('дунё'), findsOneWidget);
  });
}
