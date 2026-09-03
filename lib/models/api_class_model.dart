import '../core/listing_languages.dart';
import 'api_category_model.dart';
import 'api_listing_terms.dart';

class ApiClassAgeGroup {
  final int? minAge;
  final int? maxAge;

  const ApiClassAgeGroup({this.minAge, this.maxAge});

  factory ApiClassAgeGroup.fromJson(Map<String, dynamic> json) =>
      ApiClassAgeGroup(
        minAge: json['min_age'] as int?,
        maxAge: json['max_age'] as int?,
      );

  String get displayRange {
    if (minAge != null && maxAge != null) return '$minAge–$maxAge years';
    if (minAge != null) return '$minAge+ years';
    return '';
  }
}

class ApiClassBatch {
  final int id;
  final String name;
  final List<String> days;
  final String startTime;
  final String endTime;
  final int capacity;
  final bool isActive;
  final String? fee;

  /// The date this batch actually begins, or null when the partner has not
  /// set one. There is no matching `end_date` on this schema — a class batch
  /// is an open-ended recurring schedule, not a bounded run.
  final DateTime? startDate;

  const ApiClassBatch({
    required this.id,
    required this.name,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.isActive,
    this.fee,
    this.startDate,
  });

  factory ApiClassBatch.fromJson(Map<String, dynamic> json) => ApiClassBatch(
        id: json['id'] as int,
        name: json['name'] as String,
        days: (json['days'] as List?)?.map((e) => e.toString()).toList() ?? [],
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        capacity: json['capacity'] as int,
        isActive: json['is_active'] as bool,
        fee: json['fee']?.toString(),
        startDate: DateTime.tryParse((json['start_date'] as String?) ?? ''),
      );
}

class ApiClassMedia {
  final int id;
  final String mediaType;
  final String url;

  const ApiClassMedia({
    required this.id,
    required this.mediaType,
    required this.url,
  });

  factory ApiClassMedia.fromJson(Map<String, dynamic> json) => ApiClassMedia(
        id: (json['id'] as num?)?.toInt() ?? 0,
        mediaType: (json['media_type'] as String?) ?? '',
        url: (json['url'] as String?) ?? '',
      );
}

class ApiClassOrganizer {
  final String businessName;
  final String? logoUrl;
  final String? partnerId;

  const ApiClassOrganizer({required this.businessName, this.logoUrl, this.partnerId});

  factory ApiClassOrganizer.fromJson(Map<String, dynamic> json) =>
      ApiClassOrganizer(
        businessName: json['business_name'] as String,
        logoUrl: json['logo_url'] as String?,
        partnerId: json['partner_id'] as String?,
      );
}

class ApiClass {
  final String id;
  final String title;
  final String? shortDescription;
  final String status;
  final bool isLive;
  final ApiCategory category;
  final int activeBatchesCount;
  final String? coverUrl;
  final double averageRating;
  final int totalReviews;

  /// A class has no end date — ClassBatch carries a daily start_time/end_time
  /// but no end_date column, so there is no date on which a class finishes
  /// (it is an open-ended recurring schedule). The partner-controlled signal
  /// for "not currently bookable" is this flag instead: true when they have
  /// paused the listing.
  final bool isPaused;

  const ApiClass({
    required this.id,
    required this.title,
    this.shortDescription,
    required this.status,
    required this.isLive,
    required this.category,
    required this.activeBatchesCount,
    this.coverUrl,
    required this.averageRating,
    required this.totalReviews,
    this.isPaused = false,
  });

  factory ApiClass.fromJson(Map<String, dynamic> json) => ApiClass(
        id: json['id'] as String,
        title: json['title'] as String,
        shortDescription: json['short_description'] as String?,
        status: json['status'] as String,
        isLive: json['is_live'] as bool? ?? false,
        category: ApiCategory.fromJson(json['category'] as Map<String, dynamic>),
        activeBatchesCount: json['active_batches_count'] as int? ?? 0,
        coverUrl: json['cover_url'] as String?,
        averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: json['total_reviews'] as int? ?? 0,
        isPaused: json['is_paused'] as bool? ?? false,
      );
}

class ApiClassDetail extends ApiClass {
  final String? description;
  final ApiClassOrganizer? organizer;
  final ApiCategory? subcategory;
  final String format;
  final String mode;
  final ApiClassAgeGroup? ageGroup;
  final List<String> tags;
  final String city;
  final String? area;
  /// Languages the listing is delivered in, as picked by the partner.
  final List<String> languages;

  /// Free text from the partner's "Other" language box; null when unused.
  final String? otherLanguage;

  /// Ready-to-show label, or null when no language was set at all.
  String? get languageLabel =>
      ListingLanguages.label(languages, otherLanguage);

  final String? address;
  final String? meetingLink;
  final String? teaserVideoUrl;
  final String? cancellationPolicy;
  final String? refundPolicy;

  /// Terms & Conditions object returned by the API. Null when the
  /// partner has not set any.
  final ApiListingTerms? terms;

  /// Partner-set label shown before booking. Defaults to true when the API
  /// omits it. Informational only — it does not decide whether a cancellation
  /// actually issues a refund.
  final bool isRefundable;
  final List<Map<String, String>> faqs;
  final String bookingType;
  final double? price;
  final List<ApiClassBatch> batches;
  final List<ApiClassMedia> media;

  const ApiClassDetail({
    required super.id,
    required super.title,
    super.shortDescription,
    required super.status,
    required super.isLive,
    required super.category,
    required super.activeBatchesCount,
    super.coverUrl,
    required super.averageRating,
    required super.totalReviews,
    super.isPaused,
    this.description,
    this.organizer,
    this.subcategory,
    required this.format,
    required this.mode,
    this.ageGroup,
    required this.tags,
    required this.city,
    this.area,
    this.address,
    this.languages = const [],
    this.otherLanguage,
    this.meetingLink,
    this.teaserVideoUrl,
    this.cancellationPolicy,
    this.refundPolicy,
    this.terms,
    this.isRefundable = true,
    required this.faqs,
    required this.bookingType,
    this.price,
    required this.batches,
    required this.media,
  });

  factory ApiClassDetail.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>? ?? {};
    
    return ApiClassDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      shortDescription: json['short_description'] as String?,
      status: json['status'] as String,
      isLive: json['is_live'] as bool? ?? false,
      // Top-level on the detail response, unlike most other class fields
      // which are nested under `service`.
      isPaused: json['is_paused'] as bool? ?? false,
      category: service['category'] != null
          ? ApiCategory.fromJson(service['category'] as Map<String, dynamic>)
          : const ApiCategory(id: 0, name: '', slug: '', sortOrder: 0, subcategories: []),
      activeBatchesCount: service['active_batches_count'] as int? ?? 0,
      coverUrl: (service['media'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .where((m) => m['media_type'] == 'cover')
          .map((m) => m['url'] as String?)
          .whereType<String>()
          .firstOrNull,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      description: json['description'] as String?,
      organizer: json['organizer'] != null
          ? ApiClassOrganizer.fromJson(json['organizer'] as Map<String, dynamic>)
          : null,
      subcategory: service['subcategory'] != null
          ? ApiCategory.fromJson(service['subcategory'] as Map<String, dynamic>)
          : null,
      format: (service['format'] as String?) ?? '',
      mode: (service['mode'] as String?) ?? '',
      ageGroup: service['age_group'] != null
          ? ApiClassAgeGroup.fromJson(service['age_group'] as Map<String, dynamic>)
          : null,
      tags: (service['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      city: (service['city'] as String?) ?? '',
      area: service['area'] as String?,
      languages: ListingLanguages.parse(json, nested: service),
      otherLanguage:
          ListingLanguages.parseOther(json, nested: service),
      address: service['address'] as String?,
      meetingLink: service['meeting_link'] as String?,
      teaserVideoUrl: service['teaser_video_url'] as String?,
      cancellationPolicy: service['cancellation_policy'] as String?,
      refundPolicy: service['refund_policy'] as String?,
      terms: ApiListingTerms.fromJson(json['terms']),
      isRefundable: (json['is_refundable'] as bool?) ?? true,
      faqs: (service['faqs'] as List?)
              ?.map((e) => {
                    'question': (e['question'] as String?) ?? '',
                    'answer': (e['answer'] as String?) ?? '',
                  })
              .toList() ??
          [],
      bookingType: (service['booking_type'] as String?) ?? 'enquiry',
      price: (service['price'] as num?)?.toDouble(),
      batches: (service['batches'] as List?)
              ?.map((e) => ApiClassBatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      media: (service['media'] as List?)
              ?.map((e) => ApiClassMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ApiClassesPage {
  final int count;
  final int page;
  final int pageSize;
  final List<ApiClass> results;

  const ApiClassesPage({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.results,
  });

  factory ApiClassesPage.fromJson(Map<String, dynamic> json) => ApiClassesPage(
        count: (json['count'] as int?) ?? 0,
        page: (json['page'] as int?) ?? 1,
        pageSize: (json['page_size'] as int?) ?? 10,
        results: ((json['results'] as List?) ?? [])
            .map((e) => ApiClass.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
