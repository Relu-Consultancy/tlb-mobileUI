import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/listing_languages.dart';

void main() {
  group('ListingLanguages Tests', () {
    test('TC_C_LL_001 — reads the API shape the partner form produces', () {
      final json = {
        'id': '1b98e204',
        'title': 'Summer Arts Festival',
        'languages': ['english', 'hindi'],
        'other_language': '',
      };
      expect(ListingLanguages.parse(json), ['english', 'hindi']);
      // The API sends "" rather than null for an unused Other box.
      expect(ListingLanguages.parseOther(json), isNull);
      expect(
        ListingLanguages.label(
            ListingLanguages.parse(json), ListingLanguages.parseOther(json)),
        'English, Hindi',
      );
    });

    test('TC_C_LL_002 — finds the fields nested, as classes carry them', () {
      // A class keeps its listing attributes under `service`.
      final json = {
        'id': 'x',
        'service': {
          'languages': ['marathi'],
          'other_language': 'Konkani',
        },
      };
      final nested = json['service'] as Map<String, dynamic>;
      expect(ListingLanguages.parse(json, nested: nested), ['marathi']);
      expect(ListingLanguages.parseOther(json, nested: nested), 'Konkani');
    });

    test('TC_C_LL_003 — appends the Other language to the picked ones', () {
      expect(ListingLanguages.label(['english'], 'Tulu'), 'English, Tulu');
    });

    test('TC_C_LL_004 — no language at all yields null, not an empty row', () {
      expect(ListingLanguages.label(const [], null), isNull);
      expect(ListingLanguages.label(const [], '   '), isNull);
      expect(ListingLanguages.parse(null), isEmpty);
      expect(ListingLanguages.parse({'languages': null}), isEmpty);
      expect(ListingLanguages.parse({'languages': 'english'}), isEmpty);
    });

    test('TC_C_LL_005 — does not repeat a language typed into both boxes', () {
      expect(ListingLanguages.label(['hindi'], 'Hindi'), 'Hindi');
    });

    test('TC_C_LL_006 — tidies the slugs the API sends', () {
      expect(ListingLanguages.label(['english', 'sign_language'], null),
          'English, Sign Language');
      // Partner-typed capitals are left alone.
      expect(ListingLanguages.label(const [], 'BSL'), 'BSL');
    });

    test('TC_C_LL_007 — drops blank entries inside the list', () {
      expect(ListingLanguages.parse({
        'languages': ['english', '', '  ']
      }), ['english']);
    });
  });
}
