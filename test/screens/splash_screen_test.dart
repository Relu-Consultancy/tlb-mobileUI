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

      // Logo now rendered as the TLB SVG, with the cursive tagline.
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('Where every star shines'), findsOneWidget);

      // Animation progresses
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(SvgPicture), findsOneWidget);

      // Navigation occurs after the animation completes (~2800ms + transition).
      await tester.pumpAndSettle(const Duration(milliseconds: 4000));
      expect(find.text('Next Screen'), findsOneWidget);
    });
  });
}
