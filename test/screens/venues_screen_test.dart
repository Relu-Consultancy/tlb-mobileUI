import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/venues_screen.dart';
import 'package:tlb_mobile_ui/widgets/floating_navbar.dart';

import '../helpers/test_setup.dart';

void main() {
  group('VenuesScreen Tests', () {
    testWidgets('renders all major sections and floating navbar', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const VenuesScreen());

        // Verify sections by titles
        expect(find.text("What's the Plan?"), findsOneWidget);
        expect(find.text('For the Big Days'), findsOneWidget);
        expect(find.text('Weekend Plan Sorted'), findsOneWidget);
        expect(find.text('Close to You'), findsOneWidget);
        expect(find.text('Out & About'), findsOneWidget);
        expect(find.text('Get Moving'), findsOneWidget);
        expect(find.text('Hand-On Spaces'), findsOneWidget);
        expect(find.text('Easy on the Pocket'), findsOneWidget);
        expect(find.text('Headed to the Mall?'), findsOneWidget);
        expect(find.text('Your Way, Your Plan'), findsOneWidget);
        expect(find.text('Thoughtful Spaces'), findsOneWidget);

        // Verify FloatingNavbar is present and has the correct active index (Venues = 4)
        final navbarFinder = find.byType(FloatingNavbar);
        expect(navbarFinder, findsOneWidget);
        
        final navbar = tester.widget<FloatingNavbar>(navbarFinder);
        expect(navbar.currentIndex, 4);
      });
    });

    testWidgets('scrolls and shows more content', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const VenuesScreen());

        // Scroll to the bottom
        await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -3500));
        await tester.pumpAndSettle();

        // Check for footer or last section
        expect(find.text('Thoughtful Spaces'), findsOneWidget);
      });
    });
  });
}
