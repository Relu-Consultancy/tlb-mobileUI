import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/venue_detail_screen.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';

import '../helpers/test_setup.dart';

void main() {
  final testEvent = EventModel(
    title: 'Test Venue Detail',
    imagePath: 'assets/images/test.png',
    venue: 'Magic Land',
    price: 350,
    tag: 'Adventure',
  );

  group('VenueDetailScreen Tests', () {
    testWidgets('renders venue details correctly', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, VenueDetailScreen(event: testEvent));

        expect(find.text('Test Venue Detail'), findsOneWidget);
        expect(find.text('Magic Land'), findsOneWidget);
        expect(find.text('Adventure'), findsOneWidget);
        expect(find.textContaining('350'), findsOneWidget);
        expect(find.text('Plan Event'), findsOneWidget);
      });
    });

    testWidgets('shows login sheet when Plan Event is tapped and not logged in', (WidgetTester tester) async {
      AuthState.isLoggedIn.value = false;
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, VenueDetailScreen(event: testEvent));

        await tester.tap(find.text('Plan Event'));
        await tester.pumpAndSettle();

        // Check for login sheet content (assuming it has "Login" text or similar)
        expect(find.text('Login'), findsWidgets);
      });
    });
  });
}
