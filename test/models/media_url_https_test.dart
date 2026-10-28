import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_search_result_model.dart';
import 'package:tlb_mobile_ui/models/homepage_section_model.dart';

/// Every media URL entering the app is upgraded to https at the point it is
/// parsed, so the cards that call Image.network directly — rather than going
/// through listingImage — are covered too.
void main() {
  test('TC_M_URL_001 — a section listing\'s cover is https', () {
    final s = HomepageSection.fromJson({
      'section': 'trending_events',
      'label': 'Trending Events',
      'hero': {
        'id': 'a',
        'title': 'Summer Arts Festival',
        'listing_type': 'event',
        'cover_url': 'http://tlb-api.reluconsultancy.in/media/x.png',
      },
      'listings': [
        {
          'id': 'b',
          'title': 'Second',
          'listing_type': 'event',
          'cover_url': 'http://tlb-api.reluconsultancy.in/media/y.png',
        },
      ],
    });

    expect(s.hero!.coverUrl, startsWith('https://'));
    expect(s.listings.single.coverUrl, startsWith('https://'));
    // ...and the card the widgets actually render.
    expect(s.hero!.toEventModel().imagePath, startsWith('https://'));
  });

  test('TC_M_URL_002 — a search result\'s cover is https', () {
    final r = ApiSearchResult.fromJson({
      'id': 'a',
      'listing_type': 'event',
      'title': 'X',
      'cover_url': 'http://tlb-api.reluconsultancy.in/media/z.png',
    })!;
    expect(r.coverUrl, startsWith('https://'));
  });

  test('TC_M_URL_003 — every model that parses a media URL secures it', () {
    // A new model that forgets this reintroduces the blank-card bug, and it
    // only shows on a real Android device.
    const models = <String, List<String>>{
      'api_booking_model.dart': ['cover_url', 'listing_cover'],
      'api_class_model.dart': ['cover_url', 'logo_url'],
      'api_event_model.dart': ['cover_url', 'logo_url'],
      'api_followed_partner_model.dart': ['logo_url', 'cover_image_url'],
      'api_program_model.dart': ['logo_url'],
      'api_provider_model.dart': ['logo_url'],
      'api_review_model.dart': ['cover_url'],
      'api_search_result_model.dart': ['cover_url'],
      'homepage_section_model.dart': ['cover_url'],
    };

    models.forEach((file, fields) {
      final src = File('lib/models/$file').readAsStringSync();
      expect(src, contains("import '../core/secure_url.dart';"), reason: file);
      for (final field in fields) {
        // Every direct read of the field must sit inside a secureUrl(...)
        // call. Checked by proximity rather than a regex lookbehind, which
        // is easier to read and catches the same mistake. RegExp.escape
        // keeps the brackets literal — unescaped they are a character class,
        // which matches almost everything.
        final read = RegExp(RegExp.escape("['$field'] as String?"));
        for (final m in read.allMatches(src)) {
          final before =
              src.substring(m.start - 60 < 0 ? 0 : m.start - 60, m.start);
          expect(before, contains('secureUrl('),
              reason: '$file reads $field without secureUrl');
        }
      }
    });
  });
}
