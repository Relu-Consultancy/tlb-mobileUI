import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/listing_filters.dart';

class _L {
  final String id;
  final double? price;
  final double? km;
  final String kind;
  const _L(this.id, {this.price, this.km, this.kind = 'a'});
}

List<String> _ids(List<_L> l) => l.map((e) => e.id).toList();

void main() {
  const items = [
    _L('a', price: 500, km: 9),
    _L('b', price: 200, km: 2),
    _L('c'), // no price, no distance
    _L('d', price: 500, km: 5),
  ];

  group('ListingFilters.sort', () {
    test('TC_C_LF_001 — price low to high, unpriced last', () {
      final out = ListingFilters.sort(items, ListingSort.priceLow,
          price: (i) => i.price);
      expect(_ids(out), ['b', 'a', 'd', 'c']);
    });

    test('TC_C_LF_002 — price high to low keeps unpriced last, ties stable',
        () {
      final out = ListingFilters.sort(items, ListingSort.priceHigh,
          price: (i) => i.price);
      expect(_ids(out), ['a', 'd', 'b', 'c']);
    });

    test('TC_C_LF_003 — distance near to far, unknown last', () {
      final out = ListingFilters.sort(items, ListingSort.distance,
          distance: (i) => i.km);
      expect(_ids(out), ['b', 'd', 'a', 'c']);
    });

    test('TC_C_LF_004 — top picks ranks high first, null keeps server order',
        () {
      final out = ListingFilters.sort(items, ListingSort.topPicks,
          rank: (i) => i.id == 'd' ? 9 : null);
      expect(_ids(out), ['d', 'a', 'b', 'c']);
    });

    test('TC_C_LF_005 — no sort, or no key for it, leaves the order alone', () {
      expect(ListingFilters.sort(items, null), items);
      expect(ListingFilters.sort(items, ListingSort.topPicks), items);
    });

    test('TC_C_LF_006 — does not mutate the input list', () {
      final copy = [...items];
      ListingFilters.sort(items, ListingSort.priceLow, price: (i) => i.price);
      expect(items, copy);
    });
  });

  group('ListingFilters.apply', () {
    final opts = [
      ListingFilter<_L>('Kind A', 'kind', (i) => i.kind == 'a'),
      ListingFilter<_L>('Kind B', 'kind', (i) => i.kind == 'b'),
      ListingFilter<_L>('Cheap', 'cost', (i) => (i.price ?? 1e9) < 300),
    ];
    const mixed = [
      _L('1', price: 100, kind: 'a'),
      _L('2', price: 100, kind: 'b'),
      _L('3', price: 900, kind: 'a'),
      _L('4', price: 900, kind: 'c'),
    ];

    test('TC_C_LF_007 — nothing selected returns everything', () {
      expect(ListingFilters.apply(mixed, const [], opts), mixed);
    });

    test('TC_C_LF_008 — options in one group are alternatives (OR)', () {
      final out = ListingFilters.apply(mixed, ['Kind A', 'Kind B'], opts);
      expect(_ids(out), ['1', '2', '3']);
    });

    test('TC_C_LF_009 — different groups must all match (AND)', () {
      final out = ListingFilters.apply(mixed, ['Kind A', 'Cheap'], opts);
      expect(_ids(out), ['1']);
    });

    test('TC_C_LF_010 — unknown labels are ignored', () {
      expect(ListingFilters.apply(mixed, ['Nope'], opts), mixed);
    });
  });

  group('prices', () {
    test('TC_C_LF_011 — parsePrice reads numeric strings, else null', () {
      expect(ListingFilters.parsePrice('500.00'), 500);
      expect(ListingFilters.parsePrice(' 2499 '), 2499);
      expect(ListingFilters.parsePrice(null), isNull);
      expect(ListingFilters.parsePrice('free'), isNull);
    });

    test('TC_C_LF_012 — price bands split at 1,000 and 3,000, skip unpriced',
        () {
      final bands = ListingFilters.priceBands<_L>((i) => i.price);
      bool hit(String label, double? p) =>
          bands.firstWhere((b) => b.label == label).test(_L('x', price: p));
      expect(hit('Under ₹1,000', 999), isTrue);
      expect(hit('Under ₹1,000', 1000), isFalse);
      expect(hit('₹1,000 – ₹3,000', 1000), isTrue);
      expect(hit('₹1,000 – ₹3,000', 3000), isTrue);
      expect(hit('Above ₹3,000', 3000.5), isTrue);
      for (final b in bands) {
        expect(b.test(const _L('x')), isFalse, reason: b.label);
      }
    });
  });

  group('ListingSort', () {
    test('TC_C_LF_013 — labels round-trip and match the sheet copy', () {
      for (final s in ListingSort.values) {
        expect(ListingSort.fromLabel(s.label), s);
      }
      expect(ListingSort.fromLabel(null), isNull);
      expect(ListingSort.distance.label, 'Distance- Near to Far');
    });

    test('TC_C_LF_014 — types without a price offer no price sort', () {
      expect(ListingSort.forType(hasPrice: false),
          [ListingSort.topPicks, ListingSort.distance]);
      expect(ListingSort.forType(hasPrice: true), ListingSort.values);
    });
  });
}
