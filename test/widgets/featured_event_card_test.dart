import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/widgets/featured_event_card.dart';

import '../helpers/test_setup.dart';

void main() {
  group('FeaturedEventCard Tests', () {
    const testEvent = EventModel(
      id: 'e2',
      title: 'Kids Dance',
      venue: 'Main Studio',
      imagePath: 'assets/images/placeholder.png',
    );

    testWidgets('renders FeaturedEventCard correctly', (WidgetTester tester) async {
      await pumpTLBApp(tester, const Scaffold(body: FeaturedEventCard(event: testEvent)));

      expect(find.text('Kids Dance'), findsOneWidget);
      expect(find.text('Main Studio'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
