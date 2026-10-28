import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/homepage_section_model.dart';

/// The section feeds gained age_group, languages, format, mode, schedule,
/// latitude/longitude and distance_km on 9 Sep 2026. Fixtures are the live
/// rows from /homepage/sections/ on 16 Sep 2026, trimmed to what matters.
HomepageListing _row(String raw) =>
    HomepageListing.fromJson(jsonDecode(raw) as Map<String, dynamic>);

const _base = '"short_description": "", "is_tlb_signature": false, '
    '"city": "Mumbai", "category": {"id": 1, "name": "X"}';

void main() {
  group('age_group', () {
    test('TC_M_SEC_001 — every listing type reads the one object', () {
      for (final type in ['event', 'class', 'program', 'venue']) {
        final card = _row('{"id": "1", "title": "T", "listing_type": "$type", '
                '$_base, "age_group": {"type": null, "min_age": 8, "max_age": 20}}')
            .toEventModel();
        expect(card.ageGroupDisplay, '8–20 years', reason: type);
      }
    });

    test('TC_M_SEC_002 — a null age_group is a real state: no row', () {
      final card = _row('{"id": "1", "title": "T", "listing_type": "event", '
              '$_base, "age_group": null}')
          .toEventModel();
      expect(card.ageGroupDisplay, isNull);
    });
  });

  group('schedule', () {
    test('TC_M_SEC_003 — a class reads its batch, short day names', () {
      final card = _row('{"id": "1", "title": "Junior Swimming", '
              '"listing_type": "class", $_base, "start_datetime": null, '
              '"schedule": {"days": ["mon","tue","wed","thu","fri","sat","sun"], '
              '"start_time": "16:00:00", "end_time": "18:00:00"}}')
          .toEventModel();
      expect(card.dateTimeDisplay, 'Daily · 4–6 PM');
    });

    test('TC_M_SEC_004 — a venue reads its next slot', () {
      final card = _row('{"id": "1", "title": "Adventure Zone Arena", '
              '"listing_type": "venue", $_base, "start_datetime": null, '
              '"schedule": {"date": "2026-09-15", '
              '"start_time": "00:00:00", "end_time": "23:59:00"}}')
          .toEventModel();
      expect(card.dateTimeDisplay, 'Tue, 15 Sep 2026 · All day');
    });

    test('TC_M_SEC_005 — a program shows its batch, not a past start date', () {
      // start_datetime is the first batch's start (5 Sep), already past for
      // a running program. The card must read the active batch instead.
      final card = _row('{"id": "1", "title": "Future Coders", '
              '"listing_type": "program", $_base, '
              '"start_datetime": "2026-09-05T17:00:00Z", '
              '"schedule": {"days": ["monday","tuesday","wednesday","thursday","friday"], '
              '"start_time": "17:00:00", "end_time": "20:00:00"}}')
          .toEventModel();
      expect(card.dateTimeDisplay, 'Mon–Fri · 5–8 PM');
    });

    test('TC_M_SEC_006 — an event, whose schedule is null, keeps its date', () {
      final card = _row('{"id": "1", "title": "Summer Arts Festival", '
              '"listing_type": "event", $_base, '
              '"start_datetime": "2026-09-04T18:30:00Z", "schedule": null}')
          .toEventModel();
      expect(card.dateTimeDisplay, isNotNull);
      expect(card.dateTimeDisplay, contains('2026'));
    });
  });

  group('geo', () {
    test('TC_M_SEC_007 — distance_km reaches the card', () {
      final card = _row('{"id": "1", "title": "T", "listing_type": "event", '
              '$_base, "latitude": 19.117091, "longitude": 72.905261, '
              '"distance_km": 0.2909453873845012}')
          .toEventModel();
      expect(card.distanceDisplay, '0.3 km away');
    });

    test('TC_M_SEC_008 — a venue gets a distance without its coordinates', () {
      final row = _row('{"id": "1", "title": "T", "listing_type": "venue", '
          '$_base, "latitude": null, "longitude": null, '
          '"distance_km": 0.10310323022896811}');
      expect(row.latitude, isNull);
      expect(row.toEventModel().distanceDisplay, '0.1 km away');
    });

    test('TC_M_SEC_009 — decimals sent as strings still parse', () {
      final row = _row('{"id": "1", "title": "T", "listing_type": "event", '
          '$_base, "latitude": "19.117091", "longitude": "72.905261", '
          '"distance_km": "2.34"}');
      expect(row.latitude, closeTo(19.117091, 1e-9));
      expect(row.toEventModel().distanceDisplay, '2.3 km away');
    });

    test('TC_M_SEC_010 — without lat/lng the card claims no distance', () {
      final card = _row('{"id": "1", "title": "T", "listing_type": "event", '
              '$_base, "distance_km": null}')
          .toEventModel();
      expect(card.distanceDisplay, isNull);
    });
  });

  test('TC_M_SEC_011 — format and mode normalise across types', () {
    final program = _row('{"id": "1", "title": "T", "listing_type": "program", '
        '$_base, "format": "short_term", "mode": "offline"}');
    expect(program.format, 'short_term');
    expect(program.mode, 'offline');
    final venue = _row('{"id": "1", "title": "T", "listing_type": "venue", '
        '$_base, "format": null, "mode": null}');
    expect(venue.format, isNull);
    expect(venue.mode, isNull);
  });
}
