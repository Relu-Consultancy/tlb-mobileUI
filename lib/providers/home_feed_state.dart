import 'package:flutter/foundation.dart';
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

  static Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_loaded && !force) return;
    _loading = true;
    try {
      final sections = await HomeFeedService.fetchSections();
      final map = <String, List<EventModel>>{};
      for (final s in sections) {
        map[s.section] = s.listings.map((l) => l.toEventModel()).toList();
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
