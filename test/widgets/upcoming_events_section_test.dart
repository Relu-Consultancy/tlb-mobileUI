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
  });
}
