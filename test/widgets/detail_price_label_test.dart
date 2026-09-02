import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/detail_sections.dart';

import '../helpers/test_setup.dart';

/// The label's rendered text. `find.textContaining` does not walk RichText
/// spans, so a `findsNothing` assertion against it passes vacuously -- it
/// never matches this widget at all.
String _plain(WidgetTester tester) => tester
    .widget<RichText>(find.descendant(
        of: find.byType(DetailPriceLabel), matching: find.byType(RichText)))
    .text
    .toPlainText();

void main() {
  group('DetailPriceLabel Tests', () {
    testWidgets('TC_W_DPL_001 — a lowest price is qualified with onwards',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: DetailPriceLabel('₹299', from: true)),
      );
      expect(_plain(tester), '₹299 onwards');
    });

    testWidgets('TC_W_DPL_002 — an exact price carries no qualifier',
        (tester) async {
      // A class fee is what it costs; "onwards" there would be a lie.
      await pumpTLBApp(
        tester,
        const Scaffold(body: DetailPriceLabel('₹299')),
      );
      expect(_plain(tester), '₹299');
    });

    testWidgets('TC_W_DPL_003 — a non-numeric price is never qualified',
        (tester) async {
      // The event screen falls back to "Paid" when no ticket carries a
      // number, and "Paid onwards" is nonsense.
      await pumpTLBApp(
        tester,
        const Scaffold(body: DetailPriceLabel('Paid', from: true)),
      );
      expect(_plain(tester), 'Paid');
    });

    testWidgets('TC_W_DPL_004 — no dangling slash', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: DetailPriceLabel('₹299', from: true)),
      );
      expect(_plain(tester), isNot(contains('/')));
    });

    testWidgets('TC_W_DPL_005 — a wide price leaves the CTA on one line',
        (tester) async {
      // Adding a qualifier widens the price; with a flex:2 button and a
      // Spacer the leftover split 1:2 and wrapped the CTA at 360-390px.
      tester.view.physicalSize = const Size(360, 200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await pumpTLBApp(
        tester,
        Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Row(
                  children: [
                    const DetailPriceLabel('₹4999', from: true),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Send Enquiry'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      final label =
          tester.renderObject<RenderBox>(find.text('Send Enquiry'));
      expect(label.size.height, lessThan(30), reason: 'CTA label wrapped');
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC_W_DPL_006 — Free renders as its own pill', (tester) async {
      await pumpTLBApp(tester, const Scaffold(body: DetailFreePill()));
      expect(find.text('Free'), findsOneWidget);
      final box = tester.widget<Container>(find.descendant(
          of: find.byType(DetailFreePill), matching: find.byType(Container)));
      expect((box.decoration! as BoxDecoration).borderRadius, isNotNull);
    });
  });
}
