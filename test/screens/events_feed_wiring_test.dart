import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/providers/discovery_feed_state.dart';

/// The Events screen's six curated rails now come from
/// GET /api/v1/listings/events/sections/ rather than DummyData.
///
/// The screen fetches on open, so it cannot be reached in a widget test
/// without a network mock (the services take no injectable client — see
/// auth_service_test's note). The wiring is guarded at source; the feed state
/// itself is exercised directly.
void main() {
  final src = File('lib/screens/events_screen.dart').readAsStringSync();

  group('Events screen — the rails read the feed', () {
    test('TC_S_EF_001 — the feed is loaded on open and on pull-to-refresh', () {
      expect(src, contains('DiscoveryFeedState.events.load();'));
      expect(src, contains('DiscoveryFeedState.events.load(force: true)'));
    });

    test('TC_S_EF_002 — every curated rail reads its API section', () {
      // The six sections the endpoint serves for this screen.
      for (final slug in const [
        'trending_events',
        'happening_this_weekend',
        'holiday_special',
        'featured_partners',
        'new_on_tlb',
        'online_events',
      ]) {
        expect(src, contains("_rail('$slug'"), reason: slug);
      }
    });

    test('TC_S_EF_003 — no rail still indexes DummyData directly', () {
      // The category grid and the banner legitimately still do; the six
      // listing rails must not.
      for (final list in const [
        'DummyData.trendingEvents[',
        'DummyData.weekendSpecial[',
        'DummyData.holidaySpecials[',
        'DummyData.featuredPartners[',
        'DummyData.newOnTlb[',
        'DummyData.onlineEvents[',
      ]) {
        expect(src, isNot(contains(list)), reason: list);
      }
    });

    test('TC_S_EF_004 — an empty rail is not drawn', () {
      for (final rail in const [
        '_trending',
        '_thisWeekend',
        '_holiday',
        '_featuredPartners',
        '_newOnTlb',
        '_onlineEvents',
      ]) {
        expect(src, contains('if ($rail.isNotEmpty)'), reason: rail);
      }
    });

    test('TC_S_EF_006 — every section draws its hero as a banner', () {
      // The admin panel calls this slot the section's "top banner" and
      // previews it as a large featured card. Left in the rail it was just
      // another identical card, which is the same as not being featured.
      for (final slug in const [
        'trending_events',
        'happening_this_weekend',
        'holiday_special',
        'featured_partners',
        'new_on_tlb',
        'online_events',
      ]) {
        expect(src, contains("_heroBanner('$slug')"), reason: slug);
      }
      expect(src, contains('SectionHeroCard(event: hero)'));
    });

    test('TC_S_EF_007 — a hero-only section still shows', () {
      // trending_events is exactly this today: a hero and no listings.
      // Gating the section on the rail alone hid the hero entirely.
      expect(src, contains('_hasSection('));
      expect(src,
          contains("bool _hasSection(String key, List<EventModel> rail) =>"));
      expect(src, contains("_hero(key) != null || rail.isNotEmpty"));
    });

    test('TC_S_EF_005 — the screen repaints when the feed lands', () {
      // The rails are built before the fetch returns.
      expect(src, contains('version.addListener(_onFeedChanged)'));
      expect(src, contains('version.removeListener(_onFeedChanged)'));
    });
  });

  group('DiscoveryFeedState', () {
    test('TC_P_DF_001 — one instance per screen, each on its own path', () {
      expect(DiscoveryFeedState.events.screen, 'events');
      expect(DiscoveryFeedState.classes.screen, 'classes');
      expect(DiscoveryFeedState.programs.screen, 'programs');
      expect(DiscoveryFeedState.venues.screen, 'venues');
    });

    test('TC_P_DF_002 — an unknown section is empty, not null', () {
      expect(DiscoveryFeedState.venues.section('nope'), isEmpty);
      expect(DiscoveryFeedState.venues.hero('nope'), isNull);
      expect(DiscoveryFeedState.venues.isSectionEmpty('nope'), isTrue);
    });

    test('TC_P_DF_003 — a failed fetch is not reported as loaded', () async {
      // The screen falls back to its mock set while !isLoaded, so a network
      // outage must not read as "the catalogue is empty".
      final feed = DiscoveryFeedState.venues;
      expect(feed.isLoaded, isFalse);
      await feed.load();
      expect(feed.isLoaded && feed.hasFailed, isFalse);
    });

    test('TC_SVC_SEC_001 — the service builds the discovery path', () {
      final svc =
          File('lib/services/home_feed_service.dart').readAsStringSync();
      expect(svc, contains(r"'$_base/api/v1/listings/$screen/sections/'"));
      expect(svc, contains(r"'$_base/api/v1/homepage/sections/'"));
    });
  });
}
