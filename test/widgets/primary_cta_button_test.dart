import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/primary_cta_button.dart';

import '../helpers/test_setup.dart';

void main() {
  group('PrimaryCtaButton Tests', () {
    testWidgets('TC_W_CTA_001 — renders the given label', (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: PrimaryCtaButton(label: 'Book Now', onTap: () {}),
        ),
      );
      expect(find.text('Book Now'), findsOneWidget);
    });

    testWidgets('TC_W_CTA_002 — renders a custom label', (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: PrimaryCtaButton(label: 'Inquire Now', onTap: () {}),
        ),
      );
      expect(find.text('Inquire Now'), findsOneWidget);
    });

    testWidgets('TC_W_CTA_003 — onTap fires when tapped', (tester) async {
      var tapped = 0;
      await pumpTLBApp(
        tester,
        Scaffold(
          body: PrimaryCtaButton(label: 'Book Now', onTap: () => tapped++),
        ),
      );
      await tester.tap(find.text('Book Now'));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('TC_W_CTA_004 — label is medium-bold (w600)', (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: PrimaryCtaButton(label: 'Book Now', onTap: () {}),
        ),
      );
      final text = tester.widget<Text>(find.text('Book Now'));
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('TC_W_CTA_005 — label is centre-aligned', (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: PrimaryCtaButton(label: 'Book Now', onTap: () {}),
        ),
      );
      final text = tester.widget<Text>(find.text('Book Now'));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('TC_W_CTA_006 — stretches to full available width', (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: PrimaryCtaButton(label: 'Book Now', onTap: () {}),
        ),
      );
      final width = tester.getSize(find.byType(PrimaryCtaButton)).width;
      // Body is unpadded, so a width:double.infinity button fills the screen.
      expect(width, tester.getSize(find.byType(Scaffold)).width);
    });

    testWidgets('TC_W_CTA_007 — uses a rounded gold Material pill', (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: PrimaryCtaButton(label: 'Book Now', onTap: () {}),
        ),
      );
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(PrimaryCtaButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.borderRadius, BorderRadius.circular(24));
    });

    testWidgets('TC_W_CTA_008 — long label does not overflow', (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: PrimaryCtaButton(
            label: 'Reserve Your Spot For This Weekend Workshop Now',
            onTap: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
