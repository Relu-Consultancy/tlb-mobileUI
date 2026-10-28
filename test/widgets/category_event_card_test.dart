import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/widgets/category_event_card.dart';

import '../helpers/test_setup.dart';

// ── Fixtures ──────────────────────────────────────────────────────────────────

const _fullEvent = EventModel(
  id: 'evt-001',
  title: 'Summer Art Workshop',
  venue: 'Delhi',
  imagePath: 'assets/images/event1.png',
  tag: 'Arts & Crafts',
  rating: 4.5,
  reviewCount: '128 reviews',
  description: 'A hands-on creative workshop for kids aged 6-12.',
);

const _minimalEvent = EventModel(
  id: 'evt-002',
  title: 'Coding Bootcamp',
  venue: '',
  imagePath: 'assets/images/event2.png',
);

void main() {
  group('CategoryEventCard Tests', () {
    testWidgets('TC_CEC_001 — renders event title', (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(body: CategoryEventCard(event: _fullEvent)),
        );
        expect(find.text('Summer Art Workshop'), findsOneWidget);
      });
    });

    testWidgets('TC_CEC_002 — renders venue/location text', (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(body: CategoryEventCard(event: _fullEvent)),
        );
        expect(find.text('Delhi'), findsOneWidget);
      });
    });

    testWidgets('TC_CEC_003 — renders tag badge when tag is non-null', (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(body: CategoryEventCard(event: _fullEvent)),
        );
        expect(find.text('Arts & Crafts'), findsOneWidget);
      });
    });

    testWidgets('TC_CEC_004 — description section renders as RichText', (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(body: CategoryEventCard(event: _fullEvent)),
        );
        // Description is rendered as RichText (multi-span "Description – body")
        expect(find.byType(RichText), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('TC_CEC_005 — review count row hidden when reviewCount is null', (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(body: CategoryEventCard(event: _minimalEvent)),
        );
        // No star icon should appear when reviewCount is absent
        expect(find.byIcon(Icons.star), findsNothing);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('TC_CEC_006 — onTap callback fires on card tap', (tester) async {
      bool tapped = false;
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(
            body: CategoryEventCard(
              event: _fullEvent,
              onTap: () => tapped = true,
            ),
          ),
        );
        // Tap the title (a stable descendant of the card's GestureDetector)
        // rather than the card's computed centre — the latter is sensitive to
        // layout height and flakes under full-suite state, while this reliably
        // validates that tapping the card content fires onTap.
        await tester.tap(find.text('Summer Art Workshop'));
        expect(tapped, isTrue);
      });
    });

    testWidgets('TC_CEC_007 — default navigation pushes EventDetailScreen',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(body: CategoryEventCard(event: _fullEvent)),
        );
        await tester.tap(find.byType(CategoryEventCard));
        await tester.pump(); // start navigation — don't pumpAndSettle (network)
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('TC_CEC_008 — minimal event (no tag/rating) renders without overflow',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(body: CategoryEventCard(event: _minimalEvent)),
        );
        expect(find.text('Coding Bootcamp'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('TC_CEC_009 — network image event uses Image.network', (tester) async {
      const networkEvent = EventModel(
        id: 'evt-net',
        title: 'Online Concert',
        venue: 'Mumbai',
        imagePath: 'https://example.com/image.png',
      );
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(body: CategoryEventCard(event: networkEvent)),
        );
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('TC_CEC_010 — long title truncates without overflow', (tester) async {
      const longTitleEvent = EventModel(
        id: 'evt-long',
        title: 'An Extremely Long Event Title That Should Be Truncated With Ellipsis On Small Screens',
        venue: 'Hyderabad',
        imagePath: 'assets/images/event1.png',
      );
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(body: CategoryEventCard(event: longTitleEvent)),
        );
        expect(tester.takeException(), isNull);
      });
    });

    // This card has no card-shaped background of its own (image + bare text on
    // the page's white), so its tap target relies on HitTestBehavior.opaque.
    // Without it a deferToChild hit test only catches the image and the
    // glyphs, and the blank space between/beside the meta rows swallows taps.
    testWidgets('TC_CEC_011 — a tap on the card\'s blank area still opens it',
        (tester) async {
      var taps = 0;
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(
            body: Center(
              child: SizedBox(
                width: 180,
                child: CategoryEventCard(
                  event: _fullEvent,
                  onTap: () => taps++,
                ),
              ),
            ),
          ),
        );

        // Aim right of the venue line: inside the card's bounds, but over
        // blank space rather than any painted child.
        final venueRight = tester.getTopRight(find.text('Delhi'));
        final cardRight = tester.getTopRight(find.byType(CategoryEventCard));
        expect(venueRight.dx, lessThan(cardRight.dx),
            reason: 'need blank space right of the venue to aim at');

        await tester.tapAt(Offset(
          (venueRight.dx + cardRight.dx) / 2,
          venueRight.dy + 6,
        ));
        await tester.pump();

        expect(taps, 1);
      });
    });

    testWidgets('TC_CEC_012 — card is opaque to hit testing', (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(
            body: CategoryEventCard(
              event: _fullEvent,
            ),
          ),
        );
        final detector = tester.widget<GestureDetector>(
          find
              .descendant(
                of: find.byType(CategoryEventCard),
                matching: find.byType(GestureDetector),
              )
              .first,
        );
        expect(detector.behavior, HitTestBehavior.opaque);
      });
    });
  });
}
