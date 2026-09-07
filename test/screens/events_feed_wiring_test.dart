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

    test('TC_S_EF_006 — the featured listings fill the top banner', () {
      // A hero is the screen's featured listing, shown in the banner
      // carousel at the top — not a second style of card inside a rail,
      // which reformatted the section it sat in.
      expect(src, contains('events: _banners,'));
      expect(src, contains('feed.heroes'));
      expect(src, isNot(contains('SectionHeroCard')));
    });

    test('TC_S_EF_007 — the banner falls back to the mock slides', () {
      // No hero is flagged on most sections, and none before the feed
      // lands; an empty carousel would leave the screen headless.
      expect(src, contains('DummyData.eventsScreenBanners'));
      expect(src, contains('feed.heroes.isEmpty'));
    });

    test('TC_S_EF_008 — the rails keep their own card widgets', () {
      // Each section's card design is its own; nothing generic replaces it.
      for (final card in const [
        'TrendingEventCard(',
        'WeekendEventCard(',
        'HolidaySpecialCard(',
        'PartnerPortraitCard(',
        'NewOnTlbCard(',
        'OnlineEventCard(',
      ]) {
        expect(src, contains(card), reason: card);
      }
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
      expect(DiscoveryFeedState.venues.heroes, isEmpty);
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
