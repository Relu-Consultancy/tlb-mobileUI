import 'package:flutter/foundation.dart';

import '../core/listing_schedule.dart';
import '../models/event_model.dart';
import '../services/home_feed_service.dart';

/// One discovery screen's curated feed: section key → ordered [EventModel]
/// cards, built from `GET /api/v1/listings/{screen}/sections/`.
///
/// The mirror of [HomeFeedState] for the four browse tabs. One instance per
/// screen rather than one class each, so wiring Classes, Programs and Venues
/// later is a field, not a copy.
///
/// [version] bumps whenever the feed loads, so rails built before the fetch
/// lands rebuild reactively.
class DiscoveryFeedState {
  DiscoveryFeedState._(this.screen);

  /// `events`, `classes`, `programs`, `venues` — the screen segment of the
  /// endpoint path.
  final String screen;

  static final DiscoveryFeedState events = DiscoveryFeedState._('events');
  static final DiscoveryFeedState classes = DiscoveryFeedState._('classes');
  static final DiscoveryFeedState programs = DiscoveryFeedState._('programs');
  static final DiscoveryFeedState venues = DiscoveryFeedState._('venues');

  final ValueNotifier<int> version = ValueNotifier<int>(0);
  final Map<String, List<EventModel>> _sections = {};
  /// Insertion-ordered, so [heroes] follows the order the API listed the
  /// sections in.
  final Map<String, EventModel> _heroes = {};
  bool _loading = false;
  bool _loaded = false;
  bool _failed = false;

  /// True once a fetch has come back with a usable feed.
  bool get isLoaded => _loaded;

  /// True when the last attempt could not reach the API. Callers show their
  /// previous content rather than an empty screen — a network blip should not
  /// look like an empty catalogue.
  bool get hasFailed => _failed;

  /// Cards for a section key (e.g. `'trending_events'`); empty when the
  /// section holds nothing or the feed has not loaded.
  ///
  /// Excludes the section's hero, which the API already keeps out of its
  /// `listings` array — read [hero] for that one.
  List<EventModel> section(String key) => _sections[key] ?? const [];

  /// The listing an admin flagged as this section's feature, or null when
  /// none is set.
  EventModel? hero(String key) => _heroes[key];

  /// Every section's hero, in the order the API listed the sections.
  ///
  /// These are what the screen's top banner carousel shows: a hero is the
  /// screen's featured listing, not a second style of card inside a rail.
  List<EventModel> get heroes => List.unmodifiable(_heroes.values);

  /// True when the section has nothing to draw at all, hero included.
  bool isSectionEmpty(String key) =>
      hero(key) == null && section(key).isEmpty;

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_loaded && !force) return;
    _loading = true;
    try {
      final sections = await HomeFeedService.fetchScreenSections(screen);
      final map = <String, List<EventModel>>{};
      final heroes = <String, EventModel>{};
      for (final s in sections) {
        // A finished event or program has nothing left to book. A no-op for
        // classes and venues, whose end_datetime is always null here.
        map[s.section] = s.listings
            .where((l) => !ListingSchedule.hasEnded(l.endDatetime))
            .map((l) => l.toEventModel())
            .toList();
        final h = s.hero;
        if (h != null && !ListingSchedule.hasEnded(h.endDatetime)) {
          heroes[s.section] = h.toEventModel();
        }
      }
      _sections
        ..clear()
        ..addAll(map);
      _heroes
        ..clear()
        ..addAll(heroes);
      _loaded = true;
      _failed = false;
    } catch (_) {
      _failed = true;
    } finally {
      _loading = false;
      version.value++;
    }
  }
}
