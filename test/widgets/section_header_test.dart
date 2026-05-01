import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/section_header.dart';

import '../helpers/test_setup.dart';

void main() {
  group('SectionHeader Tests', () {
    testWidgets('renders title correctly without See All', (WidgetTester tester) async {
      await pumpTLBApp(tester, const Scaffold(body: SectionHeader(title: 'Top Events')));

      expect(find.text('Top Events'), findsOneWidget);
      expect(find.text('See All'), findsNothing);
    });

    testWidgets('renders title and subtitle correctly', (WidgetTester tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: SectionHeader(
            title: 'Top Events',
            subtitle: 'Best picks for you',
          ),
        ),
      );

      expect(find.text('Top Events'), findsOneWidget);
      expect(find.text('Best picks for you'), findsOneWidget);
    });

    testWidgets('renders See All button and handles tap', (WidgetTester tester) async {
      bool tapped = false;
      await pumpTLBApp(
        tester,
        Scaffold(
          body: SectionHeader(
            title: 'Top Events',
            onSeeAll: () {
              tapped = true;
            },
          ),
        ),
      );

      final seeAllButton = find.text('See All');
      expect(seeAllButton, findsOneWidget);

      await tester.tap(seeAllButton);
      expect(tapped, isTrue);
    });
  });
}
