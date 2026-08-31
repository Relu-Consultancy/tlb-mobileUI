import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/walkthrough_intro_overlay.dart';

import '../helpers/test_setup.dart';

void main() {
  group('WalkthroughIntroOverlay', () {
    testWidgets('TC_W_WIO_001 — previews all four sections and the headline',
        (tester) async {
      await pumpTLBApp(
        tester,
        WalkthroughIntroOverlay(onNext: () {}, onSkip: () {}),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.textContaining('Welcome to'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Classes'), findsOneWidget);
      expect(find.text('Programs'), findsOneWidget);
      expect(find.text('Venues'), findsOneWidget);
      expect(find.text('Take the Tour'), findsOneWidget);
    });

    // Previously there was no way out of the intro at all — every path led
    // into the coach-mark tour. This is the escape hatch.
    testWidgets('TC_W_WIO_002 — offers a Skip for now option', (tester) async {
      await pumpTLBApp(
        tester,
        WalkthroughIntroOverlay(onNext: () {}, onSkip: () {}),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Skip for now'), findsOneWidget);
    });

    testWidgets('TC_W_WIO_003 — "Take the Tour" calls onNext, not onSkip',
        (tester) async {
      var nextCalled = false;
      var skipCalled = false;
      await pumpTLBApp(
        tester,
        WalkthroughIntroOverlay(
          onNext: () => nextCalled = true,
          onSkip: () => skipCalled = true,
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text('Take the Tour'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(nextCalled, isTrue);
      expect(skipCalled, isFalse);
    });

    testWidgets('TC_W_WIO_004 — "Skip for now" calls onSkip, not onNext',
        (tester) async {
      var nextCalled = false;
      var skipCalled = false;
      await pumpTLBApp(
        tester,
        WalkthroughIntroOverlay(
          onNext: () => nextCalled = true,
          onSkip: () => skipCalled = true,
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(skipCalled, isTrue);
      expect(nextCalled, isFalse);
    });
  });
}
