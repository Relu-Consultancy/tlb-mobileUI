import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/class_detail_screen.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';

import '../helpers/test_setup.dart';

void main() {
  final testEvent = EventModel(
    title: 'Test Class',
    imagePath: 'assets/images/test.png',
    venue: 'Test Venue',
    price: 500,
    tag: 'Art',
  );

  group('ClassDetailScreen Tests', () {
    testWidgets('renders event details correctly', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, ClassDetailScreen(event: testEvent));

        expect(find.text('Test Class'), findsOneWidget);
        expect(find.text('Test Venue').first, findsOneWidget);
        expect(find.text('Art'), findsOneWidget);
        expect(find.text('₹500', findRichText: true), findsOneWidget);
        expect(find.text('Check Availability'), findsOneWidget);
      });
    });

    testWidgets('scrolls to reveal gallery and reviews', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, ClassDetailScreen(event: testEvent));

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
        await tester.pumpAndSettle();

        expect(find.text('Gallery'), findsOneWidget);
        expect(find.text('Reviews'), findsOneWidget);
      });
    });
  });
}
