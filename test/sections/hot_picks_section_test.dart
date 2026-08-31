import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tlb_mobile_ui/helpers/walkthrough_keys.dart';
import 'package:tlb_mobile_ui/sections/hot_picks_section.dart';
import 'package:tlb_mobile_ui/widgets/walkthrough_tooltip.dart';

import '../helpers/test_setup.dart';

// Showcase's `key:` parameter is package-internal bookkeeping (stored as
// `.showcaseKey`) — its build() just returns `widget.child` unconditionally,
// so this key is never attached as an actual Flutter Widget.key, and the
// tooltip only renders through a separate Overlay once a tour is actively
// targeting it. So the wiring is checked by inspecting the Showcase widget's
// own fields directly, not via find.byKey/find.byType(WalkthroughTooltip) on
// a passively-pumped tree.

void main() {
  group('HotPicksSection walkthrough hook', () {
    setUp(() {
      // Showcase/Showcase.withWidget looks up a globally registered
      // ShowcaseView (this app has no ShowcaseWidget ancestor — see
      // home_screen.dart's register()/unregister() in initState/dispose) and
      // throws if none is registered.
      try {
        ShowcaseView.register();
      } catch (_) {}
    });

    tearDown(() {
      try {
        ShowcaseView.get().unregister();
      } catch (_) {}
    });

    testWidgets('TC_S_HP_001 — renders the section and its cards',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const Scaffold(body: HotPicksSection()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hot Picks'), findsOneWidget);
        expect(find.byType(GestureDetector), findsWidgets);
      });
    });

    // Only the first card should carry the tour's showcase — teaching the
    // interaction once on a concrete example, not on every card in the rail.
    testWidgets(
        'TC_S_HP_002 — only the first card carries the "Tap Any Card" showcase',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const Scaffold(body: HotPicksSection()),
        );
        await tester.pumpAndSettle();

        // Exactly one card is wrapped in Showcase.withWidget, and it's
        // configured with the "Tap Any Card" tooltip.
        expect(find.byType(Showcase), findsOneWidget);

        final showcase = tester.widget<Showcase>(find.byType(Showcase));
        expect(showcase.showcaseKey, WalkthroughKeys.firstSectionCard);
        expect(showcase.container, isA<WalkthroughTooltip>());

        final tooltip = showcase.container as WalkthroughTooltip;
        expect(tooltip.title, 'Tap Any Card');
        expect(tooltip.stepIndex, kSectionCardShowcaseConfig.stepIndex);
      });
    });
  });
}
