class EventModel {
  final String id;
  final String title;
  final String venue;
  final String imagePath;
  final double? price;
  final double? rating;
  final String? reviewCount;
  final String? tag;
  final String? description;
  final bool isFeatured;
  final String? eventDate;
  final String? eventTime;

  const EventModel({
    this.id = '',
    required this.title,
    required this.venue,
    required this.imagePath,
    this.price,
    this.rating,
    this.reviewCount,
    this.tag,
    this.description,
    this.isFeatured = false,
    this.eventDate,
    this.eventTime,
  });

  /// Stable identifier: uses explicit id if set, otherwise title+venue hash.
  String get uniqueId => id.isNotEmpty ? id : '${title}_$venue';
}
