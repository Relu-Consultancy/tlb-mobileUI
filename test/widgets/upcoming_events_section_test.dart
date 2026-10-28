import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/upcoming_events_section.dart';

import '../helpers/test_setup.dart';

void main() {
  group('UpcomingEventsSection', () {
    // The loop: a detail screen listed the very listing being viewed, so
    // tapping it pushed an identical screen and Back returned to what looked
    // like the same page.
    testWidgets('TC_W_UE_001 — takes the id of the listing to leave out',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: SingleChildScrollView(
            child: UpcomingEventsSection(excludeListingId: 'a379ee9f'),
          ),
        ),
      );
      await tester.pump();

      final section = tester.widget<UpcomingEventsSection>(
        find.byType(UpcomingEventsSection),
      );
      expect(section.excludeListingId, 'a379ee9f');
    });

    testWidgets('TC_W_UE_002 — renders without an id, for the organizer page',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: SingleChildScrollView(
            child: UpcomingEventsSection(showDivider: true),
          ),
        ),
      );
      await tester.pump();

      final section = tester.widget<UpcomingEventsSection>(
        find.byType(UpcomingEventsSection),
      );
      expect(section.excludeListingId, isNull);
      expect(tester.takeException(), isNull);
    });

    // The bug this guards: fetching an unfiltered page (default ordering,
    // oldest/seed data first in this dataset) and then stripping ended
    // events client-side could legitimately zero out a whole page — 10/10
    // events on page 1 were already-ended seed data, hiding the 11 genuinely
    // upcoming events sitting on page 2+. date_preset: 'upcoming' filters
    // server-side instead, so pagination front-loading can't hide anything.
    //
    // A static check, not a live-network assertion: these services call
    // http.get directly with no injectable client (see
    // auth_service_test.dart), so there's no seam to mock this widget's
    // fetch through.
    test('TC_W_UE_003 — fetches with date_preset: upcoming, not an unfiltered page', () {
      final src = File('lib/widgets/upcoming_events_section.dart').readAsStringSync();
      expect(src, contains("datePreset: 'upcoming'"));
    });
  });
}
