import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/social_links_row.dart';

import '../helpers/test_setup.dart';

void main() {
  group('SocialLinksRow Tests', () {
    testWidgets('TC_W_SLR_001 — renders all three brand marks', (tester) async {
      await pumpTLBApp(tester, const Scaffold(body: SocialLinksRow()));
      expect(find.byType(SvgPicture), findsNWidgets(3));
    });

    testWidgets('TC_W_SLR_002 — each mark is labelled for a11y',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTLBApp(tester, const Scaffold(body: SocialLinksRow()));
      expect(find.bySemanticsLabel('Instagram'), findsOneWidget);
      expect(find.bySemanticsLabel('Facebook'), findsOneWidget);
      expect(find.bySemanticsLabel('LinkedIn'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('TC_W_SLR_003 — the marks show even with no links yet',
        (tester) async {
      // They are placeholders until the revised backend sends URLs; the row
      // must not collapse to nothing in the meantime.
      await pumpTLBApp(tester, const Scaffold(body: SocialLinksRow()));
      expect(find.byType(SocialLinksRow), findsOneWidget);
      expect(tester.getSize(find.byType(SocialLinksRow)).height,
          greaterThan(0));
    });

    testWidgets('TC_W_SLR_004 — tapping a link-less mark explains itself',
        (tester) async {
      await pumpTLBApp(tester, const Scaffold(body: SocialLinksRow()));
      await tester.tap(find.byType(SvgPicture).first);
      await tester.pump();
      expect(find.text('Link coming soon'), findsOneWidget);
    });

    testWidgets('TC_W_SLR_005 — a supplied link is not treated as missing',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: SocialLinksRow(instagramUrl: 'https://instagram.com/tlb'),
        ),
      );
      await tester.tap(find.byType(SvgPicture).first);
      await tester.pump();
      // It tries to launch instead. (The launcher plugin is absent under
      // test, so the attempt fails — but it must not fall back to the
      // placeholder message.)
      expect(find.text('Link coming soon'), findsNothing);
    });
  });
}
