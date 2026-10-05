import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/feed_city_filter.dart';
import 'package:tlb_mobile_ui/models/homepage_section_model.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/providers/home_feed_state.dart';
import 'package:tlb_mobile_ui/providers/location_state.dart';

HomepageListing _l(String id, String? city, {String? mode}) => HomepageListing(
      id: id,
      title: 'Listing $id',
      shortDescription: '',
      listingType: 'event',
      isTlbSignature: false,
      city: city,
      mode: mode,
    );

void main() {
  final state = LocationState();

  setUp(() {
    AuthState.isLoggedIn.value = false; // keep setCity off the network
    state.refreshGeoFeeds = () {};
  });

  tearDown(() {
    HomeFeedState.resetForTest();
    state.setCity('Mumbai');
  });

  group('FeedCityFilter', () {
    test('TC_P_FCF_001 — keeps only listings in the selected city', () {
      expect(FeedCityFilter.keep(_l('1', 'Prayagraj'), 'Prayagraj'), isTrue);
      expect(FeedCityFilter.keep(_l('2', 'Mumbai'), 'Prayagraj'), isFalse);
    });

    test('TC_P_FCF_002 — ignores case and spacing', () {
      expect(FeedCityFilter.keep(_l('1', ' prayagraj '), 'Prayagraj'), isTrue);
    });

    test('TC_P_FCF_003 — Delhi NCR cities match each other', () {
      expect(FeedCityFilter.keep(_l('1', 'Gurugram'), 'New Delhi'), isTrue);
      expect(FeedCityFilter.keep(_l('2', 'Noida'), 'Delhi NCR'), isTrue);
    });

    test('TC_P_FCF_004 — no city selected keeps everything', () {
      expect(FeedCityFilter.keep(_l('1', 'Mumbai'), null), isTrue);
      expect(FeedCityFilter.keep(_l('2', 'Pune'), ''), isTrue);
    });

    test('TC_P_FCF_005 — online listings show in every city', () {
      expect(FeedCityFilter.keep(_l('1', 'Mumbai', mode: 'online'), 'Pune'),
          isTrue);
    });

    test('TC_P_FCF_006 — a listing with no city is left out once one is set',
        () {
      expect(FeedCityFilter.keep(_l('1', null), 'Pune'), isFalse);
      expect(FeedCityFilter.keep(_l('2', ''), 'Pune'), isFalse);
    });
  });

  group('HomeFeedState in a city', () {
    final feed = {
      'spotlight': [_l('s1', 'Mumbai')],
      'hot_picks': [_l('h1', 'Mumbai'), _l('h2', 'Prayagraj')],
    };

    test('TC_P_FCF_007 — sections show only the selected city (the bug)', () {
      // Prayagraj was shown Mumbai listings: the API isn't city-aware yet.
      HomeFeedState.seedForTest(feed);
      state.setCity('Prayagraj');

      expect(HomeFeedState.section('hot_picks').map((e) => e.id), ['h2']);
      expect(HomeFeedState.section('spotlight'), isEmpty);
      expect(HomeFeedState.isEmptyForCity, isFalse);
    });

    test('TC_P_FCF_008 — a city change re-filters without a refetch', () {
      HomeFeedState.seedForTest(feed);
      state.setCity('Prayagraj');
      expect(HomeFeedState.section('hot_picks').map((e) => e.id), ['h2']);

      state.setCity('Mumbai');
      expect(HomeFeedState.section('hot_picks').map((e) => e.id), ['h1']);
      expect(HomeFeedState.section('spotlight').map((e) => e.id), ['s1']);
    });

    test('TC_P_FCF_009 — empty for a city with no curated listings', () {
      HomeFeedState.seedForTest(feed);
      state.setCity('Pune');
      expect(HomeFeedState.isEmptyForCity, isTrue);
    });

    test('TC_P_FCF_010 — never "empty for city" before the feed loads', () {
      state.setCity('Pune');
      expect(HomeFeedState.isEmptyForCity, isFalse);
    });
  });
}
