import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Pulls the ticket QR out of a `/bookings/{id}/ticket/data/` payload.
///
/// The API sends it as a base64 PNG under **`qr_code_b64`**. That name is
/// confirmed against a live response — the endpoint publishes no schema, and
/// its prose only says "QR code as a base64 PNG string" without naming the
/// field, so both the on-screen ticket and the PDF had guessed `qr_code` and
/// silently rendered nothing.
///
/// Shared by the ticket widget and the PDF builder so the two can't drift onto
/// different keys again.
class QrPayload {
  const QrPayload._();

  /// Candidate field names, most-confirmed first. Extras are cheap insurance
  /// against a rename, which otherwise fails silently as an empty box.
  static const List<String> keys = <String>[
    'qr_code_b64',
    'qr_code',
    'qr_code_base64',
    'qr_base64',
    'qr_code_url',
    'qr_image',
    'qr_url',
    'qr',
  ];

  /// The first non-empty QR value on the payload — top level first, then a
  /// nested `ticket` / `data` object. Returns null when there is none, so the
  /// caller can say so rather than showing a blank frame.
  static String? extract(Map<String, dynamic> data) {
    String? pick(Map source) {
      for (final k in keys) {
        final v = source[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return null;
    }

    final direct = pick(data);
    if (direct != null) return direct;

    for (final key in const ['ticket', 'data', 'qr']) {
      final nested = data[key];
      if (nested is Map) {
        final found = pick(nested);
        if (found != null) return found;
      }
    }
    return null;
  }

  /// True when the value is a link to fetch rather than an inline payload.
  static bool isUrl(String raw) =>
      raw.startsWith('http://') || raw.startsWith('https://');

  /// Decodes a base64 QR. Accepts a bare payload and a
  /// `data:image/png;base64,…` URI. Returns null if it isn't decodable.
  static Uint8List? decode(String? raw) {
    if (raw == null || raw.isEmpty || isUrl(raw)) return null;
    try {
      final cleaned =
          raw.contains(',') ? raw.substring(raw.indexOf(',') + 1) : raw;
      final bytes = base64Decode(cleaned);
      return bytes.isEmpty ? null : bytes;
    } catch (e) {
      debugPrint('QR decode failed: $e');
      return null;
    }
  }
}
