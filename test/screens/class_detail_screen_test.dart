import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/class_detail_screen.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';

import '../helpers/test_setup.dart';

void main() {
  // id: '' → dummy mode, no API call
  final testEvent = EventModel(
    id: '',
    title: 'Test Class',
    imagePath: 'assets/images/test.png',
    venue: 'Test Venue',
    price: 500,
    tag: 'Art',
  );

  group('ClassDetailScreen Tests', () {
    testWidgets('renders event details correctly', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, ClassDetailScreen(event: testEvent));

        expect(find.text('Test Class'), findsOneWidget);
        expect(find.text('Test Venue').first, findsOneWidget);
        expect(find.text('Art'), findsOneWidget);
        // Sessions 43 + Session-32-era: with id='' (dummy mode) no API
        // detail is fetched, so booking_type is unknown → screen falls
        // through to the enquiry CTA and hides the price field.
        expect(find.text('Enquire Now'), findsOneWidget);
        expect(find.text('₹500'), findsNothing);
        expect(find.text('₹500/mo', findRichText: true), findsNothing);
      });
    });

    testWidgets('scrolls to reveal gallery section', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, ClassDetailScreen(event: testEvent));

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
        await tester.pumpAndSettle();

        // Gallery is always shown in dummy mode; Reviews are only shown when _hasApiId = true
        expect(find.text('Gallery'), findsOneWidget);
      });
    });
  });
}
