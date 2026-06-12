import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/classes_screen.dart';
import 'package:tlb_mobile_ui/widgets/floating_navbar.dart';

import '../helpers/test_setup.dart';

void main() {
  group('ClassesScreen Tests', () {
    testWidgets('renders all major sections and floating navbar', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const ClassesScreen());

        // Verify sections by titles
        expect(find.text("Let's Begin Here"), findsOneWidget);
        expect(find.text("What's Everyone Joining?"), findsOneWidget);
        expect(find.text('Pick Your Pace'), findsOneWidget);
        expect(find.text('Right Around You'), findsOneWidget);
        expect(find.text('Top Picks For You'), findsOneWidget);
        expect(find.text('Holiday Special'), findsOneWidget);
        expect(find.text('Build New Skills'), findsOneWidget);
        expect(find.text('Special Focus'), findsOneWidget);

        // Verify FloatingNavbar is present and has the correct active index (Classes = 2)
        final navbarFinder = find.byType(FloatingNavbar);
        expect(navbarFinder, findsOneWidget);
        
        final navbar = tester.widget<FloatingNavbar>(navbarFinder);
        expect(navbar.currentIndex, 2);
      });
    });

    testWidgets('scrolls and shows more content', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const ClassesScreen());

        // Initially "Special Focus" might be off-screen
        // Scroll to the bottom
        await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -2000));
        // Bounded pumps (not pumpAndSettle) — the screen has perpetual
        // auto-scrolling rails + a rotating quote that never "settle".
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        // Check for footer or last section
        expect(find.text('Special Focus'), findsOneWidget);
      });
    });
  });
}
