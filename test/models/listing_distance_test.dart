import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_class_model.dart';
import 'package:tlb_mobile_ui/models/api_event_model.dart';
import 'package:tlb_mobile_ui/models/api_search_result_model.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';

/// The card's "X km away" used to be fabricated from the listing's own id —
/// stable per listing, but unrelated to where the user was, and identical for
/// two users on opposite sides of the country. It now reports only what the
/// API measured (`distance_km`, computed from the coordinates the request
/// carried and the listing's stored coordinates), and shows nothing at all
/// when there is no measurement.
Map<String, dynamic> _json(String raw) =>
    jsonDecode(raw) as Map<String, dynamic>;

void main() {
  group('EventModel.distanceDisplay', () {
    test('TC_M_DIST_001 — reports the measured distance to one decimal', () {
      const e = EventModel(
          title: 'X', venue: 'Y', imagePath: '', distanceKm: 2.34);
      expect(e.distanceDisplay, '2.3 km away');
    });

    test('TC_M_DIST_002 — no measurement means no claim', () {
      const e = EventModel(title: 'X', venue: 'Y', imagePath: '');
      expect(e.distanceKm, isNull);
      expect(e.distanceDisplay, isNull);
    });

    test('TC_M_DIST_003 — is no longer derived from the listing identity', () {
      // Two different listings, neither measured, must both say nothing —
      // the old code gave each a different fabricated figure.
      const a = EventModel(id: 'a', title: 'A', venue: 'V', imagePath: '');
      const b = EventModel(id: 'b', title: 'B', venue: 'W', imagePath: '');
      expect(a.distanceDisplay, isNull);
      expect(b.distanceDisplay, isNull);
    });

    test('TC_M_DIST_004 — the same listing reads differently from two places',
        () {
      // Which is the whole point: distance is a property of the user's
      // position, not of the listing.
      const near = EventModel(
          id: 'a', title: 'A', venue: 'V', imagePath: '', distanceKm: 0.4);
      const far = EventModel(
          id: 'a', title: 'A', venue: 'V', imagePath: '', distanceKm: 812.6);
      expect(near.distanceDisplay, '0.4 km away');
      expect(far.distanceDisplay, '812.6 km away');
    });

    test('TC_M_DIST_005 — a nonsense negative distance is not shown', () {
      const e = EventModel(
          title: 'X', venue: 'Y', imagePath: '', distanceKm: -1);
      expect(e.distanceDisplay, isNull);
    });
  });

  group('distance_km parsing', () {
    test('TC_M_DIST_006 — an event row carries it', () {
      final e = ApiEvent.fromJson(_json('''
        {"id":"1","title":"T","category":{"id":1,"name":"C","slug":"c"},
         "city":"Mumbai","distance_km":2.34}
      '''));
      expect(e.distanceKm, 2.34);
    });

    test('TC_M_DIST_007 — a class row carries it', () {
      final c = ApiClass.fromJson(_json('''
        {"id":"1","title":"T","status":"published","is_live":true,
         "category":{"id":1,"name":"C","slug":"c"},"distance_km":1.5}
      '''));
      expect(c.distanceKm, 1.5);
    });

    test('TC_M_DIST_008 — a search result carries it', () {
      final r = ApiSearchResult.fromJson(_json('''
        {"id":"1","listing_type":"event","title":"T","distance_km":4.1}
      '''))!;
      expect(r.distanceKm, 4.1);
    });

    test('TC_M_DIST_009 — absent or null parses to null, not zero', () {
      // Zero would render "0.0 km away", which reads as "you are here".
      final r = ApiSearchResult.fromJson(
          _json('{"id":"1","listing_type":"event","title":"T"}'))!;
      expect(r.distanceKm, isNull);

      final withNull = ApiSearchResult.fromJson(_json(
          '{"id":"1","listing_type":"event","title":"T","distance_km":null}'))!;
      expect(withNull.distanceKm, isNull);
    });
  });
}
