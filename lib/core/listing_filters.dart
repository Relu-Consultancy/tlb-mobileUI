// Sorting and filtering for the category screens' Sort / Filters sheet.
// 
// The listing endpoints ignore every ordering parameter (probed live: the
// order never changes), so sorting and filtering happen here, on the cards a
// screen has loaded. One implementation serves all four listing types; each
// screen only says how to read a price, distance and so on from its own model.

/// How the sheet's "Sort by" labels map to behaviour. The labels are what the
/// sheet shows and returns, so they live here once rather than in each screen.
enum ListingSort {
  topPicks('Top Picks'),
  distance('Distance- Near to Far'),
  priceLow('Price- Low to High'),
  priceHigh('Price- High to Low');

  final String label;
  const ListingSort(this.label);

  static ListingSort? fromLabel(String? label) {
    for (final s in values) {
      if (s.label == label) return s;
    }
    return null;
  }

  /// Sort options for a listing type. Venues carry no price in the list
  /// response, so offering a price sort there would silently do nothing.
  static List<ListingSort> forType({required bool hasPrice}) => [
        topPicks,
        distance,
        if (hasPrice) ...[priceLow, priceHigh],
      ];
}

/// One entry in the sheet's Filters tab. Entries sharing a [group] are
/// alternatives (OR); different groups must all match (AND) — so picking
/// "Workshop" and "Camp" shows both, while "Workshop" and "Free" shows only
/// free workshops.
class ListingFilter<T> {
  final String label;
  final String group;
  final bool Function(T item) test;

  const ListingFilter(this.label, this.group, this.test);
}

class ListingFilters {
  const ListingFilters._();

  /// Keeps the items that satisfy every group with at least one selection.
  static List<T> apply<T>(
    List<T> items,
    Iterable<String> selected,
    List<ListingFilter<T>> available,
  ) {
    final chosen = available.where((f) => selected.contains(f.label)).toList();
    if (chosen.isEmpty) return items;
    final groups = <String, List<ListingFilter<T>>>{};
    for (final f in chosen) {
      (groups[f.group] ??= []).add(f);
    }
    return items
        .where((item) => groups.values
            .every((alternatives) => alternatives.any((f) => f.test(item))))
        .toList();
  }

  /// Orders [items] without disturbing the server's order among equals
  /// (`List.sort` is not stable, so ties would otherwise shuffle between
  /// taps). Items with no value for the chosen key go last either way.
  ///
  /// [rank] is the Top Picks key: higher comes first; null keeps server order.
  static List<T> sort<T>(
    List<T> items,
    ListingSort? sort, {
    double? Function(T item)? price,
    double? Function(T item)? distance,
    double? Function(T item)? rank,
  }) {
    if (sort == null) return items;
    double? Function(T)? key;
    var descending = false;
    switch (sort) {
      case ListingSort.topPicks:
        key = rank;
        descending = true;
      case ListingSort.distance:
        key = distance;
      case ListingSort.priceLow:
        key = price;
      case ListingSort.priceHigh:
        key = price;
        descending = true;
    }
    if (key == null) return items;

    final indexed = [for (var i = 0; i < items.length; i++) (i, items[i])];
    indexed.sort((a, b) {
      final ka = key!(a.$2);
      final kb = key(b.$2);
      if (ka == null && kb == null) return a.$1.compareTo(b.$1);
      if (ka == null) return 1;
      if (kb == null) return -1;
      final c = descending ? kb.compareTo(ka) : ka.compareTo(kb);
      return c != 0 ? c : a.$1.compareTo(b.$1);
    });
    return [for (final e in indexed) e.$2];
  }

  /// A price shown as text ("500.00") as a number; null when absent.
  static double? parsePrice(String? raw) =>
      raw == null ? null : double.tryParse(raw.trim());

  /// Standard price bands used by every priced type.
  static List<ListingFilter<T>> priceBands<T>(double? Function(T) price) => [
        ListingFilter<T>('Under ₹1,000', 'price', (i) {
          final p = price(i);
          return p != null && p < 1000;
        }),
        ListingFilter<T>('₹1,000 – ₹3,000', 'price', (i) {
          final p = price(i);
          return p != null && p >= 1000 && p <= 3000;
        }),
        ListingFilter<T>('Above ₹3,000', 'price', (i) {
          final p = price(i);
          return p != null && p > 3000;
        }),
      ];
}
