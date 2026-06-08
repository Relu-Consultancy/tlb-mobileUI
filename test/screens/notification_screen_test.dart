import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/screens/notification_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  group('NotificationScreen Tests', () {
    testWidgets('renders the Notifications title',
        (WidgetTester tester) async {
      await pumpTLBApp(tester, const NotificationScreen());

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows a log-in prompt when not authenticated',
        (WidgetTester tester) async {
      // With no access token (the default in tests) the screen short-circuits
      // to a "please log in" message instead of hitting the network.
      await pumpTLBApp(tester, const NotificationScreen());
      await tester.pump();

      expect(find.textContaining('log in'), findsOneWidget);
    });

    testWidgets('no hard-coded mock notification cards are shown',
        (WidgetTester tester) async {
      // Regression guard — the screen has historically been re-introduced
      // with mock data; this keeps it honest.
      await pumpTLBApp(tester, const NotificationScreen());

      expect(find.text('Limited Time Cashback'), findsNothing);
      expect(find.text('Classes Rescheduled'), findsNothing);
    });
  });
}
