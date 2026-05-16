class ApiProvider {
  final String id;
  final String name;
  final String? bio;
  final String? logoUrl;
  final int totalListings;
  final double averageRating;
  final int totalReviews;
  final int experienceYears;

  const ApiProvider({
    required this.id,
    required this.name,
    this.bio,
    this.logoUrl,
    required this.totalListings,
    required this.averageRating,
    required this.totalReviews,
    required this.experienceYears,
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
      );
}
