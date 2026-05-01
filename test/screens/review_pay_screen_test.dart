import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/review_pay_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  const testEvent = EventModel(
    id: 'e1',
    title: 'Awesome Kids Event',
    venue: 'Central Park',
    imagePath: 'assets/images/placeholder.png',
    price: 360.0,
  );

  group('ReviewPayScreen Tests', () {
    testWidgets('renders screen and calculates total correctly', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        const double subtotal = 399.0;
        final double bookingFee = subtotal * 0.0826;
        final double expectedTotal = subtotal + bookingFee;

        await pumpTLBApp(
          tester,
          const ReviewPayScreen(
            event: testEvent,
            selectedDate: 'Sat, 21 Mar',
            selectedTime: '3:00 PM',
            subtotal: subtotal,
            ticketDetails: 'Standard (₹360) × 1',
          ),
        );

        // Verify title
        expect(find.text('Review & Pay'), findsOneWidget);
        expect(find.text('Awesome Kids Event'), findsOneWidget);

        // Verify Date & Time
        expect(find.text('Sat, 21 Mar • 3:00 PM'), findsOneWidget);

        // Verify Ticket details string
        expect(find.text('Standard (₹360) × 1'), findsOneWidget);

        // Verify Pricing Math
        expect(find.text('₹399'), findsOneWidget); // Sub-total
        expect(find.text('₹${bookingFee.toStringAsFixed(2)}'), findsOneWidget); // Booking Fee
        expect(find.text('₹${expectedTotal.toStringAsFixed(2)}'), findsOneWidget); // Total Amount
        
        // Verify Proceed to Pay button exists
        expect(find.text('Proceed to Pay'), findsOneWidget);
      });
    });

    testWidgets('navigates to PaymentScreen on Proceed to Pay tap', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const ReviewPayScreen(
            event: testEvent,
            selectedDate: 'Sat, 21 Mar',
            selectedTime: '3:00 PM',
            subtotal: 100.0,
            ticketDetails: 'Standard (₹100) × 1',
          ),
        );

        await tester.tap(find.text('Proceed to Pay'));
        await tester.pumpAndSettle();

        // Screen should change to PaymentScreen.
        // We can check if 'Review & Pay' header is gone, or 'Pay' / Payment methods text appeared
        expect(find.text('Review & Pay'), findsNothing);
      });
    });
  });
}
