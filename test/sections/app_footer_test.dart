import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/screens/privacy_policy_screen.dart';
import 'package:tlb_mobile_ui/screens/terms_of_service_screen.dart';
import 'package:tlb_mobile_ui/sections/app_footer.dart';

import '../helpers/test_setup.dart';

Future<void> _pumpFooter(WidgetTester tester) async {
  await pumpTLBApp(
    tester,
    const Scaffold(
      body: SingleChildScrollView(child: AppFooter()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AppFooter policy links', () {
    // These were plain Text — they looked like links and did nothing.
    testWidgets('TC_S_AF_001 — Privacy Policy opens the policy screen',
        (tester) async {
      await _pumpFooter(tester);

      await tester.ensureVisible(find.text('Privacy Policy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    });

    testWidgets('TC_S_AF_002 — Terms & Conditions opens the terms screen',
        (tester) async {
      await _pumpFooter(tester);

      await tester.ensureVisible(find.text('Terms & Conditions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terms & Conditions'));
      await tester.pumpAndSettle();

      expect(find.byType(TermsOfServiceScreen), findsOneWidget);
    });

    // Same destinations the About Us list in Accounts uses, so the two routes
    // into these documents can't drift apart.
    testWidgets('TC_S_AF_003 — all four labels are still rendered',
        (tester) async {
      await _pumpFooter(tester);

      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Contact Us'), findsOneWidget);
      expect(find.text('Become a Partner'), findsOneWidget);
    });

    testWidgets('TC_S_AF_004 — links with no destination stay inert',
        (tester) async {
      await _pumpFooter(tester);

      // Contact Us / Become a Partner have nowhere to go yet, so they must not
      // present themselves as tappable.
      expect(
        find.ancestor(
          of: find.text('Contact Us'),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: find.text('Privacy Policy'),
          matching: find.byType(GestureDetector),
        ),
        findsOneWidget,
      );
    });
  });
}
