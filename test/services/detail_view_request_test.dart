import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tlb_mobile_ui/core/listing_source.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/screens/class_detail_screen.dart';
import 'package:tlb_mobile_ui/screens/event_detail_screen.dart';
import 'package:tlb_mobile_ui/screens/program_detail_screen.dart';
import 'package:tlb_mobile_ui/screens/venue_detail_screen.dart';
import 'package:tlb_mobile_ui/services/activity_service.dart';

/// The backend records a Listing View from the detail GET
/// (/listings/{events|classes|programs|venues}/{id}/) and ignores view_listing
/// on /activity/track/. Its traffic source comes from `?utm_source=` on that
/// GET — without it the view counts as organic/direct.
const _uuid = '550e8400-e29b-41d4-a716-446655440000';

EventModel _listing() => const EventModel(
      id: _uuid,
      title: 'Summer Arts Festival',
      venue: 'Mumbai',
      imagePath: 'assets/images/placeholder.png',
      price: 350,
      tag: 'Arts',
      description: 'Painting and music for kids.',
    );

/// A surface tagged exactly as the real screens tag themselves.
class _Surface extends StatelessWidget {
  final String? source;
  final Widget detail;
  const _Surface({required this.source, required this.detail});

  @override
  Widget build(BuildContext context) {
    if (source != null) ListingSource.mark(context, source!);
    return Scaffold(
      body: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => detail),
        ),
        child: const Text('open'),
      ),
    );
  }
}

void main() {
  group('ListingViewRequest', () {
    test('TC_A_DVR_001 — utm_source goes on the detail URL when known', () {
      const url = 'https://api.test/api/v1/listings/events/$_uuid/';
      expect(ListingViewRequest.uri(url, source: 'homepage').toString(),
          '$url?utm_source=homepage');
      expect(ListingViewRequest.uri(url, source: 'partner_profile')
              .queryParameters['utm_source'],
          'partner_profile');
      // Unknown: no parameter at all, which the backend counts as organic.
      expect(ListingViewRequest.uri(url).toString(), url);
      expect(ListingViewRequest.uri(url, source: '').toString(), url);
    });

    test('TC_A_DVR_002 — the platform always, the token only when given', () {
      expect(ListingViewRequest.headers(), {
        'Accept': 'application/json',
        'X-Client-Platform': 'app',
      });
      expect(ListingViewRequest.headers(token: 'abc')['Authorization'],
          'Bearer abc');
      expect(ListingViewRequest.headers(token: ''), isNot(contains('Authorization')));
    });
  });

  group('detail screens send the source on their detail GET', () {
    late List<http.Request> requests;

    setUp(() {
      requests = [];
      FlutterSecureStorage.setMockInitialValues({});
      ActivityService.resetForTest();
      ActivityService.send = (_) async {};
      AuthState.isLoggedIn.value = true;
      AuthState.accessToken = 'access-123';
    });

    tearDown(() {
      ActivityService.resetForTest();
      AuthState.isLoggedIn.value = false;
      AuthState.accessToken = null;
    });

    Future<http.Request?> openFrom(
        WidgetTester tester, String? source, Widget detail, String type) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      // A fresh navigator each time, so a previous open isn't still on top.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [ListingSource.observer],
        home: _Surface(source: source, detail: detail),
      ));
      await http.runWithClient(
        () async {
          await tester.tap(find.text('open'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
        },
        () => MockClient((req) async {
          requests.add(req);
          return http.Response('{"success": false}', 404);
        }),
      );
      return requests
          .where((r) => r.url.path == '/api/v1/listings/$type/$_uuid/')
          .firstOrNull;
    }

    final screens = <String, Widget Function()>{
      'events': () => EventDetailScreen(event: _listing()),
      'classes': () => ClassDetailScreen(event: _listing()),
      'programs': () => ProgramDetailScreen(event: _listing()),
      'venues': () => VenueDetailScreen(event: _listing()),
    };

    screens.forEach((type, build) {
      testWidgets(
          'TC_S_DVR_003 — $type detail: one GET carrying utm_source, '
          'the platform and the customer', (tester) async {
        final req = await openFrom(tester, ListingSource.homepage, build(), type);

        expect(req, isNotNull, reason: 'no detail GET for $type');
        expect(req!.url.queryParameters['utm_source'], 'homepage');
        expect(req.headers['X-Client-Platform'], 'app');
        expect(req.headers['Authorization'], 'Bearer access-123');
        expect(
          requests.where((r) => r.url.path == req.url.path),
          hasLength(1),
          reason: 'one open is one view',
        );
      });
    });

    testWidgets(
        'TC_S_DVR_004 — opened from an untagged surface, no utm_source and '
        'signed out, no token', (tester) async {
      AuthState.isLoggedIn.value = false;
      final req = await openFrom(
          tester, null, EventDetailScreen(event: _listing()), 'events');

      expect(req, isNotNull);
      expect(req!.url.queryParameters, isNot(contains('utm_source')));
      expect(req.headers, isNot(contains('Authorization')));
    });

    testWidgets('TC_S_DVR_005 — every in-app source passes through as is',
        (tester) async {
      for (final source in [
        ListingSource.search,
        ListingSource.browse,
        ListingSource.category,
        ListingSource.wishlist,
        ListingSource.partnerProfile,
      ]) {
        requests.clear();
        final req = await openFrom(
            tester, source, ClassDetailScreen(event: _listing()), 'classes');
        expect(req!.url.queryParameters['utm_source'], source);
      }
    });
  });
}
