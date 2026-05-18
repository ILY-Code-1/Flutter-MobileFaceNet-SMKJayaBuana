import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_absensi_smk_jaya_buana/main.dart';

void main() {
  testWidgets('App boots into dev navigator', (WidgetTester tester) async {
    await tester.pumpWidget(const JayaBuanaApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
