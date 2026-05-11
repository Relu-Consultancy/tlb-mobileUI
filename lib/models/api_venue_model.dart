class ApiVenueCategory {
  final int id;
  final String name;
  final String slug;

  const ApiVenueCategory({required this.id, required this.name, required this.slug});

  factory ApiVenueCategory.fromJson(Map<String, dynamic> json) => ApiVenueCategory(
        id: (json['id'] as int?) ?? 0,
        name: (json['name'] as String?) ?? '',
        slug: (json['slug'] as String?) ?? '',
      );
}

class ApiVenueMedia {
  final int id;
  final String mediaType;
  final String url;

  const ApiVenueMedia({required this.id, required this.mediaType, required this.url});

  factory ApiVenueMedia.fromJson(Map<String, dynamic> json) => ApiVenueMedia(
        id: (json['id'] as int?) ?? 0,
        mediaType: (json['media_type'] as String?) ?? '',
        url: (json['url'] as String?) ?? '',
      );
}

class ApiVenuePackage {
  final int id;
  final String name;
  final double price;
  final String? description;
  final int? durationMinutes;
  final int? maxGuests;

  const ApiVenuePackage({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.durationMinutes,
    this.maxGuests,
  });

  factory ApiVenuePackage.fromJson(Map<String, dynamic> json) => ApiVenuePackage(
        id: (json['id'] as int?) ?? 0,
        name: (json['name'] as String?) ?? '',
        price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
        description: json['description'] as String?,
        durationMinutes: json['duration_minutes'] as int?,
        maxGuests: json['max_guests'] as int?,
      );
}

class ApiVenueAvailability {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final String? note;

  const ApiVenueAvailability({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.note,
  });

  factory ApiVenueAvailability.fromJson(Map<String, dynamic> json) =>
      ApiVenueAvailability(
        id: (json['id'] as int?) ?? 0,
        date: (json['date'] as String?) ?? '',
        startTime: (json['start_time'] as String?) ?? '',
        endTime: (json['end_time'] as String?) ?? '',
        note: json['note'] as String?,
      );
}

class ApiVenueOrganizer {
  final String businessName;
  final String? logoUrl;

  const ApiVenueOrganizer({required this.businessName, this.logoUrl});

  factory ApiVenueOrganizer.fromJson(Map<String, dynamic> json) =>
      ApiVenueOrganizer(
        businessName: (json['business_name'] as String?) ?? '',
        logoUrl: json['logo_url'] as String?,
      );
}

/// Lightweight model returned by the list endpoint
/// (GET /api/v1/listings/venues/).
class ApiVenue {
  final String id;
  final String title;
  final String city;
  final String? area;
  final ApiVenueCategory category;
  final bool isFeatured;
  final bool isNewThisWeek;
  final bool isTopRated;
  final String? cover;
  final double? distanceKm;

  const ApiVenue({
    required this.id,
    required this.title,
    required this.city,
    this.area,
    required this.category,
    required this.isFeatured,
    required this.isNewThisWeek,
    required this.isTopRated,
    this.cover,
    this.distanceKm,
  });

  factory ApiVenue.fromJson(Map<String, dynamic> json) => ApiVenue(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] as String?) ?? '',
        city: (json['city'] as String?) ?? '',
        area: json['area'] as String?,
        category: json['category'] != null
            ? ApiVenueCategory.fromJson(json['category'] as Map<String, dynamic>)
            : const ApiVenueCategory(id: 0, name: '', slug: ''),
        isFeatured: (json['is_featured'] as bool?) ?? false,
        isNewThisWeek: (json['is_new_this_week'] as bool?) ?? false,
        isTopRated: (json['is_top_rated'] as bool?) ?? false,
        cover: json['cover'] as String?,
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
      );
}

/// Full model returned by the detail endpoint
/// (GET /api/v1/listings/venues/{listing_id}/).
class ApiVenueDetail extends ApiVenue {
  final String? description;
  final ApiVenueCategory? subcategory;
  final String? locationType;
  final String? address;
  final int? minAge;
  final int? maxAge;
  final int? minCapacity;
  final int? maxCapacity;
  final List<ApiVenueMedia> media;
  final List<ApiVenuePackage> packages;
  final List<ApiVenueAvailability> availability;
  final ApiVenueOrganizer? organizer;

  const ApiVenueDetail({
    required super.id,
    required super.title,
    required super.city,
    super.area,
    required super.category,
    required super.isFeatured,
    required super.isNewThisWeek,
    required super.isTopRated,
    super.cover,
    super.distanceKm,
    this.description,
    this.subcategory,
    this.locationType,
    this.address,
    this.minAge,
    this.maxAge,
    this.minCapacity,
    this.maxCapacity,
    required this.media,
    required this.packages,
    required this.availability,
    this.organizer,
  });

  List<ApiVenueMedia> get galleryMedia =>
      media.where((m) => m.mediaType != 'cover').toList();

  factory ApiVenueDetail.fromJson(Map<String, dynamic> json) => ApiVenueDetail(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] as String?) ?? '',
        city: (json['city'] as String?) ?? '',
        area: json['area'] as String?,
        category: json['category'] != null
            ? ApiVenueCategory.fromJson(json['category'] as Map<String, dynamic>)
            : const ApiVenueCategory(id: 0, name: '', slug: ''),
        isFeatured: (json['is_featured'] as bool?) ?? false,
        isNewThisWeek: (json['is_new_this_week'] as bool?) ?? false,
        isTopRated: (json['is_top_rated'] as bool?) ?? false,
        cover: (json['media'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .where((m) => m['media_type'] == 'cover')
            .map((m) => m['url'] as String)
            .firstOrNull,
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        description: json['description'] as String?,
        subcategory: json['subcategory'] != null
            ? ApiVenueCategory.fromJson(
                json['subcategory'] as Map<String, dynamic>)
            : null,
        locationType: json['location_type'] as String?,
        address: json['address'] as String?,
        minAge: json['min_age'] as int?,
        maxAge: json['max_age'] as int?,
        minCapacity: json['min_capacity'] as int?,
        maxCapacity: json['max_capacity'] as int?,
        media: (json['media'] as List? ?? [])
            .map((m) => ApiVenueMedia.fromJson(m as Map<String, dynamic>))
            .toList(),
        packages: (json['packages'] as List? ?? [])
            .map((p) => ApiVenuePackage.fromJson(p as Map<String, dynamic>))
            .toList(),
        availability: (json['availability'] as List? ?? [])
            .map((a) => ApiVenueAvailability.fromJson(a as Map<String, dynamic>))
            .toList(),
        organizer: json['organizer'] != null
            ? ApiVenueOrganizer.fromJson(
                json['organizer'] as Map<String, dynamic>)
            : null,
      );
}

class ApiVenuesPage {
  final int count;
  final int page;
  final int pageSize;
  final List<ApiVenue> results;

  const ApiVenuesPage({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.results,
  });

  factory ApiVenuesPage.fromJson(Map<String, dynamic> json) => ApiVenuesPage(
        count: (json['count'] as int?) ?? 0,
        page: (json['page'] as int?) ?? 1,
        pageSize: (json['page_size'] as int?) ?? 10,
        results: ((json['results'] as List?) ?? [])
            .map((e) => ApiVenue.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
