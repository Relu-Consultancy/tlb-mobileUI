import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/homepage_section_model.dart';

/// A live section from GET /api/v1/listings/events/sections/. Two things here
/// that the model previously got wrong:
///   * `category` is an object, not a string — read as a string it stamped a
///     whole Dart map onto the card's tag chip.
///   * `hero` is a new field, and the API *removes* the hero from `listings`,
///     so anything reading only `listings` loses a curated card the moment an
///     admin flags one.
const _sectionWithHero = '''
{
  "section": "trending_events",
  "label": "Trending Events",
  "hero": {
    "id": "a1dfe226-b200-4964-8282-d6a92874e9d1",
    "title": "Summer Arts Festival",
    "short_description": "",
    "listing_type": "event",
    "is_tlb_signature": false,
    "cover_url": "http://tlb-api.reluconsultancy.in/media/x.png",
    "category": {"id": 1, "name": "Arts & Crafts"},
    "city": "Mumbai",
    "area": "Sector A",
    "price": "500.00",
    "price_type": "paid",
    "start_datetime": "2026-09-04T18:30:00Z",
    "end_datetime": "2036-09-20T06:30:00Z",
    "rating": "0.0",
    "total_reviews": 0
  },
  "listings": []
}
''';

Map<String, dynamic> _json(String raw) =>
    jsonDecode(raw) as Map<String, dynamic>;

void main() {
  group('HomepageSection.hero', () {
    test('TC_M_HS_001 — parses the hero as a full card', () {
      final s = HomepageSection.fromJson(_json(_sectionWithHero));

      expect(s.hero, isNotNull);
      expect(s.hero!.title, 'Summer Arts Festival');
      expect(s.hero!.category, 'Arts & Crafts');
    });

    test('TC_M_HS_002 — ordered leads with the hero, then the listings', () {
      final json = _json(_sectionWithHero);
      json['listings'] = [
        {'id': 'b', 'title': 'Second', 'listing_type': 'event'},
      ];
      final s = HomepageSection.fromJson(json);

      expect(s.ordered.map((l) => l.title), ['Summer Arts Festival', 'Second']);
    });

    test('TC_M_HS_003 — no hero means ordered is just the listings', () {
      // The default for most sections today.
      final json = _json(_sectionWithHero)
        ..['hero'] = null
        ..['listings'] = [
          {'id': 'b', 'title': 'Only', 'listing_type': 'event'},
        ];
      final s = HomepageSection.fromJson(json);

      expect(s.hero, isNull);
      expect(s.ordered.map((l) => l.title), ['Only']);
    });

    test('TC_M_HS_004 — a missing hero key is not an error', () {
      final json = _json(_sectionWithHero)..remove('hero');
      expect(HomepageSection.fromJson(json).hero, isNull);
    });
  });

  group('HomepageListing card fields', () {
    HomepageListing hero() =>
        HomepageSection.fromJson(_json(_sectionWithHero)).hero!;

    test('TC_M_HL_001 — the category object becomes its name', () {
      expect(hero().toEventModel().tag, 'Arts & Crafts');
      expect(hero().toEventModel().tag, isNot(contains('{')));
    });

    test('TC_M_HL_002 — a plain-string category still works', () {
      final json = _json(_sectionWithHero);
      (json['hero'] as Map<String, dynamic>)['category'] = 'Sports';
      expect(HomepageSection.fromJson(json).hero!.category, 'Sports');
    });

    test('TC_M_HL_003 — start_datetime becomes the app\'s date and time', () {
      // The mock cards carried preformatted strings; the cards that print a
      // date drew nothing until these were filled in.
      final card = hero().toEventModel();

      expect(card.eventDate, isNotNull);
      expect(card.eventTime, isNotNull);
      // The one app-wide date shape, and a 12-hour clock.
      expect(RegExp(r'^\w{3}, \d{1,2} \w{3} \d{4}$').hasMatch(card.eventDate!),
          isTrue, reason: card.eventDate);
      expect(card.eventTime, anyOf(contains('AM'), contains('PM')));
    });

    test('TC_M_HL_004 — no start_datetime leaves both null, not blank text',
        () {
      final json = _json(_sectionWithHero);
      (json['hero'] as Map<String, dynamic>)['start_datetime'] = null;
      final card = HomepageSection.fromJson(json).hero!.toEventModel();

      expect(card.eventDate, isNull);
      expect(card.eventTime, isNull);
    });

    test('TC_M_HL_005 — area and city make the venue line', () {
      expect(hero().toEventModel().venue, 'Sector A, Mumbai');
    });
  });
}
