import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_absensi_smk_jaya_buana/main.dart';
import 'package:flutter_absensi_smk_jaya_buana/routing/app_router.dart';

void main() {
  testWidgets('App boots into the registration screen by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        const JayaBuanaApp(initialRoute: AppRoutes.registration));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
