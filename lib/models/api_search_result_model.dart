import '../providers/listing_taxonomy_state.dart';
import 'api_category_model.dart';

/// One row from `GET /listings/search/` — the unified keyword-search endpoint.
///
/// This is a deliberately lean *search card*, not the full detail payload each
/// listing type's own endpoint returns. Every listing type comes back in this
/// one flat shape, with [listingType] saying which detail screen a tap should
/// open.
class ApiSearchResult {
  final String id;
  final ListingKind listingType;
  final String title;
  final String? shortDescription;
  final ApiCategory? category;
  final String? city;
  final String? coverUrl;
  final String? partnerName;

  /// Ratings are documented on this endpoint but are absent from live rows
  /// today, so they are optional here — the card has to read fine without
  /// them rather than showing a hard "0.0".
  final double? averageRating;
  final int? totalReviews;

  const ApiSearchResult({
    required this.id,
    required this.listingType,
    required this.title,
    this.shortDescription,
    this.category,
    this.city,
    this.coverUrl,
    this.partnerName,
    this.averageRating,
    this.totalReviews,
  });

  /// The API's `listing_type` values. `class` is a Dart keyword, hence the
  /// enum's `klass`.
  static ListingKind? kindFrom(String? raw) => switch (raw) {
        'event' => ListingKind.event,
        'class' => ListingKind.klass,
        'program' => ListingKind.program,
        'venue' => ListingKind.venue,
        _ => null,
      };

  /// The wire value for [kind] — used to narrow a search to one type.
  static String wireName(ListingKind kind) => switch (kind) {
        ListingKind.event => 'event',
        ListingKind.klass => 'class',
        ListingKind.program => 'program',
        ListingKind.venue => 'venue',
      };

  /// Returns null for a row whose `listing_type` is missing or unrecognised —
  /// there is no detail screen to route such a row to, so it is dropped rather
  /// than rendered as an untappable card.
  static ApiSearchResult? fromJson(Map<String, dynamic> json) {
    final kind = kindFrom(json['listing_type'] as String?);
    if (kind == null) return null;
    final category = json['category'];
    return ApiSearchResult(
      id: (json['id'] as String?) ?? '',
      listingType: kind,
      title: (json['title'] as String?) ?? '',
      shortDescription: _text(json['short_description']),
      category: category is Map<String, dynamic>
          ? ApiCategory.fromJson(category)
          : null,
      city: _text(json['city']),
      coverUrl: _text(json['cover_url']),
      partnerName: _text(json['partner_name']),
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      totalReviews: json['total_reviews'] as int?,
    );
  }

  static String? _text(Object? raw) {
    final s = raw as String?;
    return (s == null || s.isEmpty) ? null : s;
  }
}

/// A page of search results. Mirrors the pagination envelope every other list
/// endpoint uses, plus the `next`/`previous` links this one adds.
class ApiSearchPage {
  final int count;
  final int page;
  final int pageSize;
  final String? next;
  final List<ApiSearchResult> results;

  const ApiSearchPage({
    required this.count,
    required this.page,
    required this.pageSize,
    this.next,
    required this.results,
  });

  factory ApiSearchPage.fromJson(Map<String, dynamic> json) => ApiSearchPage(
        count: (json['count'] as int?) ?? 0,
        page: (json['page'] as int?) ?? 1,
        pageSize: (json['page_size'] as int?) ?? 10,
        next: json['next'] as String?,
        results: ((json['results'] as List?) ?? [])
            .map((r) => ApiSearchResult.fromJson(r as Map<String, dynamic>))
            .whereType<ApiSearchResult>()
            .toList(),
      );
}
