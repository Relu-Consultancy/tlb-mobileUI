import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_program_model.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/attendee_details_screen.dart';

import '../helpers/test_setup.dart';

ApiProgramBatch _batch({String? fee}) => ApiProgramBatch(
      id: 1,
      name: 'Batch 1',
      fee: fee,
      isActive: true,
      daysOfWeek: const ['mon'],
    );

EventModel _event({double? price}) => EventModel(
      id: 'class-1',
      title: 'Test Class',
      venue: 'Mumbai',
      imagePath: '',
      price: price,
    );

Future<void> _pump(WidgetTester tester, AttendeeDetailsScreen screen) async {
  await pumpTLBApp(tester, screen);
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

void main() {
  group('AttendeeDetailsScreen fee fallback (Session 43)', () {
    testWidgets('uses batch.fee when present', (tester) async {
      await _pump(
        tester,
        AttendeeDetailsScreen(
          event: _event(price: 1500),
          batch: _batch(fee: '500'),
          selectedDate: '1 Jan',
          selectedTime: '10:00',
          bookingType: 'class',
        ),
      );
      expect(find.text('₹500'), findsOneWidget);
    });

    testWidgets('falls back to event.price when batch.fee is null',
        (tester) async {
      await _pump(
        tester,
        AttendeeDetailsScreen(
          event: _event(price: 1500),
          batch: _batch(fee: null),
          selectedDate: '1 Jan',
          selectedTime: '10:00',
          bookingType: 'class',
        ),
      );
      // This is the Session 43 fix — was showing "Free" before.
      expect(find.text('₹1500'), findsOneWidget);
    });

    testWidgets('falls back to event.price when batch.fee is "0"',
        (tester) async {
      await _pump(
        tester,
        AttendeeDetailsScreen(
          event: _event(price: 1500),
          batch: _batch(fee: '0'),
          selectedDate: '1 Jan',
          selectedTime: '10:00',
          bookingType: 'class',
        ),
      );
      expect(find.text('₹1500'), findsOneWidget);
    });

    testWidgets('shows "Free" when both batch.fee and event.price are null',
        (tester) async {
      await _pump(
        tester,
        AttendeeDetailsScreen(
          event: _event(price: null),
          batch: _batch(fee: null),
          selectedDate: '1 Jan',
          selectedTime: '10:00',
          bookingType: 'class',
        ),
      );
      expect(find.text('Free'), findsOneWidget);
    });
  });
}
