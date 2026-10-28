
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sayi_reaktoru/main.dart';

void main() {
  testWidgets(
    'Sayı Reaktörü açılış testi',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ReactorApp());

      expect(find.byType(ReactorApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('⚡ SAYI REAKTÖRÜ'), findsOneWidget);
      expect(find.text('BÖLÜM 1 / 10'), findsOneWidget);
    },
  );
}
