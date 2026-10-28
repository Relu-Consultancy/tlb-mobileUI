import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/widgets/event_card.dart';

import '../helpers/test_setup.dart';

void main() {
  group('EventCard Tests', () {
    const testEvent = EventModel(
      id: 'e1',
      title: 'Magic Show',
      venue: 'City Hall',
      imagePath: 'assets/images/placeholder.png',
    );

    testWidgets('renders EventCard correctly', (WidgetTester tester) async {
      await pumpTLBApp(tester, const Scaffold(body: EventCard(event: testEvent)));

      // Verify text elements
      expect(find.text('Magic Show'), findsOneWidget);
      expect(find.text('City Hall'), findsOneWidget);

      // Verify image is rendered
      expect(find.byType(Image), findsOneWidget);

      // Verify the WishlistButton is present
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });
  });
}
