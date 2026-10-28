import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/dark_category_section.dart';
import 'package:tlb_mobile_ui/widgets/four_point_star.dart';

import '../helpers/test_setup.dart';

void main() {
  group('DarkCategoryTitle Tests', () {
    testWidgets('TC_W_DCT_001 — renders the title text', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: DarkCategoryTitle('Explore by Categories')),
      );
      expect(find.text('Explore by Categories'), findsOneWidget);
    });

    testWidgets('TC_W_DCT_002 — flanks the title with two ornament stars', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: DarkCategoryTitle('What\'s the Plan?')),
      );
      expect(find.byType(FourPointStar), findsNWidgets(2));
    });

    testWidgets('TC_W_DCT_003 — title is centre-aligned', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: DarkCategoryTitle('Pave Your Path')),
      );
      final text = tester.widget<Text>(find.text('Pave Your Path'));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('TC_W_DCT_004 — long title does not overflow', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: DarkCategoryTitle(
            'Explore Every Format, Age Group and Interest Available',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('DarkViewAllButton Tests', () {
    testWidgets('TC_W_DVA_001 — renders the "View All" label and arrow', (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(body: DarkViewAllButton(onTap: () {})),
      );
      expect(find.text('View All'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('TC_W_DVA_002 — onTap fires when the pill is tapped', (tester) async {
      var tapped = 0;
      await pumpTLBApp(
        tester,
        Scaffold(body: DarkViewAllButton(onTap: () => tapped++)),
      );
      await tester.tap(find.text('View All'));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('TC_W_DVA_003 — dark shade band does not intercept taps', (tester) async {
      // The gradient shade band behind the pill is wrapped in IgnorePointer so
      // it never steals taps from the grid behind it.
      await pumpTLBApp(
        tester,
        Scaffold(body: DarkViewAllButton(onTap: () {})),
      );
      expect(
        find.descendant(
          of: find.byType(DarkViewAllButton),
          matching: find.byType(IgnorePointer),
        ),
        findsOneWidget,
      );
    });
  });

  group('goldBannerSideGlow Tests', () {
    test('TC_U_GBS_001 — returns exactly two side shadows', () {
      final glow = goldBannerSideGlow();
      expect(glow.length, 2);
    });

    test('TC_U_GBS_002 — shadows are offset to the left and right only', () {
      final glow = goldBannerSideGlow();
      expect(glow[0].offset.dx, -13);
      expect(glow[1].offset.dx, 13);
      // Side-only glow: no vertical offset.
      expect(glow[0].offset.dy, 0);
      expect(glow[1].offset.dy, 0);
    });

    test('TC_U_GBS_003 — opacity parameter drives the shadow alpha', () {
      final faint = goldBannerSideGlow(opacity: 0.2);
      final strong = goldBannerSideGlow(opacity: 0.8);
      expect(strong[0].color.opacity, greaterThan(faint[0].color.opacity));
    });
  });
}
