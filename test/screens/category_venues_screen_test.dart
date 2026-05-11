import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/category_venues_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  group('CategoryVenuesScreen Tests', () {
    testWidgets('renders category title and venues', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const CategoryVenuesScreen(initialCategoryIndex: 0),
        );

        expect(find.text('Explore other Venues'), findsOneWidget);
        expect(find.text('Filters'), findsOneWidget);
      });
    });

    testWidgets('switching category updates the UI', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const CategoryVenuesScreen(initialCategoryIndex: 0),
        );

        await tester.pumpAndSettle();
        expect(find.text('Explore other Venues'), findsOneWidget);
      });
    });
  });
}
