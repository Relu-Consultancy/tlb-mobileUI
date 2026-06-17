class ApiEventCategory {
  final int id;
  final String name;

  const ApiEventCategory({required this.id, required this.name});

  factory ApiEventCategory.fromJson(Map<String, dynamic> json) =>
      ApiEventCategory(
        id: json['id'] as int,
        name: json['name'] as String,
      );
}

class ApiEventAgeGroup {
  final String type; // 'static' | 'custom'
  final int? minAge;
  final int? maxAge;

  const ApiEventAgeGroup({required this.type, this.minAge, this.maxAge});

  factory ApiEventAgeGroup.fromJson(Map<String, dynamic> json) =>
      ApiEventAgeGroup(
        type: json['type'] as String,
        minAge: json['min_age'] as int?,
        maxAge: json['max_age'] as int?,
      );

  /// e.g. "6–8 years"
  String get displayRange {
    if (minAge != null && maxAge != null) return '$minAge–$maxAge years';
    if (minAge != null) return '$minAge+ years';
    return '';
  }
}

class ApiEventTicket {
  final int id;
  final String name;
  final double price;
  final int totalQuantity;
  final int availableQuantity;
  final String? description;
  final bool isDefault;

  const ApiEventTicket({
    required this.id,
    required this.name,
    required this.price,
    required this.totalQuantity,
    required this.availableQuantity,
    this.description,
    required this.isDefault,
  });

  factory ApiEventTicket.fromJson(Map<String, dynamic> json) => ApiEventTicket(
        id: json['id'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        totalQuantity: json['total_quantity'] as int,
        availableQuantity: json['available_quantity'] as int,
        description: json['description'] as String?,
        isDefault: json['is_default'] as bool,
      );
}

class ApiEventMedia {
  final int id;
  final String mediaType; // 'cover' | 'gallery' | etc.
  final String fileUrl;

  const ApiEventMedia({
    required this.id,
    required this.mediaType,
    required this.fileUrl,
  });

  factory ApiEventMedia.fromJson(Map<String, dynamic> json) => ApiEventMedia(
        id: (json['id'] as num?)?.toInt() ?? 0,
        mediaType: (json['media_type'] as String?) ?? '',
        fileUrl: (json['file_url'] as String?) ?? '',
      );
}

class ApiEventOrganizer {
  final String businessName;
  final String? logoUrl;
  final String? partnerId;

  const ApiEventOrganizer({required this.businessName, this.logoUrl, this.partnerId});

  factory ApiEventOrganizer.fromJson(Map<String, dynamic> json) =>
      ApiEventOrganizer(
        businessName: json['business_name'] as String,
        logoUrl: json['logo_url'] as String?,
        partnerId: json['partner_id'] as String?,
      );
}

/// Lightweight model returned by the list endpoint
/// (GET /api/v1/listings/events/).
class ApiEvent {
  final String id;
  final String title;
  final ApiEventCategory category;
  final ApiEventCategory? subcategory;
  final String format;
  final ApiEventAgeGroup? ageGroup;
  final String city;
  final String priceType; // 'free' | 'paid'
  final String? priceFrom; // lowest ticket price as string, null for free
  final DateTime startDatetime;
  final String? coverUrl;

  const ApiEvent({
    required this.id,
    required this.title,
    required this.category,
    this.subcategory,
    required this.format,
    this.ageGroup,
    required this.city,
    required this.priceType,
    this.priceFrom,
    required this.startDatetime,
    this.coverUrl,
  });

  factory ApiEvent.fromJson(Map<String, dynamic> json) => ApiEvent(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] as String?) ?? '',
        category: json['category'] != null
            ? ApiEventCategory.fromJson(json['category'] as Map<String, dynamic>)
            : const ApiEventCategory(id: 0, name: ''),
        subcategory: json['subcategory'] != null
            ? ApiEventCategory.fromJson(
                json['subcategory'] as Map<String, dynamic>)
            : null,
        format: (json['format'] as String?) ?? '',
        ageGroup: json['age_group'] != null
            ? ApiEventAgeGroup.fromJson(
                json['age_group'] as Map<String, dynamic>)
            : null,
        city: (json['city'] as String?) ?? '',
        priceType: (json['price_type'] as String?) ?? 'free',
        priceFrom: json['price_from']?.toString(),
        startDatetime:
            DateTime.tryParse(json['start_datetime']?.toString() ?? '') ??
                DateTime.now(),
        coverUrl: json['cover_url'] as String?,
      );
}

/// Full model returned by the detail endpoint
/// (GET /api/v1/listings/events/{listing_id}/).
class ApiEventDetail extends ApiEvent {
  final String? description;
  final String? area;
  final String? address;
  final String mode; // 'offline' | 'online' | 'hybrid'
  final int? capacity;
  final int? availableSeats;
  final DateTime? registrationDeadline;
  final DateTime? endDatetime;
  final List<ApiEventTicket> tickets;
  final List<ApiEventMedia> media;
  final ApiEventOrganizer? organizer;
  final String? cancellationPolicy;
  final String? refundPolicy;
  final List<Map<String, String>> faqs;

  const ApiEventDetail({
    required super.id,
    required super.title,
    required super.category,
    super.subcategory,
    required super.format,
    super.ageGroup,
    required super.city,
    required super.priceType,
    super.priceFrom,
    required super.startDatetime,
    super.coverUrl,
    this.description,
    this.area,
    this.address,
    required this.mode,
    this.capacity,
    this.availableSeats,
    this.registrationDeadline,
    this.endDatetime,
    required this.tickets,
    required this.media,
    this.organizer,
    this.cancellationPolicy,
    this.refundPolicy,
    this.faqs = const [],
  });

  factory ApiEventDetail.fromJson(Map<String, dynamic> json) => ApiEventDetail(
        id: json['id'] as String,
        title: json['title'] as String,
        category: ApiEventCategory.fromJson(
            json['category'] as Map<String, dynamic>),
        subcategory: json['subcategory'] != null
            ? ApiEventCategory.fromJson(
                json['subcategory'] as Map<String, dynamic>)
            : null,
        format: json['format'] as String,
        ageGroup: json['age_group'] != null
            ? ApiEventAgeGroup.fromJson(
                json['age_group'] as Map<String, dynamic>)
            : null,
        city: json['city'] as String,
        priceType: json['price_type'] as String,
        priceFrom: json['price_from'] as String?,
        startDatetime:
            DateTime.tryParse(json['start_datetime']?.toString() ?? '') ??
                DateTime.now(),
        coverUrl: (json['media'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .where((m) => m['media_type'] == 'cover')
            .map((m) => m['file_url'] as String?)
            .whereType<String>()
            .firstOrNull,
        description: json['description'] as String?,
        area: json['area'] as String?,
        address: json['address'] as String?,
        mode: json['mode'] as String,
        capacity: json['capacity'] as int?,
        availableSeats: json['available_seats'] as int?,
        registrationDeadline:
            DateTime.tryParse(json['registration_deadline']?.toString() ?? ''),
        endDatetime:
            DateTime.tryParse(json['end_datetime']?.toString() ?? ''),
        tickets: (json['tickets'] as List? ?? [])
            .map((t) => ApiEventTicket.fromJson(t as Map<String, dynamic>))
            .toList(),
        media: (json['media'] as List? ?? [])
            .map((m) => ApiEventMedia.fromJson(m as Map<String, dynamic>))
            .toList(),
        organizer: json['organizer'] != null
            ? ApiEventOrganizer.fromJson(
                json['organizer'] as Map<String, dynamic>)
            : null,
        cancellationPolicy: json['cancellation_policy'] as String?,
        refundPolicy: json['refund_policy'] as String?,
        faqs: (json['faqs'] as List?)
                ?.map((e) => {
                      'question': (e['question'] as String?) ?? '',
                      'answer': (e['answer'] as String?) ?? '',
                    })
                .toList() ??
            [],
      );
}

class ApiEventsPage {
  final int count;
  final int page;
  final int pageSize;
  final List<ApiEvent> results;

  const ApiEventsPage({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.results,
  });

  factory ApiEventsPage.fromJson(Map<String, dynamic> json) => ApiEventsPage(
        count: (json['count'] as int?) ?? 0,
        page: (json['page'] as int?) ?? 1,
        pageSize: (json['page_size'] as int?) ?? 10,
        results: ((json['results'] as List?) ?? [])
            .map((e) => ApiEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
