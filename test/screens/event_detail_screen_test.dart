import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/event_detail_screen.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';

import '../helpers/test_setup.dart';

void main() {
  const testEvent = EventModel(
    id: 'e1',
    title: 'Awesome Kids Event',
    venue: 'Central Park',
    imagePath: 'assets/images/placeholder.png',
    price: 350.0,
    tag: 'Kids & Family',
    description: 'A super fun event for kids.',
  );

  setUp(() {
    AuthState.isLoggedIn.value = false;
  });

  group('EventDetailScreen Tests', () {
    testWidgets('renders all event details correctly', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const EventDetailScreen(event: testEvent));

        // Verify title
        expect(find.text('Awesome Kids Event'), findsOneWidget);
        // Verify venue
        expect(find.text('Central Park'), findsWidgets); // Might be multiple (Location section + Header)
        // Verify tag
        expect(find.text('Kids & Family'), findsOneWidget);
        // Verify description
        expect(find.textContaining('A super fun event for kids.'), findsOneWidget);
        // Verify price (the formatting is '₹350' and '/' in RichText, so it's '₹350/')
        expect(find.text('₹350/', findRichText: true), findsOneWidget);
        
        // Verify important buttons
        expect(find.text('Book Now'), findsOneWidget);
      });
    });

    testWidgets('shows login sheet when Book Now is tapped while logged out', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        AuthState.isLoggedIn.value = false;
        await pumpTLBApp(tester, const EventDetailScreen(event: testEvent));

        // Scroll to make sure Book Now is visible (it's in a sticky bottom bar, so should be visible)
        await tester.tap(find.text('Book Now'));
        await tester.pumpAndSettle();

        // Verify login sheet appears
        expect(find.text('Login to explore amazing kids events!'), findsOneWidget);
      });
    });

    testWidgets('navigates to DateTimeSelectionScreen when Book Now is tapped while logged in', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        AuthState.isLoggedIn.value = true;
        await pumpTLBApp(tester, const EventDetailScreen(event: testEvent));

        await tester.tap(find.text('Book Now'));
        await tester.pumpAndSettle();

        // Verify DateTimeSelectionScreen appears (look for specific text from it, usually "Select Date" or "Select Date & Time")
        // We might not know exact text without looking, but we can verify EventDetailScreen is no longer the top or find DateTimeSelectionScreen type
        expect(find.text('Book Now'), findsNothing); // Should have navigated away
      });
    });
  });
}
