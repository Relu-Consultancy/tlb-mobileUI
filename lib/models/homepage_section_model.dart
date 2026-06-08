/// A single listing reference inside a homepage section. The homepage endpoint
/// returns only minimal fields — the full card data (image, price, city,
/// rating) is hydrated separately from the list APIs by [id] + [listingType].
class HomepageListing {
  final String id;
  final String title;
  final String shortDescription;
  final String listingType; // 'event' | 'class' | 'program' | 'venue'
  final bool isTlbSignature;

  const HomepageListing({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.listingType,
    required this.isTlbSignature,
  });

  factory HomepageListing.fromJson(Map<String, dynamic> json) =>
      HomepageListing(
        id: json['id']?.toString() ?? '',
        title: (json['title'] as String?) ?? '',
        shortDescription: (json['short_description'] as String?) ?? '',
        listingType: (json['listing_type'] as String?) ?? 'event',
        isTlbSignature: json['is_tlb_signature'] == true,
      );
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
