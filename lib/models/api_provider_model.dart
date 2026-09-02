class ApiProvider {
  final String id;
  final String name;
  final String? bio;
  final String? logoUrl;
  final int totalListings;
  final double averageRating;
  final int totalReviews;
  final int experienceYears;
  /// Follower count, or null when the API did not send one.
  ///
  /// `/listings/{id}/provider/` returns no follower field of any name today —
  /// only `/partner/followed/` carries one, as `follower_count`. Null means
  /// "unknown", which the profile screen renders as nothing rather than as a
  /// confident zero: showing "0 Followers" to somebody who is themselves
  /// following reads as a broken app, not as missing data.
  final int? totalFollowers;

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
        // `follower_count` first: that is the spelling the backend already
        // uses on `/partner/followed/`, so it is the one the provider
        // endpoint will most likely adopt when it starts sending the field.
        totalFollowers: (json['follower_count'] as num?)?.toInt() ??
            (json['total_followers'] as num?)?.toInt() ??
            (json['followers_count'] as num?)?.toInt(),
      );
}
