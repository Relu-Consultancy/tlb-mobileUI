import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/screens/notification_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  group('NotificationScreen Tests', () {
    testWidgets('renders title and currently-being-developed card',
        (WidgetTester tester) async {
      await pumpTLBApp(tester, const NotificationScreen());

      expect(find.text('Notifications'), findsOneWidget);
      // Notifications API isn't wired yet — the screen shows a clear
      // "Currently being developed" card instead of a fake empty state.
      expect(find.text('Currently being developed'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
    });

    testWidgets('coming-soon body copy is present',
        (WidgetTester tester) async {
      await pumpTLBApp(tester, const NotificationScreen());

      expect(
        find.textContaining("We're building in-app notifications"),
        findsOneWidget,
      );
    });

    testWidgets('no mock notification cards are shown',
        (WidgetTester tester) async {
      // Regression guard — the screen has historically been re-introduced
      // with mock data; this keeps it honest.
      await pumpTLBApp(tester, const NotificationScreen());

      expect(find.text('Limited Time Cashback'), findsNothing);
      expect(find.text('Classes Rescheduled'), findsNothing);
      expect(find.text('Today'), findsNothing);
      expect(find.text('Yesterday'), findsNothing);
    });
  });
}
