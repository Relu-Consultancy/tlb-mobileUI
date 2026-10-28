import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_provider_model.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/screens/organizer_profile_screen.dart';
import 'package:tlb_mobile_ui/services/activity_service.dart';

import '../helpers/test_setup.dart';

/// Partner profile views — POST /partner/{id}/track-view/, the "profile
/// views" count on the partner's dashboard. Once per profile open; works
/// signed out.
const _partner = '550e8400-e29b-41d4-a716-446655440000';

ApiProvider _provider(String id) => ApiProvider(
      id: id,
      name: 'The Grand Maze',
      bio: 'We bring unique experiences.',
      totalListings: 0,
      averageRating: 0,
      totalReviews: 0,
      experienceYears: 0,
    );

void main() {
  late List<(String, String?)> sent;
  late DateTime clock;

  setUp(() {
    sent = [];
    clock = DateTime(2026, 10, 7, 12);
    ActivityService.resetForTest();
    ActivityService.sendPartnerView = (id, token) async => sent.add((id, token));
    ActivityService.now = () => clock;
    AuthState.isLoggedIn.value = false;
    AuthState.accessToken = null;
  });

  tearDown(() {
    ActivityService.resetForTest();
    AuthState.isLoggedIn.value = false;
    AuthState.accessToken = null;
  });

  group('ActivityService.trackPartnerView', () {
    test('TC_A_PV_001 — works signed out, with no token', () {
      ActivityService.trackPartnerView(_partner);
      expect(sent, [(_partner, null)]);
    });

    test('TC_A_PV_002 — signed in, the token goes along', () {
      AuthState.isLoggedIn.value = true;
      AuthState.accessToken = 'access-123';
      ActivityService.trackPartnerView(_partner);
      expect(sent, [(_partner, 'access-123')]);
    });

    test('TC_A_PV_003 — the same partner within 30 minutes is sent once', () {
      ActivityService.trackPartnerView(_partner);
      clock = clock.add(const Duration(minutes: 10));
      ActivityService.trackPartnerView(_partner);
      expect(sent, hasLength(1));

      clock = clock.add(const Duration(minutes: 21));
      ActivityService.trackPartnerView(_partner);
      expect(sent, hasLength(2));
    });

    test('TC_A_PV_004 — stays under the 20-a-minute limit', () {
      for (var i = 0; i < 30; i++) {
        final id = '550e8400-e29b-41d4-a716-${i.toString().padLeft(12, '0')}';
        ActivityService.trackPartnerView(id);
      }
      expect(sent.length, lessThan(20));
    });

    test('TC_A_PV_005 — a non-partner id is ignored, failures are swallowed',
        () async {
      ActivityService.trackPartnerView('p1');
      expect(sent, isEmpty);

      ActivityService.sendPartnerView = (_, __) => throw StateError('boom');
      expect(() => ActivityService.trackPartnerView(_partner), returnsNormally);
      ActivityService.sendPartnerView =
          (_, __) async => throw Exception('offline');
      clock = clock.add(const Duration(hours: 1));
      ActivityService.trackPartnerView(_partner);
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
  });

  group('OrganizerProfileScreen', () {
    testWidgets('TC_S_PV_006 — opening a profile sends one view',
        (tester) async {
      await pumpTLBApp(
        tester,
        OrganizerProfileScreen(listingId: 'l1', provider: _provider(_partner)),
      );
      expect(sent, [(_partner, null)]);
    });

    testWidgets('TC_S_PV_007 — rebuilds do not send another', (tester) async {
      await pumpTLBApp(
        tester,
        OrganizerProfileScreen(listingId: 'l1', provider: _provider(_partner)),
      );
      // Rebuild with a new configuration of the same screen.
      final state = tester.state(find.byType(OrganizerProfileScreen));
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(sent, hasLength(1));
    });
  });
}
