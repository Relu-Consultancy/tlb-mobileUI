import '../core/listing_languages.dart';
import 'api_category_model.dart';
import 'api_listing_terms.dart';

class ApiProgramTag {
  final int id;
  final String name;
  final String slug;

  const ApiProgramTag({required this.id, required this.name, required this.slug});

  factory ApiProgramTag.fromJson(Map<String, dynamic> json) => ApiProgramTag(
        id: json['id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
      );
}

class ApiProgramBatch {
  final int id;
  final String name;
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
  final String? fee;
  final int? totalSeats;
  final bool isActive;
  final List<String> daysOfWeek;

  const ApiProgramBatch({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.fee,
    this.totalSeats,
    required this.isActive,
    required this.daysOfWeek,
  });

  factory ApiProgramBatch.fromJson(Map<String, dynamic> json) => ApiProgramBatch(
        id: json['id'] as int,
        name: json['name'] as String,
        startDate: json['start_date'] as String?,
        endDate: json['end_date'] as String?,
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
        fee: json['fee']?.toString(),
        totalSeats: json['total_seats'] as int?,
        isActive: json['is_active'] as bool? ?? false,
        daysOfWeek: (json['days_of_week'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
}

class ApiProgramMedia {
  final int id;
  final String mediaType;
  final String url;

  const ApiProgramMedia({
    required this.id,
    required this.mediaType,
    required this.url,
  });

  factory ApiProgramMedia.fromJson(Map<String, dynamic> json) => ApiProgramMedia(
        id: (json['id'] as num?)?.toInt() ?? 0,
        mediaType: (json['media_type'] as String?) ?? '',
        url: (json['url'] as String?) ?? '',
      );
}

class ApiProgramOrganizer {
  final String businessName;
  final String? logoUrl;
  final String? partnerId;

  const ApiProgramOrganizer({required this.businessName, this.logoUrl, this.partnerId});

  factory ApiProgramOrganizer.fromJson(Map<String, dynamic> json) =>
      ApiProgramOrganizer(
        businessName: json['business_name'] as String,
        logoUrl: json['logo_url'] as String?,
        partnerId: json['partner_id'] as String?,
      );
}

class ApiProgram {
  final String id;
  final String title;
  final String? shortDescription;
  final String? programFormat;
  final String? deliveryMode;
  final String? city;
  final int? minAge;
  final int? maxAge;
  final ApiCategory? category;
  final bool isFeatured;
  final bool isNewThisWeek;
  final bool isTopRated;
  final String? cover;
  final String? feeFrom;
  final double? distanceKm;
  final double averageRating;
  final int totalReviews;

  /// Earliest active batch's start.
  final DateTime? startDatetime;

  /// Latest active batch's end — a program is over only once every batch is,
  /// unlike an event's single start/end. Null if the program has no batches
  /// with an end date. See [ListingSchedule.hasEnded].
  final DateTime? endDatetime;

  const ApiProgram({
    required this.id,
    required this.title,
    this.shortDescription,
    this.programFormat,
    this.deliveryMode,
    this.city,
    this.minAge,
    this.maxAge,
    this.category,
    this.isFeatured = false,
    this.isNewThisWeek = false,
    this.isTopRated = false,
    this.cover,
    this.feeFrom,
    this.distanceKm,
    required this.averageRating,
    required this.totalReviews,
    this.startDatetime,
    this.endDatetime,
  });

  factory ApiProgram.fromJson(Map<String, dynamic> json) => ApiProgram(
        id: json['id'] as String,
        title: json['title'] as String,
        shortDescription: json['short_description'] as String?,
        programFormat: json['program_format'] as String?,
        deliveryMode: json['delivery_mode'] as String?,
        city: json['city'] as String?,
        minAge: json['min_age'] as int?,
        maxAge: json['max_age'] as int?,
        category: json['category'] != null
            ? ApiCategory.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        isFeatured: json['is_featured'] as bool? ?? false,
        isNewThisWeek: json['is_new_this_week'] as bool? ?? false,
        isTopRated: json['is_top_rated'] as bool? ?? false,
        cover: json['cover'] as String?,
        feeFrom: json['fee_from']?.toString(),
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: json['total_reviews'] as int? ?? 0,
        startDatetime:
            DateTime.tryParse(json['start_datetime']?.toString() ?? ''),
        endDatetime:
            DateTime.tryParse(json['end_datetime']?.toString() ?? ''),
      );

  String get displayAgeRange {
    if (minAge != null && maxAge != null) return '$minAge–$maxAge years';
    if (minAge != null) return '$minAge+ years';
    return '';
  }
}

class ApiProgramDetail extends ApiProgram {
  final String? description;
  final String? area;
  /// Languages the listing is delivered in, as picked by the partner.
  final List<String> languages;

  /// Free text from the partner's "Other" language box; null when unused.
  final String? otherLanguage;

  /// Ready-to-show label, or null when no language was set at all.
  String? get languageLabel =>
      ListingLanguages.label(languages, otherLanguage);

  final String? address;
  final int? maxCapacity;
  final int? totalHours;
  final int? moduleCount;
  final String bookingType;
  final ApiCategory? subcategory;
  final List<ApiProgramTag> tags;
  final List<ApiProgramBatch> batches;
  final List<Map<String, String>> faqs;
  final List<ApiProgramMedia> media;
  final ApiProgramOrganizer? organizer;
  final String? cancellationPolicy;
  final String? refundPolicy;

  /// Terms & Conditions object returned by the API. Null when the
  /// partner has not set any.
  final ApiListingTerms? terms;

  /// Partner-set label shown before booking. Defaults to true when the API
  /// omits it. Informational only — it does not decide whether a cancellation
  /// actually issues a refund.
  final bool isRefundable;

  const ApiProgramDetail({
    required super.id,
    required super.title,
    super.shortDescription,
    super.programFormat,
    super.deliveryMode,
    super.city,
    super.minAge,
    super.maxAge,
    super.category,
    super.isFeatured,
    super.isNewThisWeek,
    super.isTopRated,
    super.cover,
    super.feeFrom,
    super.distanceKm,
    required super.averageRating,
    required super.totalReviews,
    super.startDatetime,
    super.endDatetime,
    this.description,
    this.area,
    this.address,
    this.languages = const [],
    this.otherLanguage,
    this.maxCapacity,
    this.totalHours,
    this.moduleCount,
    required this.bookingType,
    this.subcategory,
    required this.tags,
    required this.batches,
    required this.faqs,
    required this.media,
    this.organizer,
    this.cancellationPolicy,
    this.refundPolicy,
    this.terms,
    this.isRefundable = true,
  });

  factory ApiProgramDetail.fromJson(Map<String, dynamic> json) {
    return ApiProgramDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      shortDescription: json['short_description'] as String?,
      programFormat: json['program_format'] as String?,
      deliveryMode: json['delivery_mode'] as String?,
      city: json['city'] as String?,
      minAge: json['min_age'] as int?,
      maxAge: json['max_age'] as int?,
      category: json['category'] != null
          ? ApiCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      isFeatured: json['is_featured'] as bool? ?? false,
      isNewThisWeek: json['is_new_this_week'] as bool? ?? false,
      isTopRated: json['is_top_rated'] as bool? ?? false,
      // In details response, they might return media array rather than 'cover' directly,
      // but if 'cover' is present we use it, otherwise fallback to finding the first cover media.
      cover: json['cover'] as String? ?? 
        (json['media'] as List?)?.whereType<Map<String, dynamic>>().where((m) => m['media_type'] == 'cover').map((m) => m['url'] as String?).whereType<String>().firstOrNull,
      feeFrom: json['fee_from']?.toString() ??
        (json['batches'] as List?)?.whereType<Map<String, dynamic>>().where((b) => b['is_active'] == true).map((b) => b['fee']?.toString()).firstOrNull,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      startDatetime:
          DateTime.tryParse(json['start_datetime']?.toString() ?? ''),
      endDatetime: DateTime.tryParse(json['end_datetime']?.toString() ?? ''),
      description: json['description'] as String?,
      area: json['area'] as String?,
      languages: ListingLanguages.parse(json),
      otherLanguage: ListingLanguages.parseOther(json),
      address: json['address'] as String?,
      maxCapacity: json['max_capacity'] as int?,
      totalHours: json['total_hours'] as int?,
      moduleCount: json['module_count'] as int?,
      bookingType: (json['booking_type'] as String?) ??
          ((json['service'] as Map<String, dynamic>?)?['booking_type'] as String?) ??
          'enquiry',
      subcategory: json['subcategory'] != null
          ? ApiCategory.fromJson(json['subcategory'] as Map<String, dynamic>)
          : null,
      tags: (json['tags'] as List?)
              ?.map((e) => ApiProgramTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      batches: (json['batches'] as List?)
              ?.map((e) => ApiProgramBatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      faqs: (json['faqs'] as List?)
              ?.map((e) => {
                    'question': (e['question'] as String?) ?? '',
                    'answer': (e['answer'] as String?) ?? '',
                  })
              .toList() ??
          [],
      media: (json['media'] as List?)
              ?.map((e) => ApiProgramMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      organizer: json['organizer'] != null
          ? ApiProgramOrganizer.fromJson(json['organizer'] as Map<String, dynamic>)
          : null,
      cancellationPolicy: json['cancellation_policy'] as String?,
      refundPolicy: json['refund_policy'] as String?,
      terms: ApiListingTerms.fromJson(json['terms']),
      isRefundable: (json['is_refundable'] as bool?) ?? true,
    );
  }
}

class ApiProgramsPage {
  final int count;
  final int page;
  final int pageSize;
  final List<ApiProgram> results;

  const ApiProgramsPage({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.results,
  });

  factory ApiProgramsPage.fromJson(Map<String, dynamic> json) => ApiProgramsPage(
        count: (json['count'] as int?) ?? 0,
        page: (json['page'] as int?) ?? 1,
        pageSize: (json['page_size'] as int?) ?? 10,
        results: ((json['results'] as List?) ?? [])
            .map((e) => ApiProgram.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
