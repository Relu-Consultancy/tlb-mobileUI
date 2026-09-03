class ApiProvider {
  final String id;
  final String name;
  final String? bio;
  final String? logoUrl;
  final int totalListings;
  final double averageRating;
  final int totalReviews;
  final int experienceYears;

  /// Social profile links, or null when the partner has not set one.
  ///
  /// `/listings/{id}/provider/` sends these under a `social_links` object and
  /// writes an unset link as an empty string, never null and never a missing
  /// key — so "" is normalised to null here and the icon for it is simply not
  /// drawn. The flat spellings are still read as a fallback; they cost
  /// nothing and cover a partner payload shaped the older way.
  final String? instagramUrl;
  final String? facebookUrl;
  final String? linkedinUrl;
  final String? websiteUrl;

  /// Active followers — people who have since unfollowed are not counted.
  ///
  /// Null means the field was absent, which the profile screen renders as
  /// nothing rather than as a confident zero: showing "0 Followers" to
  /// somebody who is themselves following reads as a broken app, not as
  /// missing data.
  final int? totalFollowers;

  /// Whether the customer who made this request follows the partner.
  ///
  /// Auth on the provider endpoint is optional: called without a token — or
  /// with an expired one — it still returns 200 with the full payload, but
  /// `is_following` comes back false. So false is only trustworthy when the
  /// call carried a valid token; from a logged-out call it means "unknown",
  /// not "definitely not following".
  final bool isFollowing;

  const ApiProvider({
    required this.id,
    required this.name,
    this.bio,
    this.logoUrl,
    required this.totalListings,
    required this.averageRating,
    required this.totalReviews,
    required this.experienceYears,
    this.totalFollowers,
    this.isFollowing = false,
    this.instagramUrl,
    this.facebookUrl,
    this.linkedinUrl,
    this.websiteUrl,
  });

  factory ApiProvider.fromJson(Map<String, dynamic> json) => ApiProvider(
        id: json['id'] as String,
        name: json['name'] as String,
        bio: json['bio'] as String?,
        logoUrl: json['logo_url'] as String?,
        totalListings: (json['total_listings'] as num?)?.toInt() ?? 0,
        averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
        experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
        // `follower_count` is what both this endpoint and `/partner/followed/`
        // send; the other two spellings are legacy fallbacks.
        totalFollowers: (json['follower_count'] as num?)?.toInt() ??
            (json['total_followers'] as num?)?.toInt() ??
            (json['followers_count'] as num?)?.toInt(),
        isFollowing: json['is_following'] == true,
        instagramUrl: _link(json, 'instagram'),
        facebookUrl: _link(json, 'facebook'),
        linkedinUrl: _link(json, 'linkedin'),
        websiteUrl: _link(json, 'website'),
      );

  /// Reads a social link under any of the shapes a backend might use:
  /// a nested `social_links: { instagram: ... }` — what the API sends — or a
  /// flat `instagram_url` / `instagram`. Blank strings count as absent, which
  /// is how the API spells "the partner has not set this one".
  static String? _link(Map<String, dynamic> json, String network) {
    final social = json['social_links'] ?? json['socials'];
    final candidates = <dynamic>[
      if (social is Map) social[network],
      if (social is Map) social['${network}_url'],
      json['${network}_url'],
      json[network],
    ];
    for (final c in candidates) {
      if (c is String && c.trim().isNotEmpty) return c.trim();
    }
    return null;
  }

  ApiProvider copyWith({int? totalFollowers, bool? isFollowing}) => ApiProvider(
        id: id,
        name: name,
        bio: bio,
        logoUrl: logoUrl,
        totalListings: totalListings,
        averageRating: averageRating,
        totalReviews: totalReviews,
        experienceYears: experienceYears,
        totalFollowers: totalFollowers ?? this.totalFollowers,
        isFollowing: isFollowing ?? this.isFollowing,
        instagramUrl: instagramUrl,
        facebookUrl: facebookUrl,
        linkedinUrl: linkedinUrl,
        websiteUrl: websiteUrl,
      );
}
