import '../core/date_format.dart';
import '../core/listing_languages.dart';
import '../core/time_format.dart';
import 'event_model.dart';
import '../core/secure_url.dart';

/// A single listing inside a homepage section. The homepage endpoint now
/// returns the full card fields, so cards render directly from this — no
/// separate hydration needed.
class HomepageListing {
  final String id;
  final String title;
  final String shortDescription;
  final String listingType; // 'event' | 'class' | 'program' | 'venue'
  final bool isTlbSignature;
  final String? coverUrl;
  final String? category;
  final String? city;
  final String? area;
  final String? price; // string amount; null/empty for free
  final String? priceType; // 'free' | 'paid' | ...
  final String? rating;
  final String? totalReviews;

  /// Present for every listing_type on this feed, but only ever non-null for
  /// events and programs — a class's end_datetime is always null (open-ended
  /// recurring schedule, no such date exists) and a venue carries neither
  /// field at all. See ListingSchedule's doc for the per-type breakdown.
  ///
  /// This feed does not carry a class's `is_paused` flag, so an ended-style
  /// filter here can only catch finished events/programs — a paused class
  /// still appears. Filtering that too would need the field added here.
  final DateTime? startDatetime;
  final DateTime? endDatetime;

  // ─── New fields added by backend on 9 Sep 2026 ───────────────────────────

  /// Formatted age-group string, e.g. `"5–16 years"`, from the `age_group`
  /// object every listing type now carries. Null when no restriction is set
  /// — a real, valid state, and the card omits its age row.
  final String? ageGroup;

  /// Languages the listing is delivered in. Empty when none are set.
  final List<String> languages;

  /// Free-text "other" language, populated only when [languages] contains
  /// `"other"`.
  final String? otherLanguage;

  /// A ready-to-show language label (`"Hindi, English"`, `"Other: Marathi"`,
  /// etc.), or null when no language was set at all.
  String? get languageLabel => ListingLanguages.label(languages, otherLanguage);

  /// Normalised format string — from `format` (events) or `program_format`
  /// (programs). Classes and venues always return null.
  final String? format;

  /// Normalised mode string — from `mode` (events/classes) or
  /// `delivery_mode` (programs). Venues always return null.
  final String? mode;

  /// Card-width date label extracted from the `schedule` object the backend
  /// returns. For classes/programs this is "Mon, Tue, Wed" from the earliest
  /// active batch; for venues it is the next unbooked slot's date.
  /// Events carry `start_datetime` directly, so `schedule` is null there and
  /// this field falls back to formatting [startDatetime] instead.
  final String? scheduleDate;

  /// Card-width time label from the same `schedule` object, e.g. `"4–6 PM"`.
  final String? scheduleTime;

  /// Listing latitude — null for venues (coordinates are deliberately withheld
  /// on the public venue endpoints) and when the partner has not set them.
  final double? latitude;

  /// Listing longitude — same nullability rules as [latitude].
  final double? longitude;

  /// Straight-line distance from the user in km. Present only when the section
  /// request carried `?lat=&lng=` and this listing has coordinates stored.
  /// Venues do get one: the server measures from coordinates it keeps but
  /// withholds from [latitude]/[longitude].
  final double? distanceKm;

  const HomepageListing({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.listingType,
    required this.isTlbSignature,
    this.coverUrl,
    this.category,
    this.city,
    this.area,
    this.price,
    this.priceType,
    this.rating,
    this.totalReviews,
    this.startDatetime,
    this.endDatetime,
    this.ageGroup,
    this.languages = const [],
    this.otherLanguage,
    this.format,
    this.mode,
    this.scheduleDate,
    this.scheduleTime,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  static int? _int(Object? v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse(v?.toString() ?? ''));

  static double? _double(Object? v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// `category` arrives as `{"id": 1, "name": "Arts & Crafts"}` on the
  /// discovery feeds. Reading it as a plain string stamped a whole Dart
  /// map onto the card's tag chip.
  static String? _categoryName(dynamic v) {
    if (v is Map) return _str(v['name']);
    return _str(v);
  }

  /// `age_group: {type, min_age, max_age}` as a display string, or null when
  /// no restriction is set. The backend normalised all four types to this one
  /// object (`type` is only set for events); top-level `min_age`/`max_age` is
  /// still read as a fallback so an older payload shape cannot break a card.
  static String? _parseAge(Map<String, dynamic> json) {
    int? min;
    int? max;
    final group = json['age_group'];
    if (group is Map) {
      min = _int(group['min_age']);
      max = _int(group['max_age']);
    }
    min ??= _int(json['min_age']);
    max ??= _int(json['max_age']);
    if (min != null && max != null) return '$min–$max years';
    if (min != null) return '$min+ years';
    if (max != null) return 'Up to $max years';
    return null;
  }

  /// Extracts a (dateLabel, timeLabel) pair from the compact `schedule`
  /// object the section endpoint returns for classes, programs, and venues.
  ///
  /// Shape (classes / programs): `{days: [...], start_time: "HH:MM:SS", end_time: "HH:MM:SS"}`
  /// Shape (venues):             `{date: "YYYY-MM-DD", start_time: "HH:MM:SS", end_time: "HH:MM:SS"}`
  static (String?, String?) _parseSchedule(dynamic schedule) {
    if (schedule is! Map<String, dynamic>) return (null, null);

    final dateStr = schedule['date'] as String?;
    if (dateStr != null && dateStr.isNotEmpty) {
      // Venue slot: specific date + time range.
      final d = DateTime.tryParse(dateStr);
      final dateLabel = d != null ? DateFormat.card(d.toLocal()) : null;
      final timeLabel = _timeRange(schedule['start_time'], schedule['end_time']);
      return (dateLabel, timeLabel);
    }

    // Class / program: recurring weekly days + time range.
    final rawDays = schedule['days'];
    final days = rawDays is List
        ? rawDays.whereType<String>().toList()
        : <String>[];
    final dateLabel = days.isEmpty ? null : _daysLabel(days);
    final timeLabel = _timeRange(schedule['start_time'], schedule['end_time']);
    return (dateLabel, timeLabel);
  }

  /// A recurring week as a card-width label. The three common sets get a name
  /// of their own; spelling out seven days overflows the meta column. Classes
  /// send short day names (`mon`) and programs full ones (`monday`), so both
  /// are cut to three letters before comparing.
  static String? _daysLabel(List<String> raw) {
    final set = raw
        .map((d) => d.trim().toLowerCase())
        .map((d) => d.length > 3 ? d.substring(0, 3) : d)
        .toSet();
    if (set.isEmpty) return null;
    const weekdays = {'mon', 'tue', 'wed', 'thu', 'fri'};
    const weekend = {'sat', 'sun'};
    if (set.length == 7) return 'Daily';
    if (set.length == 5 && set.containsAll(weekdays)) return 'Mon–Fri';
    if (set.length == 2 && set.containsAll(weekend)) return 'Sat & Sun';
    return DateFormat.weekdayList(raw, short: true);
  }

  /// `"4–6 PM"` from a pair of `HH:MM:SS` strings. A venue's default
  /// 00:00–23:59 slot reads as "All day".
  static String? _timeRange(Object? from, Object? to) {
    final a = from?.toString();
    final b = to?.toString();
    if (a == null || a.isEmpty) return null;
    if (a.startsWith('00:00') && (b ?? '').startsWith('23:')) return 'All day';
    final start = TimeFormat.h12(a);
    if (b == null || b.isEmpty) return start;
    final end = TimeFormat.h12(b);
    final suffix = start.split(' ').last;
    if (suffix == end.split(' ').last) {
      return '${start.substring(0, start.length - suffix.length - 1)}–$end';
    }
    return '$start–$end';
  }

  factory HomepageListing.fromJson(Map<String, dynamic> json) {
    final (schedDate, schedTime) = _parseSchedule(json['schedule']);
    return HomepageListing(
      id: json['id']?.toString() ?? '',
      title: (json['title'] as String?) ?? '',
      shortDescription: (json['short_description'] as String?) ?? '',
      listingType: (json['listing_type'] as String?) ?? 'event',
      isTlbSignature: json['is_tlb_signature'] == true,
      coverUrl: secureUrl(_str(json['cover_url'])),
      category: _categoryName(json['category']),
      city: _str(json['city']),
      area: _str(json['area']),
      price: _str(json['price']),
      priceType: _str(json['price_type']),
      rating: _str(json['rating']),
      totalReviews: _str(json['total_reviews']),
      startDatetime:
          DateTime.tryParse(json['start_datetime']?.toString() ?? ''),
      endDatetime:
          DateTime.tryParse(json['end_datetime']?.toString() ?? ''),
      ageGroup: _parseAge(json),
      languages: ListingLanguages.parse(json),
      otherLanguage: ListingLanguages.parseOther(json),
      format: _str(json['format'] ?? json['program_format']),
      mode: _str(json['mode'] ?? json['delivery_mode']),
      scheduleDate: schedDate,
      scheduleTime: schedTime,
      // Decimal columns: a number today, but DRF renders them as strings
      // under some settings, and a hard `as num?` cast would throw.
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      distanceKm: _double(json['distance_km']),
    );
  }

  /// Build the card model used by the existing home-section / banner widgets.
  EventModel toEventModel() {
    final loc = [area, city]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
    final isFree = (priceType ?? '').toLowerCase() == 'free';
    final reviews = totalReviews;

    // The compact `schedule` object wins whenever the feed sends one. It is
    // null for events, whose start_datetime already says when. A program
    // carries both, and there start_datetime is the first batch's start —
    // already in the past for a program that is running — while `schedule`
    // is its earliest active batch ("Mon–Fri · 5–8 PM"), which is what a
    // parent needs to see.
    String? dateLabel;
    String? timeLabel;
    if (scheduleDate != null || scheduleTime != null) {
      dateLabel = scheduleDate;
      timeLabel = scheduleTime;
    } else if (startDatetime != null) {
      dateLabel = DateFormat.card(startDatetime!.toLocal());
      timeLabel = _timeOf(startDatetime!);
    }

    return EventModel(
      id: id,
      title: title,
      venue: loc.isNotEmpty ? loc : shortDescription,
      imagePath: coverUrl ?? '',
      tag: category,
      description: shortDescription.isEmpty ? null : shortDescription,
      price: isFree ? null : (price != null ? double.tryParse(price!) : null),
      rating: rating != null ? double.tryParse(rating!) : null,
      // total_reviews arrives as a string ("0"); no reviews means no count.
      reviewCount: (int.tryParse(reviews ?? '') ?? 0) > 0
          ? '$reviews reviews'
          : null,
      listingType: listingType,
      eventDate: dateLabel,
      eventTime: timeLabel,
      ageGroup: ageGroup,
      distanceKm: distanceKm,
    );
  }

  static String _timeOf(DateTime dt) {
    final local = dt.toLocal();
    final minute = local.minute.toString().padLeft(2, '0');
    return TimeFormat.h12('${local.hour}:$minute');
  }
}

/// One section (e.g. `hot_picks`, `trending_events`) and its ordered
/// listings. Used for both the homepage feed and the four discovery
/// screens, which return the identical shape.
class HomepageSection {
  final String section;
  final String label;

  /// The one listing an admin flagged as this section's feature, or null
  /// when none is set — which is still the default for most sections.
  ///
  /// It is NOT repeated in [listings]: the API removes a hero from that
  /// array, so anything reading only [listings] silently loses a curated
  /// card the moment an admin sets one. Read [ordered] instead.
  final HomepageListing? hero;

  final List<HomepageListing> listings;

  const HomepageSection({
    required this.section,
    required this.label,
    this.hero,
    required this.listings,
  });

  /// Every curated listing, the hero first.
  ///
  /// These rails are rows of identical cards with no banner slot, so the
  /// hero leads the row rather than getting its own treatment — it is
  /// still the first thing seen, and nothing an admin curated is dropped.
  List<HomepageListing> get ordered =>
      hero == null ? listings : [hero!, ...listings];

  factory HomepageSection.fromJson(Map<String, dynamic> json) =>
      HomepageSection(
        section: (json['section'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
        hero: json['hero'] is Map<String, dynamic>
            ? HomepageListing.fromJson(json['hero'] as Map<String, dynamic>)
            : null,
        listings: (json['listings'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(HomepageListing.fromJson)
            .toList(),
      );
}
