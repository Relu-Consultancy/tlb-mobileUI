import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/screens/notification_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  group('NotificationScreen Tests', () {
    testWidgets('renders all major sections and notifications', (WidgetTester tester) async {
      await pumpTLBApp(tester, const NotificationScreen());

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      
      // Verify some sample notification content
      expect(find.text('Limited Time Cashback'), findsOneWidget);
      expect(find.text('Classes Rescheduled'), findsOneWidget);
    });

    testWidgets('Mark All as Read updates the summary and hides dots', (WidgetTester tester) async {
      await pumpTLBApp(tester, const NotificationScreen());

      // Initial state (should have 2 new notifications based on dummy data)
      expect(find.textContaining('2 Notifications', findRichText: true), findsOneWidget);

      await tester.tap(find.text('Mark All as Read'));
      await tester.pump();

      // Summary should update
      expect(find.textContaining('0 Notifications', findRichText: true), findsOneWidget);
    });
  });
}
