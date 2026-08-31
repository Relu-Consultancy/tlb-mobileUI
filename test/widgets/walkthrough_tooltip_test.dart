import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/walkthrough_tooltip.dart';

import '../helpers/test_setup.dart';

void main() {
  group('WalkthroughTooltip', () {
    testWidgets('TC_W_WT_001 — renders the icon, title, description and step count',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: WalkthroughTooltip(
            icon: Icons.home_rounded,
            title: 'Home',
            description: 'Browse curated picks & spotlight events',
            stepIndex: 1,
            totalSteps: 7,
            onNext: () {},
            onSkip: () {},
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Browse curated picks & spotlight events'),
          findsOneWidget);
      // stepIndex is 0-based; the counter is 1-based ("2 / 7").
      expect(find.text('2 / 7'), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('TC_W_WT_002 — a middle step says Next and offers Skip',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: WalkthroughTooltip(
            icon: Icons.home_rounded,
            title: 'Home',
            description: 'desc',
            stepIndex: 2,
            totalSteps: 7,
            onNext: () {},
            onSkip: () {},
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Got it'), findsNothing);
      expect(find.text('Skip tour'), findsOneWidget);
    });

    // The last step is a destination, not a step toward one — "Next" would
    // be misleading, and there's nothing left to skip to.
    testWidgets(
        'TC_W_WT_003 — the last step says Got it and has no Skip button',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: WalkthroughTooltip(
            icon: Icons.person_rounded,
            title: 'Profile',
            description: 'desc',
            stepIndex: 6,
            totalSteps: 7,
            onNext: () {},
            onSkip: () {},
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Got it'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
      expect(find.text('Skip tour'), findsNothing);
    });

    testWidgets('TC_W_WT_004 — tapping the primary button calls onNext',
        (tester) async {
      var called = false;
      await pumpTLBApp(
        tester,
        Scaffold(
          body: WalkthroughTooltip(
            icon: Icons.home_rounded,
            title: 'Home',
            description: 'desc',
            stepIndex: 0,
            totalSteps: 7,
            onNext: () => called = true,
            onSkip: () {},
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('TC_W_WT_005 — tapping Skip tour calls onSkip', (tester) async {
      var called = false;
      await pumpTLBApp(
        tester,
        Scaffold(
          body: WalkthroughTooltip(
            icon: Icons.home_rounded,
            title: 'Home',
            description: 'desc',
            stepIndex: 0,
            totalSteps: 7,
            onNext: () {},
            onSkip: () => called = true,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('Skip tour'));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('TC_W_WT_006 — renders one progress dot per step', (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: WalkthroughTooltip(
            icon: Icons.home_rounded,
            title: 'Home',
            description: 'desc',
            stepIndex: 3,
            totalSteps: 7,
            onNext: () {},
            onSkip: () {},
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 7 dots + the icon badge circle + any other AnimatedContainer in the
      // tree — scope to the dots row specifically via the container decoration
      // count is fragile, so instead assert indirectly: exactly 7 borderless
      // pill/dot AnimatedContainers exist inside the tooltip.
      final dots = tester.widgetList<AnimatedContainer>(
        find.descendant(
          of: find.byType(WalkthroughTooltip),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(dots.length, 7);
    });
  });
}
