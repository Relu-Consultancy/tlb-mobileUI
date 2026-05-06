import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/category_events_screen.dart';
import 'package:tlb_mobile_ui/data/dummy_data.dart';

import '../helpers/test_setup.dart';

void main() {
  group('CategoryEventsScreen Tests', () {
    testWidgets('renders category title and events', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        // Use index 0 (Art & Craft)
        await pumpTLBApp(tester, const CategoryEventsScreen(initialCategoryIndex: 0));

        final title = DummyData.exploreCategories[0]['label'].toString().replaceAll('\n', ' ');
        expect(find.text(title), findsOneWidget);
        expect(find.text('Explore other Categories'), findsOneWidget);
        expect(find.text('All $title'), findsOneWidget);
        
        // Verify filter chips
        expect(find.text('Filters'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
      });
    });

    testWidgets('switching category updates the UI', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const CategoryEventsScreen(initialCategoryIndex: 0));

        // Tap on index 1 (Music & Dance)
        final cat1Label = DummyData.exploreCategories[1]['label'].toString();
        await tester.tap(find.text(cat1Label));
        await tester.pumpAndSettle();

        final title1 = cat1Label.replaceAll('\n', ' ');
        expect(find.text(title1), findsOneWidget);
      });
    });
  });
}
