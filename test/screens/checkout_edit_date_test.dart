import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/models/api_event_model.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/date_time_selection_screen.dart';
import 'package:tlb_mobile_ui/screens/ticket_booking_screen.dart';

import '../helpers/test_setup.dart';

const _testEvent = EventModel(
  id: 'e1',
  title: 'Monsoon Special Art Festival',
  venue: 'Mumbai',
  imagePath: 'assets/images/placeholder.png',
  price: 500.0,
);

final _start = DateTime.utc(2026, 8, 20, 23, 0);
final _end = DateTime.utc(2026, 9, 21, 10, 33);

const _tickets = [
  ApiEventTicket(
    id: 1,
    name: 'General Admission',
    price: 500,
    totalQuantity: 100,
    availableQuantity: 96,
    isDefault: true,
  ),
];

void main() {
  group('Checkout pencil "Edit" reopens the real date/time screen', () {
    // The bug: tapping the pencil on Checkout called
    // DateTimeSelectionScreen(event: event) with nothing else, which falls
    // back to that screen's dummy-data path — 6 fake days from today with
    // placeholder hourly slots — instead of the real, already-fetched event
    // window the customer had just picked a date from.
    testWidgets(
        'carries the real event window and tickets through to DateTimeSelectionScreen',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          TicketBookingScreen(
            event: _testEvent,
            selectedDate: 'Fri, 21 Aug',
            selectedTime: 'Open all day',
            apiTickets: _tickets,
            eventDateTime: _start,
            eventEndDateTime: _end,
          ),
        );

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        final reopened =
            tester.widget<DateTimeSelectionScreen>(find.byType(DateTimeSelectionScreen));
        expect(reopened.eventDateTime, _start);
        expect(reopened.eventEndDateTime, _end);
        expect(reopened.apiTickets, _tickets);
      });
    });

    testWidgets('without a real window, still falls back gracefully (no crash)',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const TicketBookingScreen(
            event: _testEvent,
            selectedDate: 'Fri, 21 Aug',
            selectedTime: 'Open all day',
          ),
        );

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        final reopened =
            tester.widget<DateTimeSelectionScreen>(find.byType(DateTimeSelectionScreen));
        expect(reopened.eventDateTime, isNull);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
