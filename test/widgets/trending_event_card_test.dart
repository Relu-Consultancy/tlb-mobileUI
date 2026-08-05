import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/widgets/trending_event_card.dart';
import 'package:tlb_mobile_ui/widgets/primary_cta_button.dart';

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

    testWidgets('TC_W_TEC_002 — uses the shared full-width Book Now CTA', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: TrendingEventCard(event: testEvent)),
      );
      expect(find.byType(PrimaryCtaButton), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);
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
