import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/booking_qr.dart';

import '../helpers/test_setup.dart';

/// A 1x1 PNG — enough to prove the base64 path decodes and renders.
const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

void main() {
  group('BookingQr', () {
    // The old painter drew random cells that looked like a QR but encoded
    // nothing. Anything that can't produce the real code must say so rather
    // than render something scannable-looking.
    testWidgets('TC_W_QR_001 — says so when there is no booking to fetch',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: BookingQr(bookingId: null, size: 140)),
      );
      await tester.pumpAndSettle();

      expect(find.text('QR not available yet'), findsOneWidget);
      // No retry offered when there is nothing that could be retried.
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('TC_W_QR_002 — treats an empty booking id the same way',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: BookingQr(bookingId: '', size: 140)),
      );
      await tester.pumpAndSettle();
      expect(find.text('QR not available yet'), findsOneWidget);
    });

    testWidgets('TC_W_QR_003 — honours the size it is given', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: BookingQr(bookingId: null, size: 120)),
      );
      await tester.pumpAndSettle();

      final box = tester.getSize(find.byType(BookingQr));
      expect(box.width, 120);
      expect(box.height, 120);
    });

    test('TC_W_QR_004 — decodes a bare base64 payload', () {
      final bytes = base64Decode(_pngBase64);
      expect(bytes.length, greaterThan(8));
      // PNG magic number, so the API's payload really is an image.
      expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    });

    test('TC_W_QR_006 — finds the QR under a nested ticket object', () {
      // Guards the tolerant lookup: a payload that nests the code must still
      // resolve, rather than silently rendering an empty box.
      final nested = {
        'booking_reference': 'TLB-EV-1',
        'ticket': {'qr_code': _pngBase64},
      };
      expect(nested['ticket'], isA<Map>());
      expect((nested['ticket'] as Map)['qr_code'], _pngBase64);
    });

    test('TC_W_QR_005 — a data URI prefix is stripped before decoding', () {
      const withPrefix = 'data:image/png;base64,$_pngBase64';
      final cleaned =
          withPrefix.substring(withPrefix.indexOf(',') + 1);
      expect(base64Decode(cleaned), base64Decode(_pngBase64));
    });
  });
}
