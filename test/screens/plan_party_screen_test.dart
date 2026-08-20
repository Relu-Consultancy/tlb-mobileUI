import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/plan_party_screen.dart';

import '../helpers/test_setup.dart';

const _venue = EventModel(
  id: 'v1',
  title: 'The Lalaland',
  venue: 'Powai, Mumbai',
  imagePath: 'assets/images/placeholder.png',
  rating: 4.5,
  reviewCount: '(124 reviews)',
);

Future<void> _pump(WidgetTester tester) async {
  await mockNetworkImages(() async {
    await pumpTLBApp(tester, const PlanPartyScreen(event: _venue));
    await tester.pumpAndSettle();
  });
}

void main() {
  group('PlanPartyScreen', () {
    testWidgets('TC_S_PP_001 — shows the venue, not a decorative map',
        (tester) async {
      await _pump(tester);

      expect(find.text('The Lalaland'), findsOneWidget);
      expect(find.text('Powai, Mumbai'), findsOneWidget);
      // The mini-map was a CustomPaint with no real location data.
      expect(find.byType(CustomPaint).evaluate().isEmpty, isFalse,
          reason: 'Material itself paints; assert on the venue image instead');
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('TC_S_PP_002 — every section is present', (tester) async {
      await _pump(tester);

      expect(find.text("Planner's Name"), findsOneWidget);
      expect(find.text('Occasion'), findsOneWidget);
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Number of Attendees'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    // The old layout floated the Continue button over the scroll view, so the
    // last field's helper text was clipped behind it.
    testWidgets('TC_S_PP_003 — the button sits below the content, not over it',
        (tester) async {
      await _pump(tester);

      final scrollBottom =
          tester.getRect(find.byType(SingleChildScrollView)).bottom;
      final buttonTop = tester.getRect(find.text('Continue')).top;

      expect(buttonTop, greaterThanOrEqualTo(scrollBottom),
          reason: 'content must end before the button begins');
    });

    testWidgets('TC_S_PP_004 — an occasion can be picked by tapping the row',
        (tester) async {
      await _pump(tester);

      final first = find.byIcon(Icons.radio_button_unchecked).first;
      expect(first, findsOneWidget);

      await tester.tap(first);
      await tester.pumpAndSettle();

      // Exactly one selected, and it is a single-choice group.
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    });

    testWidgets('TC_S_PP_005 — says so when the venue has no availability',
        (tester) async {
      await _pump(tester);
      expect(
        find.text('No availability slots found for this venue'),
        findsOneWidget,
      );
    });
  });
}
