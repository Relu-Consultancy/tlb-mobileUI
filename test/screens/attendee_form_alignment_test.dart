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

      // "+91" is a floating badge now (see TC_S_TB_ALIGN5), not part of this
      // row, so it is no longer one of the three columns being compared here.
      final lefts = ['Attendee name', 'Select age']
          .map((t) => tester.getRect(find.text(t).first).left)
          .toList();
      expect(lefts[1], lefts[0], reason: 'age row off the name placeholder');
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

    // A "+91" shown inline before the number unavoidably eats into the
    // field's own leading width — there is no size for it small enough to
    // stay legible and still let the digits start where the name field's
    // text does. Floating it above the border instead (see IndianDialBadge)
    // is what makes an actually-typed number line up with the name, not just
    // the empty placeholders.
    testWidgets('TC_S_TB_ALIGN5 — a typed phone number lines up with the name',
        (tester) async {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpTLBApp(tester, TicketBookingScreen(event: _event()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const ValueKey('parentPhoneField')), '8778974651');
      await tester.pump();

      final nameLeft = tester.getRect(find.text('Attendee name')).left;
      final digitsLeft = tester.getRect(find.text('8778974651')).left;
      expect(digitsLeft, nameLeft);
    });

    testWidgets('TC_S_TB_ALIGN6 — the +91 badge still shows, above the field',
        (tester) async {
      await pumpTLBApp(tester, TicketBookingScreen(event: _event()));
      await tester.pumpAndSettle();

      final badgeBottom = tester.getRect(find.text('+91')).bottom;
      final fieldTop =
          tester.getRect(find.byKey(const ValueKey('parentPhoneField'))).top;
      expect(badgeBottom, lessThanOrEqualTo(fieldTop + 10));
    });
  });
}
