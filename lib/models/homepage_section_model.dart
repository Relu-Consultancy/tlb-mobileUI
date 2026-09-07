import '../core/date_format.dart';
import '../core/time_format.dart';
import 'event_model.dart';
import '../core/secure_url.dart';

/// A single listing inside a homepage section. The homepage endpoint now
/// returns the full card fields, so cards render directly from this — no
/// separate hydration needed.
class HomepageListing {
  final String id;
  final String title;
  final String shortDescription;
  final String listingType; // 'event' | 'class' | 'program' | 'venue'
  final bool isTlbSignature;
  final String? coverUrl;
  final String? category;
  final String? city;
  final String? area;
  final String? price; // string amount; null/empty for free
  final String? priceType; // 'free' | 'paid' | ...
  final String? rating;
  final String? totalReviews;

  /// Present for every listing_type on this feed, but only ever non-null for
  /// events and programs — a class's end_datetime is always null (open-ended
  /// recurring schedule, no such date exists) and a venue carries neither
  /// field at all. See ListingSchedule's doc for the per-type breakdown.
  ///
  /// This feed does not carry a class's `is_paused` flag, so an ended-style
  /// filter here can only catch finished events/programs — a paused class
  /// still appears. Filtering that too would need the field added here.
  final DateTime? startDatetime;
  final DateTime? endDatetime;

  const HomepageListing({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.listingType,
    required this.isTlbSignature,
    this.coverUrl,
    this.category,
    this.city,
    this.area,
    this.price,
    this.priceType,
    this.rating,
    this.totalReviews,
    this.startDatetime,
    this.endDatetime,
  });

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// `category` arrives as `{"id": 1, "name": "Arts & Crafts"}` on the
  /// discovery feeds. Reading it as a plain string stamped a whole Dart
  /// map onto the card's tag chip.
  static String? _categoryName(dynamic v) {
    if (v is Map) return _str(v['name']);
    return _str(v);
  }

  factory HomepageListing.fromJson(Map<String, dynamic> json) =>
      HomepageListing(
        id: json['id']?.toString() ?? '',
        title: (json['title'] as String?) ?? '',
        shortDescription: (json['short_description'] as String?) ?? '',
        listingType: (json['listing_type'] as String?) ?? 'event',
        isTlbSignature: json['is_tlb_signature'] == true,
        coverUrl: secureUrl(_str(json['cover_url'])),
        category: _categoryName(json['category']),
        city: _str(json['city']),
        area: _str(json['area']),
        price: _str(json['price']),
        priceType: _str(json['price_type']),
        rating: _str(json['rating']),
        totalReviews: _str(json['total_reviews']),
        startDatetime:
            DateTime.tryParse(json['start_datetime']?.toString() ?? ''),
        endDatetime:
            DateTime.tryParse(json['end_datetime']?.toString() ?? ''),
      );

  /// Build the card model used by the existing home-section / banner widgets.
  EventModel toEventModel() {
    final loc = [area, city]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
    final isFree = (priceType ?? '').toLowerCase() == 'free';
    final reviews = totalReviews;
    return EventModel(
      id: id,
      title: title,
      venue: loc.isNotEmpty ? loc : (shortDescription),
      imagePath: coverUrl ?? '',
      tag: category,
      description: shortDescription.isEmpty ? null : shortDescription,
      price: isFree ? null : (price != null ? double.tryParse(price!) : null),
      rating: rating != null ? double.tryParse(rating!) : null,
      reviewCount: (reviews != null && reviews.isNotEmpty)
          ? '$reviews reviews'
          : null,
      listingType: listingType,
      // The mock cards carried a preformatted date and time; the feed
      // carries an ISO datetime, so format it here to the one shape the
      // app uses. Without this the cards that print a date drew nothing.
      eventDate: startDatetime == null
          ? null
          : DateFormat.card(startDatetime!.toLocal()),
      eventTime: startDatetime == null ? null : _timeOf(startDatetime!),
    );
  }

  static String _timeOf(DateTime dt) {
    final local = dt.toLocal();
    final minute = local.minute.toString().padLeft(2, '0');
    return TimeFormat.h12('${local.hour}:$minute');
  }
}

/// One section (e.g. `hot_picks`, `trending_events`) and its ordered
/// listings. Used for both the homepage feed and the four discovery
/// screens, which return the identical shape.
class HomepageSection {
  final String section;
  final String label;

  /// The one listing an admin flagged as this section's feature, or null
  /// when none is set — which is still the default for most sections.
  ///
  /// It is NOT repeated in [listings]: the API removes a hero from that
  /// array, so anything reading only [listings] silently loses a curated
  /// card the moment an admin sets one. Read [ordered] instead.
  final HomepageListing? hero;

  final List<HomepageListing> listings;

  const HomepageSection({
    required this.section,
    required this.label,
    this.hero,
    required this.listings,
  });

  /// Every curated listing, the hero first.
  ///
  /// These rails are rows of identical cards with no banner slot, so the
  /// hero leads the row rather than getting its own treatment — it is
  /// still the first thing seen, and nothing an admin curated is dropped.
  List<HomepageListing> get ordered =>
      hero == null ? listings : [hero!, ...listings];

  factory HomepageSection.fromJson(Map<String, dynamic> json) =>
      HomepageSection(
        section: (json['section'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
        hero: json['hero'] is Map<String, dynamic>
            ? HomepageListing.fromJson(json['hero'] as Map<String, dynamic>)
            : null,
        listings: (json['listings'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(HomepageListing.fromJson)
            .toList(),
      );
}
