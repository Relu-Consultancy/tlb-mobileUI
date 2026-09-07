import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/event_detail_screen.dart';
import 'package:tlb_mobile_ui/widgets/section_hero_card.dart';

import '../helpers/test_setup.dart';

/// The section's "top banner" — the listing an admin flags as its hero.
EventModel _hero({
  String title = 'Summer Arts Festival',
  String venue = 'Sector A, Mumbai',
  String? date = 'Fri, 4 Sep 2026',
}) =>
    EventModel(
      id: 'h1',
      title: title,
      venue: venue,
      imagePath: '',
      eventDate: date,
    );

Future<void> _pump(WidgetTester tester, EventModel event) => pumpTLBApp(
      tester,
      Scaffold(body: SectionHeroCard(event: event)),
    );

void main() {
  group('SectionHeroCard', () {
    testWidgets('TC_W_SHC_001 — names the listing and marks it featured',
        (tester) async {
      await _pump(tester, _hero());
      expect(find.text('Summer Arts Festival'), findsOneWidget);
      expect(find.text('FEATURED'), findsOneWidget);
    });

    testWidgets('TC_W_SHC_002 — the meta line joins date and place',
        (tester) async {
      await _pump(tester, _hero());
      expect(find.text('Fri, 4 Sep 2026  •  Sector A, Mumbai'), findsOneWidget);
    });

    testWidgets('TC_W_SHC_003 — a missing date leaves no empty separator',
        (tester) async {
      // The feed omits any of these; " •  " on its own reads as broken.
      await _pump(tester, _hero(date: null));
      expect(find.text('Sector A, Mumbai'), findsOneWidget);
      expect(find.textContaining('•'), findsNothing);
    });

    testWidgets('TC_W_SHC_004 — with neither, no meta line at all',
        (tester) async {
      await _pump(tester, _hero(venue: '', date: null));
      expect(find.text('Summer Arts Festival'), findsOneWidget);
      expect(find.textContaining('•'), findsNothing);
    });

    testWidgets('TC_W_SHC_005 — is wider than it is tall, being a banner',
        (tester) async {
      await _pump(tester, _hero());
      final size = tester.getSize(find.byType(SectionHeroCard));
      expect(size.width, greaterThan(size.height));
    });

    testWidgets('TC_W_SHC_006 — tapping it opens the listing', (tester) async {
      await _pump(tester, _hero());
      await tester.tap(find.text('Summer Arts Festival'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(EventDetailScreen), findsOneWidget);
    });

    testWidgets('TC_W_SHC_007 — a long title is clamped, not overflowing',
        (tester) async {
      await _pump(
        tester,
        _hero(title: 'A Very Long Featured Listing Title That Runs On And On'),
      );
      final text = tester.widget<Text>(find.textContaining('A Very Long'));
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}
