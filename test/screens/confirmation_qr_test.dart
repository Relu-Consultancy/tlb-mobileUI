import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/core/qr_payload.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/booking_confirmed_screen.dart';
import 'package:tlb_mobile_ui/screens/program_booking_confirmed_screen.dart';
import 'package:tlb_mobile_ui/screens/venue_booking_confirmed_screen.dart';
import 'package:tlb_mobile_ui/widgets/booking_qr.dart';

import '../helpers/test_setup.dart';

const _event = EventModel(
  id: 'a379ee9f',
  title: 'Monsoon Special Art Festival',
  venue: 'Powai, Mumbai',
  imagePath: 'assets/images/placeholder.png',
  price: 500,
);

const _apiBookingId = 'a379ee9f-f44b-450e-b714-8f1e5c66b533';

void main() {
  group('Check-in QR reaches every booking type', () {
    testWidgets('TC_S_CQR_001 — events confirmation renders a QR',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const BookingConfirmedScreen(
            event: _event,
            selectedDate: 'Sun 23 Aug',
            selectedTime: 'Open all day',
            bookingReference: 'TLB-EV-20260820-2JF9',
            bookingId: _apiBookingId,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BookingQr), findsOneWidget);
        expect(find.text('Scan QR Code'), findsOneWidget);
      });
    });

    // Programs and classes share this screen and had no QR at all before.
    for (final type in ['program', 'class']) {
      testWidgets('TC_S_CQR_002_$type — $type confirmation renders a QR',
          (tester) async {
        await mockNetworkImages(() async {
          await pumpTLBApp(
            tester,
            ProgramBookingConfirmedScreen(
              event: _event,
              selectedDate: 'Sun 23 Aug',
              selectedTime: '10:00 AM',
              bookingReference: 'TLB-PR-20260820-1AB2',
              bookingType: type,
              bookingId: _apiBookingId,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(BookingQr), findsOneWidget);
          expect(find.text('Scan QR Code'), findsOneWidget);
        });
      });
    }

    testWidgets('TC_S_CQR_005 — venue confirmation renders a QR',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const VenueBookingConfirmedScreen(
            event: _event,
            selectedDate: 'Sun 23 Aug',
            selectedTime: '10:00 AM',
            bookingReference: 'TLB-VN-20260820-9XY1',
            bookingId: _apiBookingId,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BookingQr), findsOneWidget);
        expect(find.text('Scan QR Code'), findsOneWidget);
      });
    });

    testWidgets('TC_S_CQR_003 — no QR card when there is no booking id',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const ProgramBookingConfirmedScreen(
            event: _event,
            selectedDate: 'Sun 23 Aug',
            selectedTime: '10:00 AM',
            bookingReference: 'TLB-PR-20260820-1AB2',
            bookingType: 'program',
          ),
        );
        await tester.pumpAndSettle();

        // Nothing to fetch against, so the card hides rather than showing an
        // empty frame.
        expect(find.byType(BookingQr), findsNothing);
        expect(find.text('Scan QR Code'), findsNothing);
      });
    });
  });

  group('PDF ticket', () {
    // The PDF builder reads the QR through the same extractor as the screens,
    // so a key change can't fix one and miss the other.
    test('TC_S_CQR_004 — PDF and screen resolve the QR identically', () {
      final payload = <String, dynamic>{
        'booking_reference': 'TLB-EV-20260820-2JF9',
        'qr_code_b64':
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
      };

      final raw = QrPayload.extract(payload);
      expect(raw, isNotNull);

      final bytes = QrPayload.decode(raw);
      expect(bytes, isNotNull);
      expect(bytes!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    });
  });
}
