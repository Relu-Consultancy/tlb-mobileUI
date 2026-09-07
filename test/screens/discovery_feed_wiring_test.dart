import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/providers/discovery_feed_state.dart';

/// Home, Classes, Programs and Venues now render their curated rails from
/// their own sections feed, the same way the Events screen does: the mock set
/// stands in until the feed is in (and if it cannot be reached), an empty
/// section hides its rail, and the sections' heroes fill the top banner.
///
/// These screens fetch on open, so they cannot be reached in a widget test
/// without a network mock (the services take no injectable client). The
/// wiring is guarded at source.
void main() {
  String read(String path) => File(path).readAsStringSync();

  /// Screen file → (feed instance, section slugs, mock banner list).
  const screens = <String, (String, List<String>, String)>{
    'classes_screen.dart': (
      'classes',
      [
        'whats_everyone_joining',
        'right_around_you',
        'top_picks_for_you',
        'holiday_special',
        'build_new_skills',
        'special_focus',
      ],
      'DummyData.classesScreenBanners',
    ),
    'programs_screen.dart': (
      'programs',
      [
        'the_big_leagues',
        'make_your_weekend_count',
        'zero_to_hero',
        'the_holiday_edit',
        'for_unique_minds',
        'level_up_your_profile',
      ],
      'DummyData.programsScreenBanners',
    ),
    'venues_screen.dart': (
      'venues',
      [
        'for_the_big_days',
        'weekend_plan_sorted',
        'close_to_you',
        'out_and_about',
        'hands_on_space',
        'easy_on_the_pocket',
        'headed_to_the_mall',
        'thoughtful_spaces',
      ],
      'DummyData.venuesScreenBanners',
    ),
    'events_screen.dart': (
      'events',
      [
        'trending_events',
        'happening_this_weekend',
        'holiday_special',
        'featured_partners',
        'new_on_tlb',
        'online_events',
      ],
      'DummyData.eventsScreenBanners',
    ),
  };

  group('Discovery screens read their sections feed', () {
    screens.forEach((file, spec) {
      final (feed, slugs, banners) = spec;
      final src = read('lib/screens/$file');

      test('$file loads and releases its feed', () {
        expect(src, contains('DiscoveryFeedState.$feed.load();'));
        expect(src, contains('DiscoveryFeedState.$feed.load(force: true)'));
        expect(src, contains('version.addListener(_onFeedChanged)'));
        expect(src, contains('version.removeListener(_onFeedChanged)'));
      });

      test('$file reads every one of its API sections', () {
        for (final slug in slugs) {
          expect(src, contains("_rail('$slug'"), reason: '$file / $slug');
        }
      });

      test('$file feeds the heroes to its top banner', () {
        expect(src, contains('events: _banners,'));
        expect(src, contains('feed.heroes'));
        // ...and keeps the mock slides for when nothing is flagged.
        expect(src, contains(banners));
      });

      test('$file hides a section the feed returns empty', () {
        expect(RegExp(r'if \(_\w+\.isNotEmpty\) \.\.\.\[').allMatches(src),
            hasLength(slugs.length));
      });
    });
  });

  group('Home reads the homepage feed', () {
    const sections = <String, String>{
      'hot_picks_section.dart': 'hot_picks',
      'weekend_special_section.dart': 'weekend_specials',
      'discover_near_you_section.dart': 'discover_near_you',
      'family_feels_section.dart': 'family_feels',
      'new_on_the_block_section.dart': 'new_on_the_block',
      'parents_favorite_section.dart': 'parents_favorite',
      'stealers_section.dart': 'stealers',
      'special_needs_section.dart': 'where_every_star_shines',
      'tlb_signature_section.dart': 'tlb_signature',
    };

    sections.forEach((file, slug) {
      test('$file renders the curated listings', () {
        final src = read('lib/sections/$file');
        expect(src, contains("HomeFeedState.sectionOr('$slug'"));
        // The wiring was commented out once; it must not go back.
        expect(src, isNot(contains('// final items = HomeFeedState')));
      });
    });

    test('the screen loads the feed and repaints when it lands', () {
      final src = read('lib/screens/home_screen.dart');
      expect(src, contains('HomeFeedState.load();'));
      expect(src, contains('HomeFeedState.load(force: true)'));
      expect(src, contains('HomeFeedState.version.addListener'));
      expect(src, isNot(contains('// HomeFeedState.load')));
    });

    test('the spotlight banner shows the curated section', () {
      final src = read('lib/screens/home_screen.dart');
      expect(src, contains("HomeFeedState.sectionOr(\n"
          "                                    'spotlight',"));
    });
  });

  group('DiscoveryFeedState covers all four screens', () {
    test('each screen has its own feed on its own path', () {
      expect(
        [
          DiscoveryFeedState.events.screen,
          DiscoveryFeedState.classes.screen,
          DiscoveryFeedState.programs.screen,
          DiscoveryFeedState.venues.screen,
        ],
        ['events', 'classes', 'programs', 'venues'],
      );
    });
  });
}
