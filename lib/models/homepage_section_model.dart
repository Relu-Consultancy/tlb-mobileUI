import 'event_model.dart';

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
  });

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  factory HomepageListing.fromJson(Map<String, dynamic> json) =>
      HomepageListing(
        id: json['id']?.toString() ?? '',
        title: (json['title'] as String?) ?? '',
        shortDescription: (json['short_description'] as String?) ?? '',
        listingType: (json['listing_type'] as String?) ?? 'event',
        isTlbSignature: json['is_tlb_signature'] == true,
        coverUrl: _str(json['cover_url']),
        category: _str(json['category']),
        city: _str(json['city']),
        area: _str(json['area']),
        price: _str(json['price']),
        priceType: _str(json['price_type']),
        rating: _str(json['rating']),
        totalReviews: _str(json['total_reviews']),
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
    );
  }
}

/// One homepage section (e.g. `hot_picks`) and its ordered listings.
class HomepageSection {
  final String section;
  final String label;
  final List<HomepageListing> listings;

  const HomepageSection({
    required this.section,
    required this.label,
    required this.listings,
  });

  factory HomepageSection.fromJson(Map<String, dynamic> json) =>
      HomepageSection(
        section: (json['section'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
        listings: (json['listings'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(HomepageListing.fromJson)
            .toList(),
      );
}
