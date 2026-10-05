import 'package:flutter/foundation.dart';
import '../core/feed_city_filter.dart';
import '../core/listing_schedule.dart';
import '../core/user_location.dart';
import '../models/event_model.dart';
import '../models/homepage_section_model.dart';
import 'location_state.dart';
import '../providers/auth_state.dart';
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
  /// Every curated card the API sent, with the listing it came from, so the
  /// city filter can be re-applied when the city changes without a refetch.
  static final Map<String, List<(HomepageListing, EventModel)>> _sections = {};
  static bool _loading = false;
  static bool _loaded = false;
  static bool _listeningToCity = false;

  /// Cards for a section key (e.g. `'hot_picks'`, `'spotlight'`) in the
  /// selected city; empty when none.
  static List<EventModel> section(String key) {
    final city = LocationState().cityOrNull;
    return [
      for (final (listing, card) in _sections[key] ?? const <(HomepageListing, EventModel)>[])
        if (FeedCityFilter.keep(listing, city)) card,
    ];
  }

  /// True once the feed is in and none of it is in the selected city — Home
  /// shows its empty state rather than a page of hidden sections.
  static bool get isEmptyForCity =>
      _loaded && _sections.keys.every((k) => section(k).isEmpty);

  /// Section widgets rebuild on [version], not on the city, so a city change
  /// bumps it — the filter is re-applied to the cards already held.
  static void _listenToCity() {
    if (_listeningToCity) return;
    _listeningToCity = true;
    LocationState().selectedCity.addListener(() => version.value++);
  }

  /// Replaces the feed as if a fetch had just landed.
  @visibleForTesting
  static void seedForTest(Map<String, List<HomepageListing>> sections) {
    _sections
      ..clear()
      ..addAll({
        for (final e in sections.entries)
          e.key: [for (final l in e.value) (l, l.toEventModel())],
      });
    _loaded = true;
  }

  @visibleForTesting
  static void resetForTest() {
    _sections.clear();
    _loaded = false;
  }

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
    _listenToCity();
    _loading = true;
    try {
      final sections = await HomeFeedService.fetchSections(
        // Pass the customer token so is_wishlisted is correct on every card.
        // The endpoint never 401s on an invalid/expired token — it just falls
        // back to is_wishlisted: false, so passing a stale token is safe.
        token: AuthState.accessToken,
        // Pass GPS coordinates when available so distance_km is populated
        // on each card. Both or neither — the API rejects a lone coordinate.
        lat: UserLocation.lat,
        lng: UserLocation.lng,
      );
      final map = <String, List<(HomepageListing, EventModel)>>{};
      for (final s in sections) {
        // Hero first, then the rest. Home's rails have no banner slot, and
        // reading `listings` alone would drop the hero outright — the API
        // removes it from that array.
        map[s.section] = s.ordered
            // A finished event or program has nothing left to book. A no-op
            // for classes/venues, whose end_datetime is always null here.
            .where((l) => !ListingSchedule.hasEnded(l.endDatetime))
            .map((l) => (l, l.toEventModel()))
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
