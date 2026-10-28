import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_provider_model.dart';
import 'package:tlb_mobile_ui/screens/organizer_profile_screen.dart';
import 'package:tlb_mobile_ui/widgets/social_links_row.dart';

import '../helpers/test_setup.dart';

ApiProvider _provider({
  int? followers = 128,
  String? instagram = 'https://instagram.com/funtime',
}) =>
    ApiProvider(
      id: 'p1',
      name: 'The Grand Maze',
      bio: 'We bring unique experiences.',
      totalListings: 4,
      averageRating: 0,
      totalReviews: 0,
      experienceYears: 0,
      totalFollowers: followers,
      instagramUrl: instagram,
    );

/// Supplying [provider] makes the screen skip its fetch, so these run without
/// a network stub. listingType stays null so the Upcoming Events section —
/// which does fetch — is not built.
Future<void> _pump(WidgetTester tester, ApiProvider provider) =>
    pumpTLBApp(
      tester,
      OrganizerProfileScreen(listingId: 'l1', provider: provider),
    );

void main() {
  group('Organizer profile — follower count', () {
    testWidgets('TC_S_OP_001 — shows the count the API sent', (tester) async {
      await _pump(tester, _provider());
      expect(find.text('128 Followers'), findsOneWidget);
    });

    testWidgets('TC_S_OP_002 — sits under the name, above the social marks',
        (tester) async {
      await _pump(tester, _provider());

      final name = tester.getTopLeft(find.text('The Grand Maze')).dy;
      final followers = tester.getTopLeft(find.text('128 Followers')).dy;
      final social = tester.getTopLeft(find.byType(SocialLinksRow)).dy;

      expect(followers, greaterThan(name));
      expect(followers, lessThan(social));
    });

    // Null means the field was absent, which is not the same as nobody
    // following — "0 Followers" on a partner you follow reads as a bug.
    testWidgets('TC_S_OP_003 — an unknown count shows nothing at all',
        (tester) async {
      await _pump(tester, _provider(followers: null));
      expect(find.textContaining('Follower'), findsNothing);
    });

    testWidgets('TC_S_OP_004 — a real zero is still shown', (tester) async {
      await _pump(tester, _provider(followers: 0));
      expect(find.text('0 Followers'), findsOneWidget);
    });

    testWidgets('TC_S_OP_005 — one follower is not plural', (tester) async {
      await _pump(tester, _provider(followers: 1));
      expect(find.text('1 Follower'), findsOneWidget);
    });

    testWidgets('TC_S_OP_006 — thousands are abbreviated', (tester) async {
      await _pump(tester, _provider(followers: 12300));
      expect(find.text('12.3k Followers'), findsOneWidget);
    });
  });

  group('Organizer profile — social marks', () {
    testWidgets('TC_S_OP_007 — only the links the partner set are drawn',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _provider());
      expect(find.bySemanticsLabel('Instagram'), findsOneWidget);
      expect(find.bySemanticsLabel('Facebook'), findsNothing);
      expect(find.bySemanticsLabel('LinkedIn'), findsNothing);
      handle.dispose();
    });

    testWidgets('TC_S_OP_008 — a partner with no links draws no marks',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _provider(instagram: null));
      expect(find.bySemanticsLabel('Instagram'), findsNothing);
      expect(tester.getSize(find.byType(SocialLinksRow)).height, 0);
      handle.dispose();
    });
  });
}
