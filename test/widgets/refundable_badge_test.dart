import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/detail_sections.dart';
import 'package:tlb_mobile_ui/widgets/refundable_badge.dart';

import '../helpers/test_setup.dart';

void main() {
  group('RefundableBadge', () {
    testWidgets('TC_W_RB_001 — states the refundable policy', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: RefundableBadge(isRefundable: true)),
      );
      expect(find.text('Refundable'), findsOneWidget);
      expect(find.text('Non-refundable'), findsNothing);
    });

    testWidgets('TC_W_RB_002 — states the non-refundable policy',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: RefundableBadge(isRefundable: false)),
      );
      expect(find.text('Non-refundable'), findsOneWidget);
      expect(find.text('Refundable'), findsNothing);
    });

    // The row sits in a stack of self-padding cards (Terms & Conditions,
    // FAQs). Without its own inset it sat flush to the screen edge while they
    // were inset by 16, which is what made it read as an orphan.
    testWidgets('TC_W_RB_003 — aligns with the DetailTermsRow beside it',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: Column(
            children: [
              const RefundableBadge(isRefundable: true),
              DetailTermsRow(onTap: () {}),
            ],
          ),
        ),
      );

      final badgeLeft = tester.getTopLeft(find.text('Refundable')).dx;
      final termsLeft =
          tester.getTopLeft(find.text('Terms & Conditions')).dx;
      // Both rows inset the same amount, so their icons — and therefore their
      // text — start at the same x.
      expect((badgeLeft - termsLeft).abs(), lessThan(1.0));
    });

    testWidgets('TC_W_RB_004 — can opt out of its own inset', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: RefundableBadge(
            isRefundable: true,
            applyHorizontalPadding: false,
          ),
        ),
      );
      expect(find.byType(Padding), findsWidgets);
      expect(find.text('Refundable'), findsOneWidget);
    });

    testWidgets('TC_W_RB_005 — is not tappable; it only reports a policy',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: RefundableBadge(isRefundable: false)),
      );
      expect(
        find.descendant(
          of: find.byType(RefundableBadge),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
    });
  });
}
