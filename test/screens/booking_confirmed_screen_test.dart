import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/booking_confirmed_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  const testEvent = EventModel(
    id: 'e1',
    title: 'Awesome Kids Event',
    venue: 'Central Park',
    imagePath: 'assets/images/placeholder.png',
    price: 360.0,
  );

  group('BookingConfirmedScreen Tests', () {
    testWidgets('renders teaser initially, reveals ticket on tap', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const BookingConfirmedScreen(
            event: testEvent,
            selectedDate: 'Sat, 21 Mar',
            selectedTime: '3:00 PM',
          ),
        );

        // Wait for animations to settle
        await tester.pumpAndSettle();

        // 1. Initial State
        // The teaser should be visible, so "Booking Confirmed!" shouldn't be immediately tappable/visible
        // Invoke onTap directly to bypass any hit test issues
        final gestureDetector = tester.widget<GestureDetector>(find.byType(GestureDetector).first);
        gestureDetector.onTap!();
        
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 900)); // The animation is 800ms
        await tester.pumpAndSettle();

        // 2. Revealed State
        // The ticket details should now be visible
        expect(find.text('Booking Confirmed!'), findsOneWidget);
        expect(find.text('Awesome Kids Event'), findsOneWidget);
        expect(find.text('Sat, 21 Mar'), findsOneWidget);
        expect(find.text('3:00 PM'), findsOneWidget);
        
        // The Booking ID should be visible
        expect(find.textContaining('Booking ID:'), findsOneWidget);
      });
    });
  });
}
