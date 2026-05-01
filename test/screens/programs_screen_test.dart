import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/programs_screen.dart';
import 'package:tlb_mobile_ui/widgets/floating_navbar.dart';

import '../helpers/test_setup.dart';

void main() {
  group('ProgramsScreen Tests', () {
    testWidgets('renders all major sections and floating navbar', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const ProgramsScreen());

        // Verify sections by titles
        expect(find.text('Pave Your Path'), findsOneWidget);
        expect(find.text('The Big Leagues'), findsOneWidget);
        expect(find.text('Make Your Weekends Count'), findsOneWidget);
        expect(find.text('Find Your Fit'), findsOneWidget);
        expect(find.text('Zero to Hero'), findsOneWidget);
        expect(find.text('The Holiday Edit'), findsOneWidget);
        expect(find.text('For Unique Minds'), findsOneWidget);
        expect(find.text('Level Up Your Profile'), findsOneWidget);

        // Verify FloatingNavbar is present and has the correct active index (Programs = 3)
        final navbarFinder = find.byType(FloatingNavbar);
        expect(navbarFinder, findsOneWidget);
        
        final navbar = tester.widget<FloatingNavbar>(navbarFinder);
        expect(navbar.currentIndex, 3);
      });
    });

    testWidgets('scrolls to reveal more content', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const ProgramsScreen());

        // Scroll to the bottom
        await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -2500));
        await tester.pumpAndSettle();

        // Check for footer or last section
        expect(find.text('Level Up Your Profile'), findsOneWidget);
      });
    });
  });
}
