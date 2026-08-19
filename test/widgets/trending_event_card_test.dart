import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/app_colors.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/widgets/trending_event_card.dart';

import '../helpers/test_setup.dart';

void main() {
  group('TrendingEventCard Tests', () {
    const testEvent = EventModel(
      id: 't1',
      title: 'Robotics Academies',
      venue: 'Techno Park',
      imagePath: 'assets/images/placeholder.png',
      tag: 'Workshop',
      description: '4-12 Yrs',
      eventDate: 'Sat, 21 Mar',
    );

    testWidgets('TC_W_TEC_001 — renders title, venue and tag', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: TrendingEventCard(event: testEvent)),
      );
      expect(find.text('Robotics Academies'), findsOneWidget);
      expect(find.text('Techno Park'), findsOneWidget);
      expect(find.text('Workshop'), findsOneWidget);
    });

    testWidgets('TC_W_TEC_002 — has no separate CTA; whole card is tappable', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: TrendingEventCard(event: testEvent)),
      );
      expect(find.text('Book Now'), findsNothing);
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('TC_W_TEC_004 — shows the distance tag beside the location',
        (tester) async {
      // Fills the space the location row left blank, matching the other
      // section cards.
      await pumpTLBApp(
        tester,
        const Scaffold(body: TrendingEventCard(event: testEvent)),
      );

      expect(find.text(testEvent.distanceDisplay), findsOneWidget);
      expect(find.byIcon(Icons.near_me_outlined), findsOneWidget);

      final label = tester.widget<Text>(find.text(testEvent.distanceDisplay));
      expect(label.style!.color, AppColors.distanceGreen);
    });

    testWidgets('TC_W_TEC_003 — splits the event date into the badge', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: TrendingEventCard(event: testEvent)),
      );
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('21 Mar'), findsOneWidget);
    });
  });
}
