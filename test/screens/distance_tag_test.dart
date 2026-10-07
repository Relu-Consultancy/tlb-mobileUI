import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/models/homepage_section_model.dart';
import 'package:tlb_mobile_ui/providers/discovery_feed_state.dart';
import 'package:tlb_mobile_ui/providers/location_state.dart';
import 'package:tlb_mobile_ui/screens/events_screen.dart';
import 'package:tlb_mobile_ui/screens/venues_screen.dart';
import 'package:tlb_mobile_ui/widgets/category_event_card.dart';

import '../helpers/test_setup.dart';

/// Every card on the browse surfaces shows the green "x km away" row when the
/// API measured a distance — several card designs used to leave it out, so
/// the tag appeared on some cards and not others. Rendered with a long
/// address too, so a card that can't fit the extra line fails on overflow.
HomepageListing _listing(String id, String type) => HomepageListing(
      id: id,
      title: 'A fairly long listing title for $id',
      shortDescription: '',
      listingType: type,
      isTlbSignature: false,
      city: 'Mumbai',
      area: 'Lokhandwala Complex, Andheri West, near the market',
      distanceKm: 5.4,
    );

void main() {
  setUp(() => LocationState().setCity('Mumbai'));
  tearDown(() {
    DiscoveryFeedState.venues.resetForTest();
    DiscoveryFeedState.events.resetForTest();
  });

  testWidgets('TC_S_DT_001 — every Venues card shows the distance',
      (tester) async {
    const sections = [
      'for_the_big_days',
      'weekend_plan_sorted',
      'close_to_you',
      'out_and_about',
      'hands_on_space',
      'easy_on_the_pocket',
      'headed_to_the_mall',
      'thoughtful_spaces',
    ];
    DiscoveryFeedState.venues.seedForTest({
      for (final s in sections) s: [_listing(s, 'venue')],
    });

    await mockNetworkImages(() async {
      await pumpTLBApp(tester, const VenuesScreen());
      await tester.pump(const Duration(milliseconds: 300));
    });

    // One per API-backed section ("Get Moving" is fixed sample content).
    expect(find.text('5.4 km away', skipOffstage: false),
        findsNWidgets(sections.length));
  });

  testWidgets('TC_S_DT_002 — the Events "this weekend" card shows it',
      (tester) async {
    DiscoveryFeedState.events.seedForTest({
      'happening_this_weekend': [_listing('w1', 'event')],
    });

    await mockNetworkImages(() async {
      await pumpTLBApp(tester, const EventsScreen());
      await tester.pump(const Duration(milliseconds: 300));
    });

    expect(find.text('5.4 km away', skipOffstage: false), findsOneWidget);
  });

  testWidgets('TC_W_DT_003 — the category grid card shows it', (tester) async {
    const event = EventModel(
      id: 'c1',
      title: 'A fairly long listing title that wraps',
      venue: 'Lokhandwala Complex, Andheri West, Mumbai',
      imagePath: '',
      distanceKm: 5.4,
    );
    await mockNetworkImages(() async {
      await pumpTLBApp(
        tester,
        const Center(
          // A cell of the two-up category grid (aspect 0.62).
          child: SizedBox(
              width: 170, height: 274, child: CategoryEventCard(event: event)),
        ),
      );
    });

    expect(find.text('5.4 km away'), findsOneWidget);
  });

  testWidgets('TC_W_DT_004 — no distance from the API, no row', (tester) async {
    const event = EventModel(
      id: 'c2',
      title: 'No coordinates stored',
      venue: 'Mumbai',
      imagePath: '',
    );
    await mockNetworkImages(() async {
      await pumpTLBApp(
        tester,
        const Center(
          child: SizedBox(
              width: 170, height: 274, child: CategoryEventCard(event: event)),
        ),
      );
    });

    expect(find.textContaining('km away'), findsNothing);
  });
}
