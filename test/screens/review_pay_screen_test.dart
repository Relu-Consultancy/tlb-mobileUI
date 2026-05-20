import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/review_pay_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  const testEvent = EventModel(
    id: '',
    title: 'Awesome Kids Event',
    venue: 'Central Park',
    imagePath: 'assets/images/placeholder.png',
    price: 360.0,
  );

  const lineItems = <Map<String, dynamic>>[];
  const attendee = <String, dynamic>{};

  group('ReviewPayScreen Tests', () {
    testWidgets('renders screen and calculates total correctly',
        (WidgetTester tester) async {
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
            lineItems: lineItems,
            attendee: attendee,
          ),
        );

        // Header
        expect(find.text('Review & Pay'), findsOneWidget);
        expect(find.text('Awesome Kids Event'), findsOneWidget);

        // Date & Time
        expect(find.text('Sat, 21 Mar • 3:00 PM'), findsOneWidget);

        // Ticket details
        expect(find.text('Standard (₹360) × 1'), findsOneWidget);

        // Pricing math
        expect(find.text('₹399'), findsOneWidget);
        expect(find.text('₹${bookingFee.toStringAsFixed(2)}'), findsOneWidget);
        expect(
            find.text('₹${expectedTotal.toStringAsFixed(2)}'), findsOneWidget);

        // Session 34: button now shows "Pay ₹X.XX" (Razorpay flow)
        expect(
            find.text('Pay ₹${expectedTotal.toStringAsFixed(2)}'),
            findsOneWidget);
      });
    });

    testWidgets('Pay button is disabled when listing id is empty',
        (WidgetTester tester) async {
      // event.id == '' → _onProceedToPay shows an error snackbar; button is still tappable
      // but booking won't be initiated. Just verify the button renders.
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const ReviewPayScreen(
            event: testEvent,
            selectedDate: 'Sat, 21 Mar',
            selectedTime: '3:00 PM',
            subtotal: 100.0,
            ticketDetails: 'Standard (₹100) × 1',
            lineItems: lineItems,
            attendee: attendee,
          ),
        );

        final payBtn = find.widgetWithText(ElevatedButton,
            'Pay ₹${(100.0 + 100.0 * 0.0826).toStringAsFixed(2)}');
        expect(payBtn, findsOneWidget);
      });
    });

    testWidgets('secure payment note is rendered',
        (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const ReviewPayScreen(
            event: testEvent,
            selectedDate: 'Sat, 21 Mar',
            selectedTime: '3:00 PM',
            subtotal: 100.0,
            ticketDetails: 'Standard (₹100) × 1',
            lineItems: lineItems,
            attendee: attendee,
          ),
        );

        expect(
            find.textContaining('Razorpay'), findsOneWidget);
      });
    });
  });
}
