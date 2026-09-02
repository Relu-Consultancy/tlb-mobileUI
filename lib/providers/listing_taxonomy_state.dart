import 'package:flutter/foundation.dart';

import '../models/api_category_model.dart';
import '../services/classes_listing_service.dart';
import '../services/events_listing_service.dart';
import '../services/programs_listing_service.dart';

/// The four listing types a search can return.
enum ListingKind { event, klass, program, venue }

/// One category (or subcategory) as offered by one or more listing types.
///
/// The four listing endpoints do **not** share a filter vocabulary:
///
/// | listing  | category filter        | subcategory filter |
/// |----------|------------------------|--------------------|
/// | events   | exact `name` string    | exact `name` string|
/// | classes  | exact `name` string    | exact `name` string|
/// | programs | integer `category_id`  | `subcategory_id`   |
/// | venues   | integer `category_id`  | `subcategory_id`   |
///
/// The name match is exact and case-sensitive — a slug or an id returns HTTP
/// 200 with zero results rather than an error, so sending the wrong shape
/// fails silently and looks identical to an empty category. A node therefore
/// carries the exact name *and* the id **per contributing source**, and a
/// source that never offered this node is simply absent from both maps —
/// which is how callers know not to ask it for this filter at all.
@immutable
class TaxonomyNode {
  /// What the user sees. Taken from the first contributing source, so it is
  /// always a real name from a real taxonomy rather than a synthesised label.
  final String label;

  /// The exact category/subcategory name each source knows this node by.
  /// Keys are the sources that offer it.
  final Map<ListingKind, String> names;

  /// The integer id each source knows this node by. Same key set as [names].
  final Map<ListingKind, int> ids;

  /// Subcategories, themselves merged across every source that offers this
  /// node. Empty for a subcategory, and empty for a category whose sources
  /// send no `subcategories` array.
  final List<TaxonomyNode> children;

  const TaxonomyNode({
    required this.label,
    required this.names,
    required this.ids,
    this.children = const [],
  });

  /// The listing types that can actually be filtered by this node.
  Iterable<ListingKind> get sources => names.keys;

  /// Whether [kind] offers this node at all.
  bool has(ListingKind kind) => names.containsKey(kind);
}

/// Loads and caches the category/subcategory taxonomies of all four listing
/// types, merged into one list the search filter sheet can offer as a single
/// vocabulary.
///
/// Modelled on [HomeFeedState]: static holder, one in-flight load at a time,
/// cached for the process lifetime, with a [version] notifier for rebuilds.
class ListingTaxonomyState {
  ListingTaxonomyState._();

  /// Bumped whenever [categories] changes, so open UI can rebuild.
  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static bool _loading = false;
  static bool _loaded = false;
  static List<TaxonomyNode> _categories = const [];

  /// Merged categories, alphabetical. Empty until [load] completes — and also
  /// empty if every endpoint failed, which callers should treat as "offer no
  /// category filter" rather than as an error worth showing.
  static List<TaxonomyNode> get categories => _categories;

  /// True once a load has finished, whether or not it found anything.
  static bool get isLoaded => _loaded;

  /// True while a load is in flight, so a picker can show a spinner instead
  /// of an empty list.
  static bool get isLoading => _loading;

  /// Fetches all four taxonomies in parallel and merges them.
  ///
  /// Each source is isolated: one endpoint being down (the venues metadata
  /// endpoint is not reliably live) costs only that source's contribution,
  /// never the whole picker. Never throws.
  static Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_loaded && !force) return;
    _loading = true;
    // Announced immediately so a sheet that is already open paints its
    // loading state rather than an empty section.
    version.value++;

    try {
      final results = await Future.wait<List<ApiCategory>>([
        _safe(EventsListingService.fetchCategories),
        _safe(ClassesListingService.fetchClassCategories),
        _safe(ProgramsListingService.fetchProgramCategories),
        _safe(EventsListingService.fetchVenueCategories),
      ]);

      _categories = _merge({
        ListingKind.event: results[0],
        ListingKind.klass: results[1],
        ListingKind.program: results[2],
        ListingKind.venue: results[3],
      });
      // Deliberately not an unconditional `true`: a total outage must not be
      // cached for the process lifetime, or the picker stays broken until the
      // app restarts. Anything found is good enough to keep.
      _loaded = _categories.isNotEmpty;
      version.value++;
    } finally {
      _loading = false;
    }
  }

  /// Runs one taxonomy fetch, turning any failure into "this source
  /// contributed nothing".
  static Future<List<ApiCategory>> _safe(
    Future<List<ApiCategory>> Function() fetch,
  ) async {
    try {
      // Capped per source, not across the joined wait: the services disagree
      // on their own timeouts (programs 15s, the other three 30s) and
      // Future.wait settles at the slowest, so a shared cap would throw away
      // the three answers already in hand to punish one hung endpoint.
      return await fetch().timeout(const Duration(seconds: 12));
    } catch (_) {
      // Broad on purpose, not `on Exception`: none of these fetchers checks
      // statusCode before jsonDecode, so an HTML error page surfaces as a
      // FormatException and an unexpected body shape as a raw TypeError.
      return const [];
    }
  }

  /// Collapses whitespace/case/newlines so the same category spelled slightly
  /// differently by two backends still merges into one option. Only the
  /// *matching* is normalised — the values sent to each API stay verbatim.
  static String _norm(String s) =>
      s.replaceAll('\n', ' ').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// The merge step on its own, so the per-source name/id bookkeeping can be
  /// verified without reaching the network.
  @visibleForTesting
  static List<TaxonomyNode> mergeTaxonomies(
    Map<ListingKind, List<ApiCategory>> byKind,
  ) =>
      _merge(byKind);

  static List<TaxonomyNode> _merge(Map<ListingKind, List<ApiCategory>> byKind) {
    // Insertion-ordered so the first source to contribute a node supplies its
    // display label; sorted alphabetically at the end for a stable picker.
    final merged = <String, _NodeBuilder>{};

    byKind.forEach((kind, categories) {
      for (final cat in categories) {
        if (cat.name.trim().isEmpty) continue;
        // Equality after normalisation ONLY — never prefix or substring
        // matching. Two taxonomies that merely start with the same words are
        // not the same category, and a wrong value returns HTTP 200 with zero
        // rows, so a mis-merge produces plausible empty results with nothing
        // to notice. Two chips that look redundant beat one chip that lies.
        final key = _norm(cat.name);
        final node = merged.putIfAbsent(key, () => _NodeBuilder(cat.name));
        node.add(kind, cat.name, cat.id);

        for (final sub in cat.subcategories) {
          if (sub.name.trim().isEmpty) continue;
          final subKey = _norm(sub.name);
          final subNode =
              node.children.putIfAbsent(subKey, () => _NodeBuilder(sub.name));
          subNode.add(kind, sub.name, sub.id);
        }
      }
    });

    final out = merged.values.map((b) => b.build()).toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return List.unmodifiable(out);
  }
}

/// Mutable accumulator used only while merging.
class _NodeBuilder {
  final String label;
  final Map<ListingKind, String> names = {};
  final Map<ListingKind, int> ids = {};
  final Map<String, _NodeBuilder> children = {};

  _NodeBuilder(this.label);

  void add(ListingKind kind, String name, int id) {
    // First spelling wins per source; a taxonomy listing the same category
    // twice must not flip the value we send.
    names.putIfAbsent(kind, () => name);
    ids.putIfAbsent(kind, () => id);
  }

  TaxonomyNode build() {
    final kids = children.values.map((b) => b.build()).toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return TaxonomyNode(
      label: label,
      names: Map.unmodifiable(names),
      ids: Map.unmodifiable(ids),
      children: List.unmodifiable(kids),
    );
  }
}
