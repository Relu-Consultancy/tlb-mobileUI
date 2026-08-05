import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/widgets/weekend_event_card.dart';
import 'package:tlb_mobile_ui/widgets/primary_cta_button.dart';

import '../helpers/test_setup.dart';

void main() {
  group('WeekendEventCard Tests', () {
    const testEvent = EventModel(
      id: 'w1',
      title: 'Kids Baking Workshop',
      venue: 'Little Chef Studio',
      imagePath: 'assets/images/placeholder.png',
      eventDate: 'Sat, 16 Mar 2026',
      eventTime: '11:00 AM',
    );

    testWidgets('TC_W_WEC_001 — renders title and venue', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: WeekendEventCard(event: testEvent)),
      );
      expect(find.text('Kids Baking Workshop'), findsOneWidget);
      expect(find.text('Little Chef Studio'), findsOneWidget);
    });

    testWidgets('TC_W_WEC_002 — uses the shared full-width Book Now CTA', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: WeekendEventCard(event: testEvent)),
      );
      expect(find.byType(PrimaryCtaButton), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);
    });

    testWidgets('TC_W_WEC_003 — respects the width parameter', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: WeekendEventCard(event: testEvent, width: 300),
          ),
        ),
      );
      expect(tester.getSize(find.byType(WeekendEventCard)).width, 300);
    });
  });
}
