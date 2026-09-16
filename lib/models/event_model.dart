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

  /// The listing's age range exactly as the API states it, e.g.
  /// `"5–16 years"`.
  ///
  /// Null whenever the source did not carry one. The events and programs
  /// list endpoints do (`age_group`, `min_age`/`max_age`); classes,
  /// venues, search results and the curated section feeds do not. Cards
  /// hide the age row in that case — see [ageGroupDisplay].
  final String? ageGroup;

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
    this.ageGroup,
  });

  /// Stable identifier: uses explicit id if set, otherwise title+venue hash.
  String get uniqueId => id.isNotEmpty ? id : '${title}_$venue';

  // ────────────────────────── Card meta fields ─────────────────────────
  // Age, schedule and distance as the API reports them.
  //
  // These were once invented from the listing's own id: stable per card,
  // but unrelated to the listing itself, so a card could claim
  // "Ages 5–10" while its own detail screen said "5–16 years". Each
  // now reports what the API gave or nothing at all, and the cards drop
  // the row rather than print a value that is not true.

  /// e.g. "5–16 years", or null when the API stated no range.
  String? get ageGroupDisplay {
    final a = ageGroup?.trim();
    return (a == null || a.isEmpty) ? null : a;
  }

  /// e.g. "Sat, 5 Sep 2026 · 10:30 AM", or null when the API gave no
  /// schedule. A class or a venue on the section feeds carries no
  /// `start_datetime` at all, so its card simply omits the row.
  String? get dateTimeDisplay {
    final d = (eventDate ?? '').trim();
    final t = (eventTime ?? '').trim();
    if (d.isNotEmpty && t.isNotEmpty) return '$d · $t';
    if (d.isNotEmpty) return d;
    if (t.isNotEmpty) return t;
    return null;
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
