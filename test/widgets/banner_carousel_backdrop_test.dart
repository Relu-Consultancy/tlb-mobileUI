import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/widgets/banner_carousel.dart';
import 'package:tlb_mobile_ui/widgets/dark_category_section.dart';

import '../helpers/test_setup.dart';

/// The Events / Classes / Programs / Venues screens each used to park a black
/// rounded plate (carrying the gold side-glow) BEHIND the banner carousel.
/// A plate outside the PageView doesn't move, so swiping slid the banners
/// across a backdrop that visibly stayed put — the black base showing through
/// beside the moving card. The Home "Spotlight" carousel never had this,
/// because its glow lives on the card.
///
/// These pin the fix: the fill + glow are painted as part of each card, and
/// no screen re-introduces a standalone plate.
EventModel _banner(String title) => EventModel(
      title: title,
      venue: 'Mumbai',
      imagePath: 'resources- tlb-ui/banner.png',
    );

void main() {
  String read(String path) => File(path).readAsStringSync();

  const screens = <String, String>{
    'events': 'lib/screens/events_screen.dart',
    'classes': 'lib/screens/classes_screen.dart',
    'programs': 'lib/screens/programs_screen.dart',
    'venues': 'lib/screens/venues_screen.dart',
  };

  group('BannerCarousel — the backdrop belongs to the card', () {
    testWidgets('TC_W_BC_001 — each slide paints the fill and the glow',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: BannerCarousel(
            events: [_banner('One'), _banner('Two')],
            height: 300,
            cardColor: Colors.black,
            cardShadow: goldBannerSideGlow(),
          ),
        ),
      );

      // The card sits inside the PageView, so it travels with the page.
      final card = find.descendant(
        of: find.byType(PageView),
        matching: find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == Colors.black),
      );
      expect(card, findsWidgets);

      final decoration =
          tester.widgetList<Container>(card).first.decoration as BoxDecoration;
      expect(decoration.color, Colors.black);
      expect(decoration.boxShadow, goldBannerSideGlow());
    });

    testWidgets('TC_W_BC_002 — no fill or glow unless asked for',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: BannerCarousel(
            events: [_banner('One')],
            height: 300,
          ),
        ),
      );

      final card = find.descendant(
        of: find.byType(PageView),
        matching: find.byWidgetPredicate((w) =>
            w is Container && w.decoration is BoxDecoration && w.child != null),
      );
      final decoration =
          tester.widgetList<Container>(card).first.decoration as BoxDecoration;
      expect(decoration.color, isNull);
      expect(decoration.boxShadow, isNull);
    });
  });

  group('Category screens — no fixed plate behind the carousel', () {
    for (final entry in screens.entries) {
      test('TC_S_${entry.key}_BANNER — glow rides on the card', () {
        final src = read(entry.value);
        expect(src, contains('cardColor: Colors.black'));
        expect(src, contains('cardShadow: goldBannerSideGlow()'));
        expect(
          src,
          isNot(contains('boxShadow: goldBannerSideGlow()')),
          reason: 'that is the standalone backdrop plate the carousel '
              'used to slide across',
        );
      });
    }
  });
}
