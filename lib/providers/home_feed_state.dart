import 'package:flutter/foundation.dart';
import '../core/listing_schedule.dart';
import '../models/event_model.dart';
import '../services/home_feed_service.dart';

/// Holds the real homepage feed: each section key → ordered list of
/// [EventModel] cards, built directly from GET /api/v1/homepage/sections/
/// (which now returns the full card fields per listing).
///
/// Sections with no listings resolve to an empty list (the section widgets and
/// the spotlight banner hide themselves). [version] bumps whenever the feed
/// (re)loads so the section widgets — built before the fetch completes —
/// rebuild reactively.
class HomeFeedState {
  HomeFeedState._();

  static final ValueNotifier<int> version = ValueNotifier<int>(0);
  static final Map<String, List<EventModel>> _sections = {};
  static bool _loading = false;
  static bool _loaded = false;

  /// Cards for a section key (e.g. `'hot_picks'`, `'spotlight'`); empty when none.
  static List<EventModel> section(String key) => _sections[key] ?? const [];

  /// True once a fetch has come back with a usable feed. Sections show their
  /// mock set until then, and if the fetch could not reach the API at all, so
  /// a slow connection or an outage shows the screen it always did rather
  /// than a blank page.
  static bool get isLoaded => _loaded;

  /// The feed's cards for [key], or [fallback] while there is no feed.
  static List<EventModel> sectionOr(String key, List<EventModel> fallback) =>
      _loaded ? section(key) : fallback;

  static Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_loaded && !force) return;
    _loading = true;
    try {
      final sections = await HomeFeedService.fetchSections();
      final map = <String, List<EventModel>>{};
      for (final s in sections) {
        // Hero first, then the rest. Home's rails have no banner slot, and
        // reading `listings` alone would drop the hero outright — the API
        // removes it from that array.
        map[s.section] = s.ordered
            // A finished event or program has nothing left to book. A no-op
            // for classes/venues, whose end_datetime is always null here.
            .where((l) => !ListingSchedule.hasEnded(l.endDatetime))
            .map((l) => l.toEventModel())
            .toList();
      }
      _sections
        ..clear()
        ..addAll(map);
      _loaded = true;
      version.value++;
    } catch (_) {
      // Leave whatever we have; empty sections just stay hidden.
    } finally {
      _loading = false;
    }
  }
}
