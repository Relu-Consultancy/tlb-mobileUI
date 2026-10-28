import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/explore_categories_grid.dart';

import '../helpers/test_setup.dart';

void main() {
  final List<Map<String, dynamic>> testCategories = [
    {
      'label': 'Category 1',
      'image': 'assets/images/placeholder1.png',
      'gradient': [Colors.red, Colors.blue],
    },
    {
      'label': 'Category 2',
      'image': 'assets/images/placeholder2.png',
      'gradient': [Colors.green, Colors.yellow],
    },
  ];

  group('ExploreCategoriesGrid Tests', () {
    testWidgets('renders categories correctly in static mode', (WidgetTester tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: ExploreCategoriesGrid(
            categories: testCategories,
            scrollable: false,
          ),
        ),
      );

      expect(find.text('Category 1'), findsOneWidget);
      expect(find.text('Category 2'), findsOneWidget);
      expect(find.text('View All'), findsNothing);
    });

    testWidgets('renders categories correctly in scrollable mode', (WidgetTester tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: ExploreCategoriesGrid(
            categories: testCategories,
            scrollable: true,
            scrollHeight: 300,
          ),
        ),
      );

      expect(find.text('Category 1'), findsOneWidget);
      expect(find.text('Category 2'), findsOneWidget);
    });

    testWidgets('handles onViewAll and onCategoryTap callbacks', (WidgetTester tester) async {
      bool viewAllTapped = false;
      int? categoryTapped;

      await pumpTLBApp(
        tester,
        Scaffold(
          body: ExploreCategoriesGrid(
            categories: testCategories,
            onViewAll: () => viewAllTapped = true,
            onCategoryTap: (index) => categoryTapped = index,
          ),
        ),
      );

      // Verify View All button
      final viewAllBtn = find.text('View All');
      expect(viewAllBtn, findsOneWidget);
      await tester.tap(viewAllBtn);
      expect(viewAllTapped, isTrue);

      // Verify category tap
      final category1 = find.text('Category 1');
      await tester.tap(category1);
      expect(categoryTapped, equals(0));
    });
  });
}
