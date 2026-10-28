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
    // The ticket used to sit behind a "Click Here" card that had to be tapped
    // and flipped through first. That step is gone, matching the venue and
    // program confirmations, so the ticket is the first thing shown.
    testWidgets('shows the ticket immediately, with no reveal step',
        (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const BookingConfirmedScreen(
            event: testEvent,
            selectedDate: 'Sat, 21 Mar',
            selectedTime: '3:00 PM',
          ),
        );
        await tester.pumpAndSettle();

        // No tap, no waiting out an animation — the details are already here.
        expect(find.text('Booking Confirmed!'), findsOneWidget);
        expect(find.text('Awesome Kids Event'), findsOneWidget);
        expect(find.text('Sat, 21 Mar'), findsOneWidget);
        expect(find.text('3:00 PM'), findsOneWidget);
        expect(find.textContaining('Booking ID:'), findsOneWidget);
      });
    });
  });
}
