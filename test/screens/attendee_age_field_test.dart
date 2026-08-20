import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/ticket_booking_screen.dart';

import '../helpers/test_setup.dart';

const _event = EventModel(
  id: 'a379ee9f',
  title: 'Monsoon Special Art Festival',
  venue: 'Powai, Mumbai',
  imagePath: 'assets/images/placeholder.png',
  price: 500,
);

Future<void> _openForm(WidgetTester tester) async {
  await pumpTLBApp(
    tester,
    const TicketBookingScreen(
      event: _event,
      selectedDate: 'Sun 23 Aug',
      selectedTime: 'Open all day',
    ),
  );
  // The form sits well below the fold; ensureVisible works because the page
  // is a SingleChildScrollView, so every field is already built.
  await tester.ensureVisible(find.text('Attendee Details'));
  await tester.pumpAndSettle();
}

Future<void> _pickAge(WidgetTester tester, String age) async {
  await tester.ensureVisible(find.text('Select age'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Select age'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(age).last);
  await tester.pumpAndSettle();
}

void main() {
  group('Attendee age field', () {
    // The bug: DropdownButton renders `hint` only while the value is null, so
    // picking an age replaced the icon + label with a bare number — while the
    // name and phone fields keep their prefix icon at all times.
    testWidgets('TC_S_AGE_001 — keeps its icon after an age is picked',
        (tester) async {
      await _openForm(tester);

      Finder cakeIcon() => find.byIcon(Icons.cake_outlined);
      expect(cakeIcon(), findsOneWidget, reason: 'icon shows as placeholder');

      await _pickAge(tester, '7');

      expect(cakeIcon(), findsOneWidget,
          reason: 'icon must survive selection, like the fields either side');
    });

    testWidgets('TC_S_AGE_002 — labels the value so it reads as an age',
        (tester) async {
      await _openForm(tester);
      await _pickAge(tester, '7');

      expect(find.text('7 years'), findsOneWidget);
      // The bare number was the whole problem.
      expect(find.text('7'), findsNothing);
    });

    testWidgets('TC_S_AGE_003 — says "1 year", not "1 years"', (tester) async {
      await _openForm(tester);
      await _pickAge(tester, '1');
      expect(find.text('1 year'), findsOneWidget);
      expect(find.text('1 years'), findsNothing);
    });

    testWidgets('TC_S_AGE_004 — the sibling fields keep their icons too',
        (tester) async {
      await _openForm(tester);
      await _pickAge(tester, '7');

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      expect(find.byIcon(Icons.cake_outlined), findsOneWidget);
    });
  });
}
