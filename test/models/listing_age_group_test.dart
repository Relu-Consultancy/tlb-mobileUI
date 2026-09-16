import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_event_model.dart';
import 'package:tlb_mobile_ui/models/api_program_model.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/models/homepage_section_model.dart';

/// A card's "Ages 5–10" used to be picked from a hardcoded list using a hash
/// of the listing's own id. It was stable per card, so it looked real, but it
/// had nothing to do with the listing: the same venue whose detail screen read
/// "5–16 years" showed "Ages 5–10" on the home rail. The card now prints the
/// range the API stated, or omits the row entirely.
Map<String, dynamic> _json(String raw) =>
    jsonDecode(raw) as Map<String, dynamic>;

void main() {
  group('EventModel.ageGroupDisplay', () {
    test('TC_M_AGE_001 — prints the range the API stated', () {
      const e = EventModel(
          title: 'X', venue: 'Y', imagePath: '', ageGroup: '5–16 years');
      expect(e.ageGroupDisplay, '5–16 years');
    });

    test('TC_M_AGE_002 — no stated range means no claim', () {
      const e = EventModel(title: 'X', venue: 'Y', imagePath: '');
      expect(e.ageGroup, isNull);
      expect(e.ageGroupDisplay, isNull);
    });

    test('TC_M_AGE_003 — an empty range reads as no range, not a blank row',
        () {
      // ApiEvent/ApiProgram hand back '' when neither bound is set.
      const e = EventModel(
          title: 'X', venue: 'Y', imagePath: '', ageGroup: '   ');
      expect(e.ageGroupDisplay, isNull);
    });

    test('TC_M_AGE_004 — is no longer derived from the listing identity', () {
      // Two different listings, neither with a stated range, must both say
      // nothing — the old code gave each a different fabricated band.
      const a = EventModel(id: 'a', title: 'A', venue: 'V', imagePath: '');
      const b = EventModel(id: 'b', title: 'B', venue: 'W', imagePath: '');
      expect(a.ageGroupDisplay, isNull);
      expect(b.ageGroupDisplay, isNull);
    });
  });

  group('the card agrees with the detail screen', () {
    test('TC_M_AGE_005 — an event carries its API range onto the card', () {
      final api = ApiEvent.fromJson(_json('''
        {
          "id": "e1", "title": "Summer Arts Festival",
          "category": {"id": 1, "name": "Arts & Crafts"},
          "format": "workshop", "city": "Mumbai", "price_type": "paid",
          "start_datetime": "2026-09-04T18:30:00Z",
          "age_group": {"type": "custom", "min_age": 5, "max_age": 15}
        }'''));
      expect(api.ageGroup?.displayRange, '5–15 years');
    });

    test('TC_M_AGE_006 — a program carries its API range onto the card', () {
      final api = ApiProgram.fromJson(_json('''
        {
          "id": "p1", "title": "Future Coders",
          "min_age": 9, "max_age": 15
        }'''));
      expect(api.displayAgeRange, '9–15 years');
    });
  });

  group('the section feeds state no age at all', () {
    test('TC_M_AGE_007 — a section card claims no range', () {
      // The curated feeds (/homepage/sections/, /listings/{screen}/sections/)
      // return no age field on any row, for any listing type. The card must
      // drop the row rather than invent one — this is the exact case the user
      // saw: home rail said "Ages 5–10", detail screen said "5–16 years".
      final card = HomepageListing.fromJson(_json('''
        {
          "id": "069befbc", "title": "Adventure Zone Arena",
          "short_description": "", "listing_type": "venue",
          "is_tlb_signature": false, "city": "Mumbai", "area": "Sector A",
          "category": {"id": 9, "name": "Play & Adventure"}
        }''')).toEventModel();
      expect(card.ageGroupDisplay, isNull);
    });

    test('TC_M_AGE_008 — a venue on a section feed states no schedule either',
        () {
      // Same fabrication, same fix: the old getter fell back to a made-up
      // "Sat & Sun · 4–6 PM" whenever start_datetime was absent, which it
      // always is for a class or a venue on these feeds.
      final card = HomepageListing.fromJson(_json('''
        {
          "id": "069befbc", "title": "Adventure Zone Arena",
          "short_description": "", "listing_type": "venue",
          "is_tlb_signature": false, "city": "Mumbai"
        }''')).toEventModel();
      expect(card.dateTimeDisplay, isNull);
    });

    test('TC_M_AGE_009 — a dated row still prints its real schedule', () {
      final card = HomepageListing.fromJson(_json('''
        {
          "id": "a1dfe226", "title": "Summer Arts Festival",
          "short_description": "", "listing_type": "event",
          "is_tlb_signature": false, "city": "Mumbai",
          "start_datetime": "2026-09-04T18:30:00Z"
        }''')).toEventModel();
      expect(card.dateTimeDisplay, isNotNull);
      expect(card.dateTimeDisplay, contains('2026'));
    });
  });
}
