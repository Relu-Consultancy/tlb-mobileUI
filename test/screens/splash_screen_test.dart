import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/screens/splash_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  group('SplashScreen Tests', () {
    testWidgets('renders splash screen and logo', (WidgetTester tester) async {
      final mockNextScreen = Scaffold(body: Text('Next Screen'));

      await pumpTLBApp(tester, SplashScreen(nextScreen: mockNextScreen));

      // Verify the splash screen is rendered by finding the asset image
      expect(find.byType(Image), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == 'assets/images/tlb_logo.png',
        ),
        findsOneWidget,
      );

      // Verify the animation progresses
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(Image), findsOneWidget);

      // Verify navigation occurs after the animation completes (3600ms total)
      await tester.pumpAndSettle(const Duration(milliseconds: 4000));
      expect(find.text('Next Screen'), findsOneWidget);
    });
  });
}
