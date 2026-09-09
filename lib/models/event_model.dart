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

  /// Which catalog this listing belongs to — `'event'`, `'class'`, `'program'`
  /// or `'venue'`. Drives which detail screen opens on tap. Defaults to event.
  final String listingType;

  /// Straight-line distance from the user, in kilometres, as computed by the
  /// API — `distance_km` on the listing endpoints.
  ///
  /// Null whenever the distance is genuinely unknown: the app had no
  /// coordinates to send, the listing has none stored, or the response came
  /// from an endpoint that does not compute it (the curated section feeds do
  /// not). Cards hide the distance row in that case rather than showing a
  /// number that means nothing — see [distanceDisplay].
  final double? distanceKm;

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
    this.listingType = 'event',
    this.distanceKm,
  });

  /// Stable identifier: uses explicit id if set, otherwise title+venue hash.
  String get uniqueId => id.isNotEmpty ? id : '${title}_$venue';

  // ───────────────────────── Mock display fields ─────────────────────────
  // Temporary, display-only values for the section cards (Age Group,
  // Date & Time, Distance). They are derived deterministically from the
  // listing's identity so each card shows a stable, sensible value without
  // touching the mock catalog. Replace these getters with real API fields
  // (age range, schedule, GPS-computed distance) when the backend is wired.

  /// Non-negative deterministic seed for picking mock values.
  int get _mockSeed => uniqueId.hashCode & 0x7fffffff;

  /// e.g. "Ages 5–10". Uses a real [ageGroup]-style value if ever present.
  String get ageGroupDisplay {
    const groups = [
      'Ages 3–6',
      'Ages 5–10',
      'Ages 8–14',
      'Ages 10+',
      'All ages',
      'Teens & up',
    ];
    return groups[_mockSeed % groups.length];
  }

  /// e.g. "Sat & Sun · 4–6 PM". Prefers the real [eventDate]/[eventTime]
  /// when the catalog provides them.
  String get dateTimeDisplay {
    final d = (eventDate ?? '').trim();
    final t = (eventTime ?? '').trim();
    if (d.isNotEmpty && t.isNotEmpty) return '$d · $t';
    if (d.isNotEmpty) return d;
    const days = [
      'Mon–Fri',
      'Sat & Sun',
      'Tue & Thu',
      'Daily',
      'Weekends',
      'Mon · Wed · Fri',
    ];
    const times = [
      '9–11 AM',
      '4–6 PM',
      '10 AM–12 PM',
      '5–7 PM',
      '3–5 PM',
      '11 AM–1 PM',
    ];
    return '${days[_mockSeed % days.length]} · ${times[(_mockSeed ~/ 7) % times.length]}';
  }

  /// e.g. "3.2 km away", or null when the distance is not known.
  ///
  /// This used to fabricate a plausible-looking figure from the listing's own
  /// id — stable per listing, but unrelated to where the user actually was,
  /// and identical for two users on opposite sides of the country. It now
  /// reports [distanceKm] and nothing else: a real measurement or no claim.
  String? get distanceDisplay {
    final km = distanceKm;
    if (km == null || km < 0) return null;
    return '${km.toStringAsFixed(1)} km away';
  }
}
