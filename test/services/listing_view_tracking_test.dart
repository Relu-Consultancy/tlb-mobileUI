import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/listing_source.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/services/activity_service.dart';

/// Listing View tracking (`POST /activity/track/`, `event_type: view_listing`)
/// powers a partner's view counts, view-to-enquiry conversion and "Where
/// customers come from". It must fire once per open of a detail screen, carry
/// the listing's UUID, and tag the surface the user came from.
const _uuid = '550e8400-e29b-41d4-a716-446655440000';

/// A stand-in surface, tagged exactly as the real screens tag themselves.
class _Surface extends StatelessWidget {
  final String? source;
  final String listingId;
  const _Surface({this.source, this.listingId = _uuid});

  @override
  Widget build(BuildContext context) {
    if (source != null) ListingSource.mark(context, source!);
    return Scaffold(
      body: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => _Detail(listingId: listingId)),
        ),
        child: const Text('open'),
      ),
    );
  }
}

/// Mirrors the hook in the four detail screens (guarded by TC_A_VIEW_008).
class _Detail extends StatefulWidget {
  final String listingId;
  const _Detail({required this.listingId});
  @override
  State<_Detail> createState() => _DetailState();
}

class _DetailState extends State<_Detail> {
  bool _viewTracked = false;
  int builds = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewTracked) return;
    _viewTracked = true;
    ActivityService.trackListingView(
      listingId: widget.listingId,
      source: ListingSource.originOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    ListingSource.mark(context, ListingSource.recommendation);
    builds++;
    return Scaffold(
      body: Column(children: [
        TextButton(
            onPressed: () => setState(() {}), child: const Text('rebuild')),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const _Detail(listingId: _uuid)),
          ),
          child: const Text('similar'),
        ),
      ]),
    );
  }
}

void main() {
  late List<Map<String, dynamic>> sent;

  setUp(() {
    sent = [];
    // Clears the rate-limit window and de-duplication between tests.
    ActivityService.resetForTest();
    ActivityService.send = (body) async => sent.add(body);
    AuthState.isLoggedIn.value = true;
  });

  tearDown(() => AuthState.isLoggedIn.value = false);

  Future<void> openFrom(WidgetTester tester, Widget surface) async {
    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [ListingSource.observer],
      home: surface,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('TC_A_VIEW_001 — an open reports the listing and its source',
      (tester) async {
    await openFrom(tester, const _Surface(source: ListingSource.search));

    expect(sent, [
      {
        'event_type': 'view_listing',
        'listing_id': _uuid,
        'platform': 'app',
        'utm_source': 'search',
      }
    ]);
  });

  testWidgets('TC_A_VIEW_002 — once per open, not per rebuild', (tester) async {
    await openFrom(tester, const _Surface(source: ListingSource.browse));
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('rebuild'));
      await tester.pump();
    }
    expect(sent, hasLength(1));
  });

  testWidgets('TC_A_VIEW_003 — opening it again is a second view',
      (tester) async {
    await openFrom(tester, const _Surface(source: ListingSource.homepage));
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(sent, hasLength(2));
  });

  testWidgets('TC_A_VIEW_004 — a listing opened from another is a recommendation',
      (tester) async {
    await openFrom(tester, const _Surface(source: ListingSource.category));
    await tester.tap(find.text('similar').last);
    await tester.pumpAndSettle();

    expect(sent.map((e) => e['utm_source']), ['category', 'recommendation']);
  });

  testWidgets('TC_A_VIEW_005 — an untagged surface sends no source at all',
      (tester) async {
    // Blank counts as organic/direct; "unknown" or "" would fragment it.
    await openFrom(tester, const _Surface());

    expect(sent.single.containsKey('utm_source'), isFalse);
  });

  testWidgets('TC_A_VIEW_006 — signed out, nothing is sent', (tester) async {
    AuthState.isLoggedIn.value = false;
    await openFrom(tester, const _Surface(source: ListingSource.search));
    expect(sent, isEmpty);
  });

  testWidgets('TC_A_VIEW_007 — a placeholder card with no real id is not sent',
      (tester) async {
    await openFrom(tester,
        const _Surface(source: ListingSource.homepage, listingId: ''));
    expect(sent, isEmpty);
  });

  test('TC_A_VIEW_008 — event, class and program detail report the view',
      () {
    for (final type in ['event', 'class', 'program']) {
      final src = File('lib/screens/${type}_detail_screen.dart')
          .readAsStringSync();
      expect(src, contains('ActivityService.trackListingView('),
          reason: '$type detail screen does not report a Listing View');
      expect(src, contains('_source = ListingSource.originOf(context)'),
          reason: '$type detail screen drops the source');
      // The same source goes on the event and on the detail GET.
      expect(RegExp(r'source: _source').allMatches(src), hasLength(2),
          reason: '$type detail screen sends the source on only one of them');
      expect(src, contains('if (_viewTracked) return;'),
          reason: '$type detail screen could report more than once per open');
    }
  });

  // The backend records a venue view itself (on GET /listings/venues/{id}/);
  // one from the app as well would count every venue view twice.
  test('TC_A_VIEW_011 — venue detail does not report a view', () {
    final src = File('lib/screens/venue_detail_screen.dart').readAsStringSync();
    expect(src, isNot(contains('ActivityService.trackListingView(')));
  });

  test('TC_A_VIEW_009 — every listing surface tags its source', () {
    const expected = {
      'home_screen': 'homepage',
      'events_screen': 'browse',
      'classes_screen': 'browse',
      'programs_screen': 'browse',
      'venues_screen': 'browse',
      'category_events_screen': 'category',
      'category_classes_screen': 'category',
      'category_programs_screen': 'category',
      'category_venues_screen': 'category',
      'format_events_screen': 'category',
      'format_programs_screen': 'category',
      'pace_classes_screen': 'category',
      'search_screen': 'search',
      'organizer_profile_screen': 'partnerProfile',
      'saved_events_screen': 'wishlist',
    };
    expected.forEach((screen, source) {
      final src = File('lib/screens/$screen.dart').readAsStringSync();
      expect(src, contains('ListingSource.mark(context, ListingSource.$source)'),
          reason: '$screen is not tagged as $source');
    });
  });

  test('TC_A_VIEW_010 — the app navigator records where routes open from', () {
    expect(File('lib/main.dart').readAsStringSync(),
        contains('navigatorObservers: [ListingSource.observer]'));
  });
}
