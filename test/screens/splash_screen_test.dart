import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/screens/splash_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  group('SplashScreen Tests', () {
    testWidgets('renders splash logo and navigates', (WidgetTester tester) async {
      const mockNextScreen = Scaffold(body: Text('Next Screen'));

      await pumpTLBApp(tester, const SplashScreen(nextScreen: mockNextScreen));

      // Logo is rendered as the TLB SVG. The cursive tagline that used to sit
      // below it was removed — guard against it coming back by accident.
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('Where every star shines'), findsNothing);

      // Animation progresses
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(SvgPicture), findsOneWidget);

      // Navigation occurs after the animation completes (~2800ms + transition).
      await tester.pumpAndSettle(const Duration(milliseconds: 4000));
      expect(find.text('Next Screen'), findsOneWidget);
    });

    testWidgets('TC_S_SP_002 — the logo sits on the flat gold, with no glow',
        (WidgetTester tester) async {
      // A soft white RadialGradient used to bloom behind the logo. The gold
      // ground is flat now, so nothing on this screen paints a gradient.
      await pumpTLBApp(
        tester,
        const SplashScreen(nextScreen: Scaffold(body: Text('Next Screen'))),
      );
      await tester.pump(const Duration(milliseconds: 1000));

      final gradients = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.gradient != null);

      expect(gradients, isEmpty);
      // ...and the query does reach this screen's decorations at all — the
      // loading dots are DecoratedBoxes — so an empty list above means "no
      // gradient", not "found nothing to look at".
      expect(
        tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .map((d) => d.decoration)
            .whereType<BoxDecoration>(),
        isNotEmpty,
      );
    });
  });
}
