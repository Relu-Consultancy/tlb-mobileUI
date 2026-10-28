import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tlb_mobile_ui/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TLBApp(isLoggedIn: false));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
