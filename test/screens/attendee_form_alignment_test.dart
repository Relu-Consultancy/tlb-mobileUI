import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/ticket_booking_screen.dart';

import '../helpers/test_setup.dart';

EventModel _event() => EventModel(
      id: '',
      title: 'Family Music Jam',
      venue: 'Malad, Mumbai',
      imagePath: 'assets/images/placeholder.png',
      price: 999,
    );

void main() {
  group('Attendee Details form Tests', () {
    testWidgets('TC_S_TB_ALIGN — the three placeholders share one column',
        (tester) async {
      // The reported defect: a TextField's placeholder sat right of the age
      // row and the "+91" because Material gave its prefixIcon a 48x48 box
      // and then added its own prefix gap on top.
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpTLBApp(tester, TicketBookingScreen(event: _event()));
      await tester.pumpAndSettle();

      final lefts = ['Attendee name', 'Select age', '+91']
          .map((t) => tester.getRect(find.text(t).first).left)
          .toList();
      expect(lefts[1], lefts[0], reason: 'age row off the name placeholder');
      expect(lefts[2], lefts[0], reason: 'dial code off the name placeholder');
    });

    testWidgets('TC_S_TB_ALIGN2 — the three leading icons share one column',
        (tester) async {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpTLBApp(tester, TicketBookingScreen(event: _event()));
      await tester.pumpAndSettle();

      final rects = [
        Icons.person_outline,
        Icons.cake_outlined,
        Icons.phone_outlined,
      ].map((i) => tester.getRect(find.byIcon(i).first)).toList();
      for (final r in rects.skip(1)) {
        expect(r.left, rects.first.left);
        expect(r.width, rects.first.width);
      }
    });

    testWidgets('TC_S_TB_ALIGN3 — the three fields are the same height',
        (tester) async {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpTLBApp(tester, TicketBookingScreen(event: _event()));
      await tester.pumpAndSettle();

      final name = tester.getSize(find.byKey(const ValueKey('childNameField')));
      final phone =
          tester.getSize(find.byKey(const ValueKey('parentPhoneField')));
      expect(phone.height, name.height);
      expect(name.height, 52);
    });

    testWidgets('TC_S_TB_ALIGN4 — the name field asks for an attendee',
        (tester) async {
      await pumpTLBApp(tester, TicketBookingScreen(event: _event()));
      await tester.pumpAndSettle();
      expect(find.text('Attendee name'), findsOneWidget);
      expect(find.text('Child name'), findsNothing);
    });
  });
}
