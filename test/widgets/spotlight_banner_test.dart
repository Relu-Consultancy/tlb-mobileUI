import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/widgets/primary_cta_button.dart';
import 'package:tlb_mobile_ui/widgets/spotlight_banner.dart';
import 'package:tlb_mobile_ui/widgets/wishlist_button.dart';

import '../helpers/test_setup.dart';

/// The Spotlight poster is finished artwork — it carries its own headline and
/// call to action. A "WORKSHOP" tag pinned over its top-left corner and a
/// "Book Tickets" button bolted under it both competed with the art, so
/// neither is drawn any more. The card itself stays the tap target.
const _event = EventModel(
  id: 'spot-1',
  title: 'Stories that stay',
  venue: 'TLB Studio, Belapur',
  imagePath: 'resources- tlb-ui/spotlight.png',
  tag: 'WORKSHOP',
  eventDate: 'Sat, 31 May',
  eventTime: '10:00 AM',
);

void main() {
  Future<void> pumpBanner(WidgetTester tester) => pumpTLBApp(
        tester,
        const Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox(
            height: 620,
            child: SpotlightBanner(events: [_event]),
          ),
        ),
      );

  group('SpotlightBanner Tests', () {
    testWidgets('TC_W_SB_001 — draws no CTA button under the poster',
        (tester) async {
      await pumpBanner(tester);
      expect(find.byType(PrimaryCtaButton), findsNothing);
      expect(find.text('Book Tickets'), findsNothing);
    });

    testWidgets('TC_W_SB_002 — draws no tag badge over the poster, even when '
        'the listing has one', (tester) async {
      await pumpBanner(tester);
      expect(_event.tag, 'WORKSHOP');
      expect(find.text('WORKSHOP'), findsNothing);
    });

    testWidgets('TC_W_SB_003 — keeps the meta row and the wishlist heart',
        (tester) async {
      await pumpBanner(tester);
      expect(find.text('Sat, 31 May'), findsOneWidget);
      expect(find.text('10:00 AM'), findsOneWidget);
      expect(find.text('TLB Studio, Belapur'), findsOneWidget);
      expect(find.byType(WishlistButton), findsOneWidget);
    });

    testWidgets('TC_W_SB_004 — the card is still the tap target for the '
        'listing', (tester) async {
      await pumpBanner(tester);
      expect(find.byType(GestureDetector), findsWidgets);
      final tap = tester
          .widgetList<GestureDetector>(find.descendant(
            of: find.byType(SpotlightBanner),
            matching: find.byType(GestureDetector),
          ))
          .where((g) => g.onTap != null);
      expect(tap, isNotEmpty);
    });
  });
}
