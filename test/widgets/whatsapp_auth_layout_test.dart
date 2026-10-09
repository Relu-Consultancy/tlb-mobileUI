import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/app_theme.dart';
import 'package:tlb_mobile_ui/screens/whatsapp_login_screen.dart';
import 'package:tlb_mobile_ui/screens/whatsapp_signup_screen.dart';
import 'package:tlb_mobile_ui/widgets/whatsapp_auth_card.dart';

/// The text under the Send OTP button ("Already have an account? Login with
/// WhatsApp") must fit every screen size: it wraps onto a second centred line
/// rather than overflowing. Pumped without pumpTLBApp, which hides overflow.
void main() {
  Future<void> pumpAt(
      WidgetTester tester, Widget screen, double width, double textScale) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: screen,
    ));
    await tester.pump();
  }

  final cases = <String, (Widget, String)>{
    'signup': (const WhatsAppSignupScreen(), 'Login with WhatsApp'),
    'login': (const WhatsAppLoginScreen(), 'Signup with WhatsApp'),
  };

  for (final width in [280.0, 320.0, 360.0, 411.0, 600.0]) {
    for (final scale in [1.0, 1.4]) {
      cases.forEach((name, c) {
        testWidgets(
            'TC_W_WAL_001 — $name footer fits at ${width.toInt()}px, '
            'text x$scale', (tester) async {
          await pumpAt(tester, c.$1, width, scale);
          // Any overflow would already have failed the test.
          expect(tester.takeException(), isNull);
          final rect = tester.getRect(find.text(c.$2));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(width));
        });
      });
    }
  }

  testWidgets('TC_W_WAL_002 — the real WhatsApp logo is used, not a chat icon',
      (tester) async {
    await pumpAt(tester, const WhatsAppLoginScreen(), 360, 1.0);
    await tester.pumpAndSettle();
    // Hero + number field.
    expect(find.byType(WhatsAppLogo), findsNWidgets(2));
    expect(find.byIcon(Icons.chat_rounded), findsNothing);
    expect(find.bySemanticsLabel('WhatsApp'), findsWidgets);
  });
}
