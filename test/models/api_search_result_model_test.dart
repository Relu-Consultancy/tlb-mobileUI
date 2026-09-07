import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_search_result_model.dart';
import 'package:tlb_mobile_ui/providers/listing_taxonomy_state.dart';

/// A live row from `GET /listings/search/?q=robtics`. Note what it does NOT
/// carry: the endpoint is documented to return average_rating, total_reviews
/// and rating_breakdown, but no live row has them today — so the model must
/// parse cleanly without them.
const _liveRow = '''
{
  "id": "2b7e1a23-5d04-496a-b5f1-ec6b2bcdd122",
  "listing_type": "program",
  "title": "Future Coders & Robotics Program",
  "short_description": "A hands-on program introducing children to coding.",
  "published_at": "2026-09-03T10:57:08.705519Z",
  "category": {"id": 12, "name": "Future Tech & AI"},
  "city": "Mumbai",
  "cover_url": "http://tlb-api.reluconsultancy.in/media/hotpic2.png",
  "partner_name": "The Grand Maze"
}
''';

Map<String, dynamic> _json(String raw) =>
    jsonDecode(raw) as Map<String, dynamic>;

void main() {
  group('ApiSearchResult.fromJson', () {
    test('TC_M_SR_001 — parses a live row that omits the rating fields', () {
      final r = ApiSearchResult.fromJson(_json(_liveRow))!;

      expect(r.id, '2b7e1a23-5d04-496a-b5f1-ec6b2bcdd122');
      expect(r.listingType, ListingKind.program);
      expect(r.title, 'Future Coders & Robotics Program');
      expect(r.category?.name, 'Future Tech & AI');
      expect(r.city, 'Mumbai');
      expect(r.partnerName, 'The Grand Maze');
      expect(r.averageRating, isNull);
      expect(r.totalReviews, isNull);
    });

    test('TC_M_SR_002 — reads the rating fields when they are sent', () {
      final json = _json(_liveRow)
        ..['average_rating'] = 4.5
        ..['total_reviews'] = 12;
      final r = ApiSearchResult.fromJson(json)!;

      expect(r.averageRating, 4.5);
      expect(r.totalReviews, 12);
    });

    test('TC_M_SR_003 — maps every listing_type onto its detail screen kind',
        () {
      expect(ApiSearchResult.kindFrom('event'), ListingKind.event);
      expect(ApiSearchResult.kindFrom('class'), ListingKind.klass);
      expect(ApiSearchResult.kindFrom('program'), ListingKind.program);
      expect(ApiSearchResult.kindFrom('venue'), ListingKind.venue);
    });

    test('TC_M_SR_004 — the wire names round-trip', () {
      for (final kind in ListingKind.values) {
        expect(ApiSearchResult.kindFrom(ApiSearchResult.wireName(kind)), kind);
      }
    });

    test('TC_M_SR_005 — drops a row with no routable listing_type', () {
      // There is no detail screen for an unknown type, so the row would
      // render as an untappable card.
      final json = _json(_liveRow)..['listing_type'] = 'workshop';
      expect(ApiSearchResult.fromJson(json), isNull);
      expect(ApiSearchResult.fromJson(_json(_liveRow)..remove('listing_type')),
          isNull);
    });

    test('TC_M_SR_006 — a null category and cover come back as null', () {
      final json = _json(_liveRow)
        ..['category'] = null
        ..['cover_url'] = null;
      final r = ApiSearchResult.fromJson(json)!;

      expect(r.category, isNull);
      expect(r.coverUrl, isNull);
    });

    test('TC_M_SR_007 — an empty string is treated as absent, not as text',
        () {
      final json = _json(_liveRow)
        ..['cover_url'] = ''
        ..['city'] = '';
      final r = ApiSearchResult.fromJson(json)!;

      expect(r.coverUrl, isNull);
      expect(r.city, isNull);
    });
  });

  group('ApiSearchPage.fromJson', () {
    test('TC_M_SP_001 — parses the pagination envelope', () {
      final page = ApiSearchPage.fromJson(_json('''
        {"count": 1, "page": 1, "page_size": 3, "next": null,
         "previous": null, "results": [$_liveRow]}
      '''));

      expect(page.count, 1);
      expect(page.page, 1);
      expect(page.pageSize, 3);
      expect(page.next, isNull);
      expect(page.results, hasLength(1));
    });

    test('TC_M_SP_002 — an unroutable row is skipped, the rest survive', () {
      final bad = _json(_liveRow)..['listing_type'] = 'workshop';
      final page = ApiSearchPage.fromJson({
        'count': 2,
        'results': [bad, _json(_liveRow)],
      });

      expect(page.results, hasLength(1));
      expect(page.results.single.listingType, ListingKind.program);
    });

    test('TC_M_SP_003 — an empty result set is not an error', () {
      final page = ApiSearchPage.fromJson(_json(
          '{"count": 0, "page": 1, "page_size": 20, "results": []}'));

      expect(page.count, 0);
      expect(page.results, isEmpty);
    });
  });
}
