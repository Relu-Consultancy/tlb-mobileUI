import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/services/activity_service.dart';
import 'package:tlb_mobile_ui/services/auth_http.dart';

/// Tracking is analytics: whatever happens to it, the app carries on. These
/// pin the two ways it could have broken things.
const _uuid = '550e8400-e29b-41d4-a716-446655440000';

void main() {
  setUp(() {
    ActivityService.resetForTest();
    AuthState.isLoggedIn.value = true;
  });

  tearDown(() {
    ActivityService.resetForTest();
    AuthState.isLoggedIn.value = false;
    AuthState.refreshToken = null;
  });

  group('never signs the customer out', () {
    test(
        'TC_A_SAFE_001 — a 401 that cannot be refreshed is handed back, '
        'not turned into a logout', () async {
      // No refresh token: the refresh fails immediately (as it also would
      // on a momentary network drop).
      AuthState.refreshToken = null;
      var calls = 0;
      final res = await AuthHttp.send(
        (_) async {
          calls++;
          return http.Response('{"detail":"expired"}', 401);
        },
        logoutOnFailure: false,
      );

      expect(res.statusCode, 401);
      expect(calls, 1);
      expect(AuthState.isLoggedIn.value, isTrue,
          reason: 'an analytics call must never sign the customer out');
    });

    test('TC_A_SAFE_002 — tracking uses that mode', () {
      final src = File('lib/services/activity_service.dart').readAsStringSync();
      expect(src, contains('logoutOnFailure: false'));
    });

    test('TC_A_SAFE_003 — every other caller keeps the logout behaviour', () {
      // The default is unchanged: only tracking opts out.
      final src = File('lib/services/auth_http.dart').readAsStringSync();
      expect(src, contains('bool logoutOnFailure = true'));
    });
  });

  group('never throws into the screen', () {
    test(
        'TC_A_SAFE_004 — even a sender that throws synchronously cannot '
        'escape (share opens its sheet right after tracking)', () {
      ActivityService.send = (_) => throw StateError('boom');

      expect(() => ActivityService.trackListingView(listingId: _uuid),
          returnsNormally);
      expect(() => ActivityService.trackSearch('pottery'), returnsNormally);
      expect(() => ActivityService.trackFilters('search', {'mode': 'Online'}),
          returnsNormally);
      expect(() => ActivityService.trackShare(type: 'event', id: _uuid),
          returnsNormally);
    });

    test('TC_A_SAFE_005 — an asynchronous failure is swallowed too', () async {
      ActivityService.send = (_) async => throw Exception('offline');
      ActivityService.trackShare(type: 'event', id: _uuid);
      // Would surface as an unhandled error and fail the test if leaked.
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });

    test('TC_A_SAFE_006 — odd input is dropped, not thrown', () {
      final sent = <Map<String, dynamic>>[];
      ActivityService.send = (b) async => sent.add(b);

      expect(
          () => ActivityService.trackFilters('search', {
                'nan': double.nan, // not valid JSON
                'list': [1, 2],
                'nested': {'a': 1},
              }),
          returnsNormally);
      expect(() => ActivityService.trackListingView(listingId: 'not-a-uuid'),
          returnsNormally);
      expect(() => ActivityService.trackShare(type: 'event', id: null),
          returnsNormally);
    });
  });
}
