import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/social_links_row.dart';

import '../helpers/test_setup.dart';

void main() {
  group('SocialLinksRow Tests', () {
    // The API sends `social_links` with an empty string for anything the
    // partner has not set. Drawing a mark for one of those gives the user a
    // button that goes nowhere, so only the links that exist are rendered.
    testWidgets('TC_W_SLR_001 — draws a mark for each link that is set',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: SocialLinksRow(
            instagramUrl: 'https://instagram.com/tlb',
            facebookUrl: 'https://facebook.com/tlb',
            linkedinUrl: 'https://linkedin.com/company/tlb',
          ),
        ),
      );
      expect(find.byType(SvgPicture), findsNWidgets(3));
    });

    testWidgets('TC_W_SLR_002 — each mark is labelled for a11y',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: SocialLinksRow(
            instagramUrl: 'https://instagram.com/tlb',
            facebookUrl: 'https://facebook.com/tlb',
            linkedinUrl: 'https://linkedin.com/company/tlb',
            websiteUrl: 'https://tlb.example.com',
          ),
        ),
      );
      expect(find.bySemanticsLabel('Instagram'), findsOneWidget);
      expect(find.bySemanticsLabel('Facebook'), findsOneWidget);
      expect(find.bySemanticsLabel('LinkedIn'), findsOneWidget);
      expect(find.bySemanticsLabel('Website'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('TC_W_SLR_003 — an unset link draws nothing at all',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: SocialLinksRow(instagramUrl: 'https://instagram.com/tlb'),
        ),
      );
      expect(find.byType(SvgPicture), findsOneWidget);

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Facebook'), findsNothing);
      expect(find.bySemanticsLabel('LinkedIn'), findsNothing);
      handle.dispose();
    });

    // The API writes an unset link as "" rather than null or a missing key,
    // and ApiProvider normalises that — but the row must not depend on it.
    testWidgets('TC_W_SLR_004 — an empty string counts as unset',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: SocialLinksRow(
            instagramUrl: '',
            facebookUrl: '   ',
            linkedinUrl: 'https://linkedin.com/company/tlb',
          ),
        ),
      );
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('TC_W_SLR_005 — a partner with no links takes no height',
        (tester) async {
      await pumpTLBApp(tester, const Scaffold(body: SocialLinksRow()));
      expect(find.byType(SvgPicture), findsNothing);
      expect(tester.getSize(find.byType(SocialLinksRow)).height, 0);
    });

    testWidgets('TC_W_SLR_006 — hasAny tells a caller whether to leave a gap',
        (tester) async {
      const none = SocialLinksRow();
      const one = SocialLinksRow(websiteUrl: 'https://tlb.example.com');
      const blank = SocialLinksRow(instagramUrl: '');
      expect(none.hasAny, isFalse);
      expect(blank.hasAny, isFalse);
      expect(one.hasAny, isTrue);
    });

    // The website has no brand mark of its own, so it rides a material globe
    // rather than an SVG — it must still be a tappable, labelled button.
    testWidgets('TC_W_SLR_007 — the website link renders as a globe',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: SocialLinksRow(websiteUrl: 'https://tlb.example.com'),
        ),
      );
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
    });
  });
}
