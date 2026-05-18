import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/category_events_screen.dart';

import '../helpers/test_setup.dart';

const _testCategories = [
  {
    'label': 'Arts & Crafts',
    'image': 'assets/images/event_subcategories/artcraft.png',
    'gradient': [Color(0xFFE8E0FF), Color(0xFFD4BFFF)],
    'slug': 'arts-crafts',
    'id': 1,
    'subcategories': <String>['Drawing', 'Painting'],
  },
  {
    // Newline in label matches actual chip rendering — tap must use exact string
    'label': 'Sports &\nFitness',
    'image': 'assets/images/event_subcategories/sports.png',
    'gradient': [Color(0xFFFFF8D4), Color(0xFFFFEDA1)],
    'slug': 'sports-fitness',
    'id': 2,
    'subcategories': <String>['Football', 'Swimming'],
  },
];

void main() {
  group('CategoryEventsScreen Tests', () {
    testWidgets('renders category title and events', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const CategoryEventsScreen(
            categories: _testCategories,
            initialCategoryIndex: 0,
          ),
        );

        expect(find.text('Explore other Categories'), findsOneWidget);
        expect(find.text('Filters'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
      });
    });

    testWidgets('switching category updates the header title', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const CategoryEventsScreen(
            categories: _testCategories,
            initialCategoryIndex: 0,
          ),
        );

        // Chip renders raw label with newline — must match exactly
        await tester.tap(find.text('Sports &\nFitness'));
        await tester.pumpAndSettle();

        // CategoryScreenHeader shows _categoryTitle = label.replaceAll('\n', ' ')
        expect(find.text('Sports & Fitness'), findsOneWidget);
      });
    });
  });
}
