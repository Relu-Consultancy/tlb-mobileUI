class ApiReviewMedia {
  final int id;
  final String mediaType;
  final String file;

  const ApiReviewMedia({required this.id, required this.mediaType, required this.file});

  factory ApiReviewMedia.fromJson(Map<String, dynamic> json) => ApiReviewMedia(
        id: json['id'] as int,
        mediaType: (json['media_type'] as String?) ?? '',
        file: (json['file'] as String?) ?? '',
      );
}

class ApiReview {
  final int id;
  final String customerId;
  final String customerName;
  final int rating;
  final String comment;
  final List<ApiReviewMedia> media;
  final DateTime createdAt;

  const ApiReview({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.media,
    required this.createdAt,
  });

  factory ApiReview.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>? ?? {};
    return ApiReview(
      id: (json['id'] as num).toInt(),
      customerId: (customer['id'] as String?) ?? '',
      customerName: (customer['name'] as String?) ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: (json['comment'] as String?) ?? '',
      media: ((json['media'] as List?) ?? [])
          .map((m) => ApiReviewMedia.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class ApiReviewPage {
  final String listingId;
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingBreakdown;
  final List<ApiReview> reviews;
  final int count;
  final bool hasNext;

  const ApiReviewPage({
    required this.listingId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
    required this.reviews,
    required this.count,
    required this.hasNext,
  });

  factory ApiReviewPage.empty(String listingId) => ApiReviewPage(
        listingId: listingId,
        averageRating: 0,
        totalReviews: 0,
        ratingBreakdown: {},
        reviews: [],
        count: 0,
        hasNext: false,
      );

  factory ApiReviewPage.fromJson(Map<String, dynamic> json) {
    final reviewsData = json['reviews'] as Map<String, dynamic>?;
    final rawBreakdown = json['rating_breakdown'] as Map? ?? {};
    return ApiReviewPage(
      listingId: (json['listing_id'] as String?) ?? '',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      ratingBreakdown: {
        for (final e in rawBreakdown.entries)
          e.key.toString(): (e.value as num?)?.toInt() ?? 0,
      },
      reviews: ((reviewsData?['results'] as List?) ?? [])
          .map((r) => ApiReview.fromJson(r as Map<String, dynamic>))
          .toList(),
      count: (reviewsData?['count'] as num?)?.toInt() ?? 0,
      hasNext: reviewsData?['next'] != null,
    );
  }
}
