import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/qr_payload.dart';

/// The real QR from a live `/bookings/{id}/ticket/data/` response
/// (booking TLB-EV-20260820-2JF9) — a 520x520 1-bit PNG. Truncated here to the
/// PNG header, which is all that's needed to prove the field is found and the
/// payload decodes to an image.
const _realQrHead =
    'iVBORw0KGgoAAAANSUhEUgAAAggAAAIIAQAAAAAjhyvOAAAFp0lEQVR4nO1d0W4bMQwjh/z/L3MPImVnb8NczDDUFknvkhAn2LEkivJR';

Map<String, dynamic> _liveShape({String key = 'qr_code_b64'}) => {
      'booking_reference': 'TLB-EV-20260820-2JF9',
      'show_name': 'Monsoon Special Art Festival',
      'booking_type': 'Event',
      'payment_status': 'Paid',
      key: _realQrHead,
    };

void main() {
  group('QrPayload.extract', () {
    // The bug: the app read `qr_code`; the API sends `qr_code_b64`. Both the
    // on-screen ticket and the downloaded PDF rendered no QR because of it.
    test('TC_C_QR_001 — finds the API\'s real field, qr_code_b64', () {
      expect(QrPayload.extract(_liveShape()), _realQrHead);
    });

    test('TC_C_QR_002 — qr_code_b64 is tried before the old guess', () {
      expect(QrPayload.keys.first, 'qr_code_b64');
      expect(QrPayload.keys.indexOf('qr_code_b64'),
          lessThan(QrPayload.keys.indexOf('qr_code')));
    });

    test('TC_C_QR_003 — still accepts the other plausible names', () {
      for (final k in QrPayload.keys) {
        expect(QrPayload.extract(_liveShape(key: k)), _realQrHead,
            reason: 'should find the QR under "$k"');
      }
    });

    test('TC_C_QR_004 — looks inside a nested ticket object', () {
      final nested = {
        'booking_reference': 'TLB-EV-1',
        'ticket': {'qr_code_b64': _realQrHead},
      };
      expect(QrPayload.extract(nested), _realQrHead);
    });

    test('TC_C_QR_005 — null when the payload carries no QR', () {
      expect(
        QrPayload.extract({'booking_reference': 'TLB-EV-1', 'city': 'Mumbai'}),
        isNull,
      );
    });

    test('TC_C_QR_006 — ignores a present-but-blank field', () {
      expect(QrPayload.extract({'qr_code_b64': '   '}), isNull);
    });
  });

  group('QrPayload.decode', () {
    test('TC_C_QR_007 — decodes the live payload to a PNG', () {
      final bytes = QrPayload.decode(_realQrHead);
      expect(bytes, isNotNull);
      // PNG magic number — the payload really is an image.
      expect(bytes!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    });

    test('TC_C_QR_008 — strips a data URI prefix', () {
      expect(
        QrPayload.decode('data:image/png;base64,$_realQrHead'),
        QrPayload.decode(_realQrHead),
      );
    });

    test('TC_C_QR_009 — a URL is not treated as base64', () {
      const url = 'https://example.com/qr.png';
      expect(QrPayload.isUrl(url), isTrue);
      expect(QrPayload.decode(url), isNull);
    });

    test('TC_C_QR_010 — undecodable input yields null, not a crash', () {
      expect(QrPayload.decode('not base64 !!!'), isNull);
      expect(QrPayload.decode(''), isNull);
      expect(QrPayload.decode(null), isNull);
    });
  });
}
