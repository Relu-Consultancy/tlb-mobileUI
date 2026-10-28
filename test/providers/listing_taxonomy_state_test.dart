import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_category_model.dart';
import 'package:tlb_mobile_ui/providers/listing_taxonomy_state.dart';

ApiCategory _cat(
  int id,
  String name, {
  List<ApiSubcategory> subs = const [],
}) =>
    ApiCategory(
      id: id,
      slug: name.toLowerCase().replaceAll(' ', '-'),
      name: name,
      sortOrder: 0,
      subcategories: subs,
    );

ApiSubcategory _sub(int id, String name) => ApiSubcategory(
      id: id,
      slug: name.toLowerCase().replaceAll(' ', '-'),
      name: name,
    );

TaxonomyNode _byLabel(List<TaxonomyNode> nodes, String label) =>
    nodes.firstWhere((n) => n.label == label);

void main() {
  group('ListingTaxonomyState.mergeTaxonomies', () {
    // The whole point of the merge: events/classes are filtered by NAME and
    // programs/venues by ID, so one option has to carry both, per source.
    test('TC_LT_001 — a shared category keeps every source\'s name and id',
        () {
      final merged = ListingTaxonomyState.mergeTaxonomies({
        ListingKind.event: [_cat(7, 'Arts & Crafts')],
        ListingKind.klass: [_cat(31, 'Arts & Crafts')],
        ListingKind.program: [_cat(22, 'Arts & Crafts')],
        ListingKind.venue: [_cat(4, 'Arts & Crafts')],
      });

      expect(merged, hasLength(1));
      final node = merged.single;
      expect(node.label, 'Arts & Crafts');
      expect(node.names[ListingKind.event], 'Arts & Crafts');
      expect(node.ids[ListingKind.program], 22);
      expect(node.ids[ListingKind.venue], 4);
      expect(node.sources, hasLength(4));
    });

    // Two backends spelling the same category differently must not produce two
    // chips — but each must still be sent the spelling it actually matches on.
    test('TC_LT_002 — case and spacing differences merge, exact names survive',
        () {
      final merged = ListingTaxonomyState.mergeTaxonomies({
        ListingKind.event: [_cat(1, 'Performing Arts')],
        ListingKind.klass: [_cat(2, 'performing   arts')],
      });

      expect(merged, hasLength(1));
      expect(merged.single.names[ListingKind.event], 'Performing Arts');
      expect(merged.single.names[ListingKind.klass], 'performing   arts');
    });

    // The classes taxonomy holds the FULL name; a truncated display label is
    // what broke the category filter once before, so it must not leak in.
    test('TC_LT_003 — a source-specific full name is preserved verbatim', () {
      final merged = ListingTaxonomyState.mergeTaxonomies({
        ListingKind.klass: [_cat(9, 'Life Skills & Personality Development')],
      });

      expect(merged.single.names[ListingKind.klass],
          'Life Skills & Personality Development');
    });

    // A source that never offered the category must be absent, so the caller
    // can tell "no rows here" from "this source cannot express the filter".
    test('TC_LT_004 — has() is false for a source that lacks the category', () {
      final merged = ListingTaxonomyState.mergeTaxonomies({
        ListingKind.event: [_cat(1, 'Sports & Fitness')],
        ListingKind.program: [_cat(5, 'Robotics')],
      });

      final sports = _byLabel(merged, 'Sports & Fitness');
      expect(sports.has(ListingKind.event), isTrue);
      expect(sports.has(ListingKind.program), isFalse);
      expect(sports.names[ListingKind.program], isNull);
    });

    test('TC_LT_005 — subcategories merge across sources under their parent',
        () {
      final merged = ListingTaxonomyState.mergeTaxonomies({
        ListingKind.event: [
          _cat(1, 'Arts & Crafts', subs: [_sub(11, 'Painting')]),
        ],
        ListingKind.program: [
          _cat(2, 'Arts & Crafts',
              subs: [_sub(77, 'Painting'), _sub(78, 'Pottery')]),
        ],
      });

      final node = merged.single;
      expect(node.children.map((c) => c.label), ['Painting', 'Pottery']);

      final painting = _byLabel(node.children, 'Painting');
      expect(painting.names[ListingKind.event], 'Painting');
      expect(painting.ids[ListingKind.program], 77);

      // Pottery came only from programs, so events cannot be filtered by it.
      expect(_byLabel(node.children, 'Pottery').has(ListingKind.event), isFalse);
    });

    test('TC_LT_006 — a failed source contributes nothing and does not throw',
        () {
      final merged = ListingTaxonomyState.mergeTaxonomies({
        ListingKind.event: [_cat(1, 'Music')],
        // What _safe() yields when an endpoint is down.
        ListingKind.venue: const <ApiCategory>[],
      });

      expect(merged, hasLength(1));
      expect(merged.single.has(ListingKind.venue), isFalse);
    });

    test('TC_LT_007 — categories are alphabetical and blank names dropped', () {
      final merged = ListingTaxonomyState.mergeTaxonomies({
        ListingKind.event: [
          _cat(1, 'Sports'),
          _cat(2, 'Arts'),
          _cat(3, '   '),
        ],
      });

      expect(merged.map((n) => n.label), ['Arts', 'Sports']);
    });

    test('TC_LT_008 — an empty taxonomy set merges to an empty list', () {
      expect(ListingTaxonomyState.mergeTaxonomies(const {}), isEmpty);
    });
  });
}
