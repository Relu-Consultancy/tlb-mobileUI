import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/screens/notification_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  group('NotificationScreen Tests', () {
    testWidgets('renders title and empty state', (WidgetTester tester) async {
      await pumpTLBApp(tester, const NotificationScreen());

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('No Notifications Yet'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
    });

    testWidgets('empty state body copy is present', (WidgetTester tester) async {
      await pumpTLBApp(tester, const NotificationScreen());

      expect(
        find.textContaining("You're all caught up"),
        findsOneWidget,
      );
    });

    testWidgets('no mock notification cards are shown', (WidgetTester tester) async {
      await pumpTLBApp(tester, const NotificationScreen());

      expect(find.text('Limited Time Cashback'), findsNothing);
      expect(find.text('Classes Rescheduled'), findsNothing);
      expect(find.text('Today'), findsNothing);
      expect(find.text('Yesterday'), findsNothing);
    });
  });
}
